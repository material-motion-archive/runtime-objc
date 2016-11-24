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
#import "MDMMotionRuntime+Private.h"
#import "MDMPerforming.h"
#import "MDMPlan.h"
#import "MDMPlanEmitter.h"
#import "MDMTracing.h"

@interface MDMPerformerGroup ()
@property(nonatomic, weak) MDMMotionRuntime *runtime;
@property(nonatomic, strong, readonly) NSMutableDictionary *performerClassNameToPerformer;
@property(nonatomic, strong, readonly) NSMutableDictionary *performerPlanNameToPerformer;
@end

@implementation MDMPerformerGroup

- (instancetype)initWithTarget:(id)target runtime:(MDMMotionRuntime *)runtime {
  self = [super init];
  if (self) {
    _target = target;
    _runtime = runtime;
    _performerClassNameToPerformer = [NSMutableDictionary dictionary];
    _performerPlanNameToPerformer = [NSMutableDictionary dictionary];
  }
  return self;
}

- (void)addPlan:(nonnull id<MDMPlan>)plan to:(nonnull id)target {
  BOOL isNew = NO;
  id<MDMPerforming> performer = [self findOrCreatePerformerForPlan:plan isNew:&isNew];

  if (isNew) {
    [self notifyPerformerCreation:performer target:target];
  }

  [performer addPlan:plan];

  for (id<MDMTracing> tracer in self.runtime.tracers) {
    if ([tracer respondsToSelector:@selector(didAddPlan:to:)]) {
      [tracer didAddPlan:plan to:target];
    }
  }
}

- (void)addPlan:(nonnull id<MDMNamedPlan>)plan named:(nonnull NSString *)name to:(nonnull id)target {
  id<MDMNamedPlanPerforming> performer = self.performerPlanNameToPerformer[name];
  [self removePlanNamed:name from:target withPerformer:performer];

  BOOL isNew = NO;
  performer = [self findOrCreatePerformerForNamedPlan:plan named:name isNew:&isNew];
  self.performerPlanNameToPerformer[name] = performer;
  if (isNew) {
    [self notifyPerformerCreation:performer target:target];
  }

  if ([performer respondsToSelector:@selector(addPlan:named:)]) {
    [performer addPlan:plan named:name];
  }
  for (id<MDMTracing> tracer in self.runtime.tracers) {
    if ([tracer respondsToSelector:@selector(didAddPlan:named:to:)]) {
      [tracer didAddPlan:plan named:name to:target];
    }
  }
}

- (void)removePlanNamed:(nonnull NSString *)name from:(nonnull id)target {
  id<MDMNamedPlanPerforming> performer = self.performerPlanNameToPerformer[name];
  [self removePlanNamed:name from:target withPerformer:performer];
}

#pragma mark - Private

- (void)removePlanNamed:(nonnull NSString *)name from:(nonnull id)target withPerformer:(nullable id<MDMPerforming>)performer {
  if (performer != nil) {
    if ([performer respondsToSelector:@selector(removePlanNamed:)]) {
      [(id<MDMNamedPlanPerforming>)performer removePlanNamed:name];
    }
    [self.performerPlanNameToPerformer removeObjectForKey:name];
    for (id<MDMTracing> tracer in self.runtime.tracers) {
      if ([tracer respondsToSelector:@selector(didRemovePlanNamed:from:)]) {
        [tracer didRemovePlanNamed:name from:target];
      }
    }
  }
}

- (id<MDMNamedPlanPerforming>)findOrCreatePerformerForNamedPlan:(id<MDMNamedPlan>)plan
                                                          named:(NSString *)name
                                                          isNew:(BOOL *)isNew {
  id<MDMNamedPlanPerforming> performer = self.performerPlanNameToPerformer[name];
  if (performer) {
    *isNew = NO;
    return performer;
  }
  performer = (id<MDMNamedPlanPerforming>)[self findOrCreatePerformerForPlan:plan isNew:isNew];
  self.performerPlanNameToPerformer[name] = performer;
  return performer;
}

- (id<MDMPerforming>)findOrCreatePerformerForPlan:(id<MDMPlan>)plan isNew:(BOOL *)isNew {
  Class performerClass = [plan performerClass];
  id performerClassName = NSStringFromClass(performerClass);
  id<MDMPerforming> performer = self.performerClassNameToPerformer[performerClassName];
  if (performer) {
    *isNew = NO;
    return performer;
  }
  performer = [[performerClass alloc] initWithTarget:self.target];
  self.performerClassNameToPerformer[performerClassName] = performer;
  [self setUpFeaturesForPerformer:performer];
  *isNew = YES;
  return performer;
}

- (void)setUpFeaturesForPerformer:(id<MDMPerforming>)performer {
  // Composable performance
  if ([performer respondsToSelector:@selector(setPlanEmitter:)]) {
    id<MDMComposablePerforming> composablePerformer = (id<MDMComposablePerforming>)performer;

    MDMPlanEmitter *emitter = [[MDMPlanEmitter alloc] initWithRuntime:self.runtime target:self.target];
    [composablePerformer setPlanEmitter:emitter];
  }

  // Continuous performance
  if ([performer respondsToSelector:@selector(setIsActiveTokenGenerator:)]) {
    id<MDMContinuousPerforming> continuousPerformer = (id<MDMContinuousPerforming>)performer;

    MDMIsActiveTokenGenerator *generator = [[MDMIsActiveTokenGenerator alloc] initWithDelegate:self.runtime];
    [continuousPerformer setIsActiveTokenGenerator:generator];
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
