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

#import "MDMMotionRuntime.h"

#import "MDMTracing.h"
#import "private/MDMTargetRegistry.h"
#import "private/MDMTargetScope.h"
#import "private/MDMToken.h"
#import "private/MDMTokenPool.h"

@interface MDMMotionRuntime () <MDMTokenActivityObserving>

@property(nonatomic, strong, readonly) NSMutableSet<id<MDMTokened>> *activeTokens;

@end

@implementation MDMMotionRuntime {
  MDMTargetRegistry *_targetRegistry;
  NSMutableOrderedSet<id<MDMTracing>> *_tracers;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _tracers = [NSMutableOrderedSet orderedSet];
    _targetRegistry = [[MDMTargetRegistry alloc] initWithRuntime:self tracers:_tracers];
    _activeTokens = [NSMutableSet set];
  }
  return self;
}

#pragma mark - Private

- (void)willAddPlan:(NSObject<MDMPlan> *)plan {
  MDMToken *token = (MDMToken *)[_targetRegistry.tokenPool tokenForPlan:plan];
  [token addActivityObserver:self];
}

- (void)stateDidChange {
  if ([self.delegate respondsToSelector:@selector(motionRuntimeActivityStateDidChange:)]) {
    [self.delegate motionRuntimeActivityStateDidChange:self];
  }
}

#pragma mark - MDMTokenActivityObserving

- (void)tokenDidActivate:(MDMToken *)token {
  BOOL wasInactive = _activeTokens.count == 0;

  [_activeTokens addObject:token];

  if (wasInactive) {
    [self stateDidChange];
  }
}

- (void)tokenDidDeactivate:(MDMToken *)token {
  NSAssert([_activeTokens containsObject:token],
           @"Token is not active. May have already been terminated by a previous invocation.");

  [_activeTokens removeObject:token];

  if (_activeTokens.count == 0) {
    [self stateDidChange];
  }
}

#pragma mark - Public

- (BOOL)isActive {
  return self.activeTokens.count > 0;
}

- (void)addPlan:(NSObject<MDMPlan> *)plan to:(id)target {
  NSObject<MDMPlan> *copiedPlan = [plan copy];
  [self willAddPlan:copiedPlan];
  [_targetRegistry addPlan:copiedPlan to:target];
}

- (void)addPlans:(nonnull NSArray<NSObject<MDMPlan> *> *)plans to:(nonnull id)target {
  for (NSObject<MDMPlan> *plan in plans) {
    [self addPlan:plan to:target];
  }
}

- (void)addPlan:(NSObject<MDMNamedPlan> *)plan named:(NSString *)name to:(id)target {
  NSParameterAssert(name.length > 0);
  NSObject<MDMNamedPlan> *copiedPlan = [plan copy];
  [self willAddPlan:(NSObject<MDMPlan> *)copiedPlan];
  [_targetRegistry addPlan:copiedPlan named:name to:target];
}

- (void)removePlanNamed:(NSString *)name from:(id)target {
  NSParameterAssert(name.length > 0);
  [_targetRegistry removePlanNamed:name from:target];
}

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
