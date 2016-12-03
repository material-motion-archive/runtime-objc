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

#import "MDMTargetRegistry.h"

#import "MDMPlanEmitter.h"
#import "MDMTargetScope.h"
#import "MDMTokenPool.h"

@implementation MDMTargetRegistry {
  NSMapTable<id, MDMTargetScope *> *_targetToScope;
  NSOrderedSet<id<MDMTracing>> *_tracers;
}

- (instancetype)initWithRuntime:(nonnull MDMMotionRuntime *)runtime
                        tracers:(nonnull NSOrderedSet<id<MDMTracing>> *)tracers {
  self = [super init];
  if (self) {
    _runtime = runtime;
    _tracers = tracers;

    _targetToScope = [NSMapTable weakToStrongObjectsMapTable];
    _tokenPool = [MDMTokenPool new];
  }
  return self;
}

#pragma mark - Private

- (MDMTargetScope *)scopeForTarget:(id)target {
  MDMTargetScope *scope = [_targetToScope objectForKey:target];
  if (!scope) {
    MDMPlanEmitter *emitter = [[MDMPlanEmitter alloc] initWithTargetRegistry:self target:target];
    scope = [[MDMTargetScope alloc] initWithTarget:target
                                           tracers:_tracers
                                       planEmitter:emitter
                                         tokenPool:_tokenPool];
    [_targetToScope setObject:scope forKey:target];
  }

  return scope;
}

#pragma mark - Public

- (void)addPlan:(NSObject<MDMPlan> *)plan to:(id)target {
  [[self scopeForTarget:target] addPlan:plan to:target];
}

- (void)addPlan:(NSObject<MDMNamedPlan> *)plan named:(NSString *)name to:(id)target {
  NSParameterAssert(name.length > 0);
  [[self scopeForTarget:target] addPlan:plan named:name to:target];
}

- (void)removePlanNamed:(NSString *)name from:(id)target {
  NSParameterAssert(name.length > 0);
  [[self scopeForTarget:target] removePlanNamed:name from:target];
}

@end
