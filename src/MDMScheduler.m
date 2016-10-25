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

#import "MDMScheduler.h"

#import "MDMPerformerGroup.h"
#import "MDMPerformerGroupDelegate.h"
#import "MDMTracing.h"
#import "MDMTransaction+Private.h"

@interface MDMScheduler () <MDMPerformerGroupDelegate>

@property(nonatomic, strong) NSMapTable *targetToPerformerGroup;
@property(nonatomic, strong) NSMutableSet *activePerformerGroups;

@end

@implementation MDMScheduler {
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
    performerGroup = [[MDMPerformerGroup alloc] initWithTarget:target scheduler:self];
    performerGroup.delegate = self;
    [self.targetToPerformerGroup setObject:performerGroup forKey:target];
  }

  return performerGroup;
}

#pragma mark MDMPerformerGroupDelegate

- (void)performerGroup:(MDMPerformerGroup *)performerGroup activeStateDidChange:(BOOL)isActive {
  BOOL schedulerWasActive = [self activityState] == MDMSchedulerActivityStateActive;

  if (isActive) {
    [self.activePerformerGroups addObject:performerGroup];
  } else {
    [self.activePerformerGroups removeObject:performerGroup];
  }

  BOOL schedulerIsActive = [self activityState] == MDMSchedulerActivityStateActive;
  if (schedulerWasActive != schedulerIsActive) {
    [self.delegate schedulerActivityStateDidChange:self];
  }
}

#pragma mark - Public

- (MDMSchedulerActivityState)activityState {
  return (self.activePerformerGroups.count > 0) ? MDMSchedulerActivityStateActive : MDMSchedulerActivityStateIdle;
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
