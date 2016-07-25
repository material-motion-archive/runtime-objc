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

@interface MDMPerformerInfo : NSObject
@property(nonnull, strong) id<MDMPerforming> performer;
@property(nonnull, strong) NSMutableSet<NSString *> *delegatedPerformanceNames;
@end

@interface MDMPerformerGroup ()
@property(nonatomic, strong) NSMutableArray<MDMPerformerInfo *> *performerInfos;

@property(nonatomic, strong) NSMutableDictionary *performerClassNameToPerformerInfo;
@property(nonatomic, strong) NSMutableSet *activePerformers;
@end

@implementation MDMPerformerGroup

- (instancetype)initWithTarget:(id)target {
  self = [super init];
  if (self) {
    _target = target;

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

  // Delegated performance

  __weak MDMPerformerInfo *weakInfo = performerInfo;
  __weak MDMPerformerGroup *weakSelf = self;
  void (^willStartNamed)(NSString *_Nonnull) = ^(NSString *name) {
    MDMPerformerInfo *strongInfo = weakInfo;
    MDMPerformerGroup *strongSelf = weakSelf;
    if (!strongInfo || !strongSelf) {
      return;
    }

    // Register the work

    [strongInfo.delegatedPerformanceNames addObject:name];

    // Check our group's activity state

    // TODO(featherless): If/when we explore multi-threaded schedulers we need to more cleanly
    // propagate activity state up to the Scheduler. As it stands, this code is not thread-safe.

    BOOL wasInactive = strongSelf.activePerformers.count == 0;

    [strongSelf.activePerformers addObject:strongInfo.performer];

    if (wasInactive) {
      [strongSelf.delegate performerGroup:strongSelf activeStateDidChange:YES];
    }
  };

  void (^didEndNamed)(NSString *_Nonnull) = ^(NSString *name) {
    MDMPerformerInfo *strongInfo = weakInfo;
    MDMPerformerGroup *strongSelf = weakSelf;
    if (!strongInfo) {
      return;
    }

    [strongInfo.delegatedPerformanceNames removeObject:name];

    if (strongInfo.delegatedPerformanceNames.count == 0) {
      [strongSelf.activePerformers removeObject:strongInfo.performer];

      if (strongSelf.activePerformers.count == 0) {
        [strongSelf.delegate performerGroup:strongSelf activeStateDidChange:NO];
      }
    }
  };

  BOOL canStartDelegated = [performer respondsToSelector:@selector(setDelegatedPerformanceWillStartNamed:)];
  BOOL canEndDelegated = [performer respondsToSelector:@selector(setDelegatedPerformanceDidEndNamed:)];
  if (canStartDelegated && canEndDelegated) {
    id<MDMDelegatedPerforming> delegatedPerformer = (id<MDMDelegatedPerforming>)performer;
    [delegatedPerformer setDelegatedPerformanceWillStartNamed:willStartNamed];
    [delegatedPerformer setDelegatedPerformanceDidEndNamed:didEndNamed];
  }

  if ([performer respondsToSelector:@selector(setDelegatedPerformanceWillStartNamed:didEndNamed:)]) {
    id<MDMDelegatedPerforming> delegatedPerformer = (id<MDMDelegatedPerforming>)performer;
    [delegatedPerformer setDelegatedPerformanceWillStartNamed:willStartNamed
                                                  didEndNamed:didEndNamed];
  }
}

@end

@implementation MDMPerformerInfo

- (instancetype)init {
  self = [super init];
  if (self) {
    _delegatedPerformanceNames = [NSMutableSet set];
  }
  return self;
}

@end
