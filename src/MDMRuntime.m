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

#import "MDMRuntime.h"

#import "MDMPerformerGroup.h"
#import "MDMPerformerGroupDelegate.h"
#import "MDMScheduler.h"
#import "MDMTracing.h"
#import "MDMTransaction+Private.h"

@interface MDMRuntime () <MDMPerformerGroupDelegate>

@property(nonatomic, strong) NSMapTable *targetToPerformerGroup;
@property(nonatomic, strong) NSMutableSet *activePerformerGroups;

@end

@implementation MDMRuntime {
  NSMutableOrderedSet *_tracers;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _tracers = [NSMutableOrderedSet orderedSet];
    _targetToPerformerGroup = [NSMapTable weakToStrongObjectsMapTable];
    _activePerformerGroups = [NSMutableSet set];
  }
  return self;
}

#pragma mark - Private

- (MDMPerformerGroup *)performerGroupForTarget:(id)target {
  MDMPerformerGroup *performerGroup = [_targetToPerformerGroup objectForKey:target];
  if (!performerGroup) {
    performerGroup = [[MDMPerformerGroup alloc] initWithTarget:target runtime:self];
    performerGroup.delegate = self;
    [self.targetToPerformerGroup setObject:performerGroup forKey:target];
  }

  return performerGroup;
}

#pragma mark MDMPerformerGroupDelegate

- (void)performerGroup:(MDMPerformerGroup *)performerGroup activeStateDidChange:(BOOL)isActive {
  BOOL runtimeWasActive = [self activityState] == MDMRuntimeActivityStateActive;

  if (isActive) {
    [self.activePerformerGroups addObject:performerGroup];
  } else {
    [self.activePerformerGroups removeObject:performerGroup];
  }

  BOOL runtimeIsActive = [self activityState] == MDMRuntimeActivityStateActive;
  if (runtimeWasActive != runtimeIsActive) {
    if ([self.delegate respondsToSelector:@selector(runtimeActivityStateDidChange:)]) {
      [self.delegate runtimeActivityStateDidChange:self];
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ([self.delegate respondsToSelector:@selector(schedulerActivityStateDidChange:)]) {
      [(id<MDMSchedulerDelegate>)self.delegate schedulerActivityStateDidChange:(MDMScheduler *)self];
    }
#pragma clang diagnostic pop
  }
}

#pragma mark - Public

- (MDMRuntimeActivityState)activityState {
  return (self.activePerformerGroups.count > 0) ? MDMRuntimeActivityStateActive : MDMRuntimeActivityStateIdle;
}

- (void)addPlan:(NSObject<MDMPlan> *)plan to:(id)target {
  id<MDMPlan> copiedPlan = [plan copy];
  [[self performerGroupForTarget:target] addPlan:copiedPlan to:target];
}

- (void)addPlan:(NSObject<MDMNamedPlan> *)plan named:(NSString *)name to:(id)target {
  NSParameterAssert(name.length > 0);
  id<MDMNamedPlan> copiedPlan = [plan copy];
  [[self performerGroupForTarget:target] addPlan:copiedPlan named:name to:target];
}

- (void)removePlanNamed:(NSString *)name from:(id)target {
  NSParameterAssert(name.length > 0);
  [[self performerGroupForTarget:target] removePlanNamed:name from:target];
}

#pragma mark - Private

- (void)addTracer:(nonnull id<MDMTracing>)tracer {
  [_tracers addObject:tracer];
}

- (void)removeTracer:(nonnull id<MDMTracing>)tracer {
  [_tracers removeObject:tracer];
}

- (nonnull NSArray<id<MDMTracing>> *)tracers {
  return _tracers.array;
}

@end
