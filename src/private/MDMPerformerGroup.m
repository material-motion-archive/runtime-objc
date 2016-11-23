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

#import "MDMIsActiveTokenGenerator.h"
#import "MDMPerformerGroupDelegate.h"
#import "MDMPerformerInfo.h"
#import "MDMPerforming.h"
#import "MDMPlan.h"
#import "MDMPlanEmitter.h"
#import "MDMRuntime.h"
#import "MDMTracing.h"

@interface MDMPerformerGroup ()
@property(nonatomic, weak) MDMRuntime *runtime;
@property(nonatomic, strong, readonly) NSMutableArray<MDMPerformerInfo *> *performerInfos;
@property(nonatomic, strong, readonly) NSMutableDictionary *performerClassNameToPerformerInfo;
@property(nonatomic, strong, readonly) NSMutableDictionary *performerPlanNameToPerformerInfo;
@property(nonatomic, strong, readonly) NSMutableSet *activePerformers;
@end

@implementation MDMPerformerGroup

- (instancetype)initWithTarget:(id)target runtime:(MDMRuntime *)runtime {
  self = [super init];
  if (self) {
    _target = target;
    _runtime = runtime;
    _performerInfos = [NSMutableArray array];
    _performerClassNameToPerformerInfo = [NSMutableDictionary dictionary];
    _performerPlanNameToPerformerInfo = [NSMutableDictionary dictionary];
    _activePerformers = [NSMutableSet set];
  }
  return self;
}

- (void)addPlan:(nonnull id<MDMPlan>)plan to:(nonnull id)target {
  BOOL isNew = NO;
  id<MDMPerforming> performer = [self findOrCreatePerformerForPlan:plan isNew:&isNew];
  if (isNew) {
    [self notifyPerformerCreation:performer target:target];
  }
  [self notifyPlanAdded:plan to:target performer:performer];
}

- (void)addPlan:(nonnull id<MDMNamedPlan>)plan named:(nonnull NSString *)name to:(nonnull id)target {
  // remove first
  MDMPerformerInfo *cachedPerformerInfo = self.performerPlanNameToPerformerInfo[name];
  [self removePlanNamed:name from:target withPerformer:cachedPerformerInfo.performer];

  // then add
  BOOL isNew = NO;
  MDMPerformerInfo *performerInfo = [self findOrCreatePerformerInfoForNamedPlan:plan named:name isNew:&isNew];
  id<MDMPerforming> performer = performerInfo.performer;
  self.performerPlanNameToPerformerInfo[name] = performerInfo;
  if (isNew) {
    [self notifyPerformerCreation:performer target:target];
  }
  [self notifyNamedPlanAdded:plan named:name to:target performer:(id<MDMNamedPlanPerforming>)performer];
}

- (void)removePlanNamed:(nonnull NSString *)name from:(nonnull id)target {
  MDMPerformerInfo *cachedPerformerInfo = self.performerPlanNameToPerformerInfo[name];
  [self removePlanNamed:name from:target withPerformer:cachedPerformerInfo.performer];
}

- (void)registerIsActiveToken:(id<MDMIsActiveTokenable>)token
            withPerformerInfo:(MDMPerformerInfo *)performerInfo {
  NSAssert(performerInfo.performer, @"Performer no longer exists.");

  [performerInfo.isActiveTokens addObject:token];

  [self didRegisterTokenForPerformerInfo:performerInfo];
}

- (void)terminateIsActiveToken:(id<MDMIsActiveTokenable>)token
             withPerformerInfo:(MDMPerformerInfo *)performerInfo {
  NSAssert(performerInfo.performer, @"Performer no longer exists.");
  NSAssert([performerInfo.isActiveTokens containsObject:token],
           @"Token is not active. May have already been terminated by a previous invocation.");

  [performerInfo.isActiveTokens removeObject:token];

  [self didTerminateTokenForPerformerInfo:performerInfo];
}

#pragma mark - Private

- (void)removePlanNamed:(nonnull NSString *)name from:(nonnull id)target withPerformer:(nullable id<MDMPerforming>)performer {
  if (performer != nil) {
    if ([performer respondsToSelector:@selector(removePlanNamed:)]) {
      [(id<MDMNamedPlanPerforming>)performer removePlanNamed:name];
    }
    [self.performerPlanNameToPerformerInfo removeObjectForKey:name];
    for (id<MDMTracing> tracer in self.runtime.tracers) {
      if ([tracer respondsToSelector:@selector(didRemovePlanNamed:from:)]) {
        [tracer didRemovePlanNamed:name from:target];
      }
    }
  }
}

- (id<MDMPerforming>)findOrCreatePerformerForPlan:(id<MDMPlan>)plan isNew:(BOOL *)isNew {
  return [self findOrCreatePerformerInfoForPlan:plan isNew:isNew].performer;
}

