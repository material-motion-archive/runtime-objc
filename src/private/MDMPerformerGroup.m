/*
 Copyright 2016-present The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "MDMPerformerGroup.h"

#import "MDMPerformerGroupDelegate.h"
#import "MDMPerforming.h"
#import "MDMPlan.h"
#import "MDMScheduler.h"
#import "MDMTransaction+Private.h"

@interface MDMDelegatedPerformanceToken : NSObject <MDMDelegatedPerformingToken>
@end

@implementation MDMDelegatedPerformanceToken
@end

@interface MDMPerformerInfo : NSObject
@property(nonnull, strong) id<MDMPerforming> performer;
@property(nonnull, strong) NSMutableSet<MDMDelegatedPerformanceToken *> *delegatedPerformanceTokens;
@end

@implementation MDMPerformerInfo

- (instancetype)init {
  self = [super init];
  if (self) {
    _delegatedPerformanceTokens = [NSMutableSet set];
  }
  return self;
}

@end

@interface MDMPerformerGroup ()
@property(nonatomic, weak) MDMScheduler *scheduler;
@property(nonatomic, strong) NSMutableArray<MDMPerformerInfo *> *performerInfos;
@property(nonatomic, strong) NSMutableDictionary *performerClassNameToPerformerInfo;
@property(nonatomic, strong) NSMutableSet *activePerformers;
@end

@implementation MDMPerformerGroup

- (instancetype)initWithTarget:(id)target scheduler:(MDMScheduler *)scheduler {
  self = [super init];
  if (self) {
    _target = target;
    _scheduler = scheduler;

    _performerInfos = [NSMutableArray array];
    _performerClassNameToPerformerInfo = [NSMutableDictionary dictionary];
    _activePerformers = [NSMutableSet set];
  }
  return self;
}

- (void)executeLog:(MDMTransactionLog *)log {
  for (id<MDMPlan> plan in log.plans) {
    id<MDMPerforming> performer = [self performerForPlan:plan];

    if ([performer respondsToSelector:@selector(addPlan:)]) {
      [(id<MDMPlanPerforming>)performer addPlan:plan];
    }
  }
}

#pragma mark - Private

- (id<MDMPerforming>)performerForPlan:(id<MDMPlan>)plan {
  Class performerClass = [plan performerClass];
  id performerClassName = NSStringFromClass(performerClass);
  MDMPerformerInfo *performerInfo = self.performerClassNameToPerformerInfo[performerClassName];
  if (performerInfo) {
    return performerInfo.performer;
  }

  id<MDMPerforming> performer = [[performerClass alloc] initWithTarget:self.target];

  performerInfo = [[MDMPerformerInfo alloc] init];
  performerInfo.performer = performer;

  [self.performerInfos addObject:performerInfo];
  self.performerClassNameToPerformerInfo[performerClassName] = performerInfo;

  [self setUpFeaturesForPerformerInfo:performerInfo];

  return performer;
}

- (void)setUpFeaturesForPerformerInfo:(MDMPerformerInfo *)performerInfo {
  id<MDMPerforming> performer = performerInfo.performer;

  // Composable performance

  if ([performer respondsToSelector:@selector(setTransactBlock:)]) {
    id<MDMComposablePerforming> composablePerformer = (id<MDMComposablePerforming>)performer;

    __weak MDMPerformerGroup *weakSelf = self;
    [composablePerformer setTransactBlock:^(MDMTransactionBlock transactionBlock) {
      MDMPerformerGroup *strongSelf = weakSelf;
      if (!strongSelf.scheduler || !transactionBlock) {
        return;
      }
      MDMTransaction *transaction = [MDMTransaction new];
      transactionBlock(transaction);
      [strongSelf.scheduler commitTransaction:transaction];
    }];
  }

  // Delegated performance

  if ([performer respondsToSelector:@selector(setDelegatedPerformanceWillStart:didEnd:)]) {
    id<MDMDelegatedPerforming> delegatedPerformer = (id<MDMDelegatedPerforming>)performer;

    __weak MDMPerformerInfo *weakInfo = performerInfo;
    __weak MDMPerformerGroup *weakSelf = self;
    MDMDelegatedPerformanceTokenReturnBlock willStartBlock = ^(void) {
      MDMPerformerInfo *strongInfo = weakInfo;
      MDMPerformerGroup *strongSelf = weakSelf;
      if (!strongInfo || !strongSelf) {
        return (id<MDMDelegatedPerformingToken>)nil;
      }

      // Register the work

      MDMDelegatedPerformanceToken *token = [MDMDelegatedPerformanceToken new];
      [strongInfo.delegatedPerformanceTokens addObject:token];

      // Check our group's activity state

      // TODO(featherless): If/when we explore multi-threaded schedulers we need to more cleanly
      // propagate activity state up to the Scheduler. As it stands, this code is not thread-safe.

      BOOL wasInactive = strongSelf.activePerformers.count == 0;

      [strongSelf.activePerformers addObject:strongInfo.performer];

      if (wasInactive) {
        [strongSelf.delegate performerGroup:strongSelf activeStateDidChange:YES];
      }

      return (id<MDMDelegatedPerformingToken>)token;
    };

    MDMDelegatedPerformanceTokenArgBlock didEndBlock = ^(id<MDMDelegatedPerformingToken> token) {
      MDMPerformerInfo *strongInfo = weakInfo;
      MDMPerformerGroup *strongSelf = weakSelf;
      if (!strongInfo) {
        return;
      }

      NSAssert([strongInfo.delegatedPerformanceTokens containsObject:token],
               @"Token is not active. May have already been terminated by a previous invocation.");
      [strongInfo.delegatedPerformanceTokens removeObject:token];

      if (strongInfo.delegatedPerformanceTokens.count == 0) {
        [strongSelf.activePerformers removeObject:strongInfo.performer];

        if (strongSelf.activePerformers.count == 0) {
          [strongSelf.delegate performerGroup:strongSelf activeStateDidChange:NO];
        }
      }
    };

    [delegatedPerformer setDelegatedPerformanceWillStart:willStartBlock didEnd:didEndBlock];
  }
}

@end