- (MDMPerformerInfo *)findOrCreatePerformerInfoForNamedPlan:(id<MDMNamedPlan>)plan named:(NSString *)name isNew:(BOOL *)isNew {
  // maybe this is a simple lookup
  MDMPerformerInfo *performerInfo = self.performerPlanNameToPerformerInfo[name];
  if (performerInfo) {
    *isNew = NO;
    return performerInfo;
  }
  // see if we can look it up by class name instead
  performerInfo = [self findOrCreatePerformerInfoForPlan:plan isNew:isNew];
  // stash this perfomer info in case we ever want to look it up again
  self.performerPlanNameToPerformerInfo[name] = performerInfo;
  return performerInfo;
}

- (MDMPerformerInfo *)findOrCreatePerformerInfoForPlan:(id<MDMPlan>)plan isNew:(BOOL *)isNew {
  Class performerClass = [plan performerClass];
  id performerClassName = NSStringFromClass(performerClass);
  MDMPerformerInfo *performerInfo = self.performerClassNameToPerformerInfo[performerClassName];
  if (performerInfo) {
    *isNew = NO;
    return performerInfo;
  }
  id<MDMPerforming> performer = [[performerClass alloc] initWithTarget:self.target];
  performerInfo = [[MDMPerformerInfo alloc] init];
  performerInfo.performer = performer;
  [self.performerInfos addObject:performerInfo];
  if (performerClassName != nil) {
    self.performerClassNameToPerformerInfo[performerClassName] = performerInfo;
  }
  [self setUpFeaturesForPerformerInfo:performerInfo];
  *isNew = YES;
  return performerInfo;
}

- (void)setUpFeaturesForPerformerInfo:(MDMPerformerInfo *)performerInfo {
  id<MDMPerforming> performer = performerInfo.performer;

  // Composable performance
  if ([performer respondsToSelector:@selector(setPlanEmitter:)]) {
    id<MDMComposablePerforming> composablePerformer = (id<MDMComposablePerforming>)performer;

    MDMPlanEmitter *emitter = [[MDMPlanEmitter alloc] initWithRuntime:self.runtime target:self.target];
    [composablePerformer setPlanEmitter:emitter];
  }

  // Is-active performance
  if ([performer respondsToSelector:@selector(setIsActiveTokenGenerator:)]) {
    id<MDMContinuousPerforming> continuousPerformer = (id<MDMContinuousPerforming>)performer;

    MDMIsActiveTokenGenerator *generator = [[MDMIsActiveTokenGenerator alloc] initWithPerformerGroup:self
                                                                                       performerInfo:performerInfo];
    [continuousPerformer setIsActiveTokenGenerator:generator];
  }
}

- (void)didRegisterTokenForPerformerInfo:(MDMPerformerInfo *)performerInfo {
  BOOL wasInactive = self.activePerformers.count == 0;

  [self.activePerformers addObject:performerInfo.performer];

  if (wasInactive) {
    [self.delegate performerGroup:self activeStateDidChange:YES];
  }
}

- (void)didTerminateTokenForPerformerInfo:(MDMPerformerInfo *)performerInfo {
  if (performerInfo.isActiveTokens.count == 0) {
    [self.activePerformers removeObject:performerInfo.performer];

    if (self.activePerformers.count == 0) {
      [self.delegate performerGroup:self activeStateDidChange:NO];
    }
  }
}

- (void)notifyPlanAdded:(id<MDMPlan>)plan to:(id)target performer:(id<MDMPerforming>)performer {
  [performer addPlan:plan];
  for (id<MDMTracing> tracer in self.runtime.tracers) {
    if ([tracer respondsToSelector:@selector(didAddPlan:to:)]) {
      [tracer didAddPlan:plan to:target];
    }
  }
}

- (void)notifyNamedPlanAdded:(id<MDMNamedPlan>)plan named:(NSString *)name to:(id)target performer:(id<MDMNamedPlanPerforming>)performer {
  if ([performer respondsToSelector:@selector(addPlan:named:)]) {
    [performer addPlan:plan named:name];
  }
  for (id<MDMTracing> tracer in self.runtime.tracers) {
    if ([tracer respondsToSelector:@selector(didAddPlan:named:to:)]) {
      [tracer didAddPlan:plan named:name to:target];
    }
  }
}

- (void)notifyPerformerCreation:(id<MDMPerforming>)performer target:(id)target {
  for (id<MDMTracing> tracer in self.runtime.tracers) {
    if ([tracer respondsToSelector:@selector(didCreatePerformer:for:)]) {
      [tracer didCreatePerformer:performer for:self.target];
    }
  }
}

@end
