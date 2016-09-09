/*
 Copyright 2016 The Material Motion Authors. All Rights Reserved.

 Licensed under the Apache License, Version 2.0 (the "License"); you may not
 use this file except in compliance with the License. You may obtain a copy
 of the License at

 http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 License for the specific language governing permissions and limitations
 under the License.
 */

#import "RuntimeTestTypes.h"
#import <XCTest/XCTest.h>

@implementation TestPerformerA {
  TestState *_targetState;
}

- (instancetype)initWithTarget:(id)target {
  self = [super init];
  if (self) {
    if ([target isMemberOfClass:[TestState class]]) {
      _targetState = target;
    }
  }
  return self;
}

- (void)addPlan:(TestPlanA *)plan {
  _targetState.boolean = plan.desiredBoolean;
}

@end

@implementation TestPerformerB {
  TestState *_targetState;
}

- (instancetype)initWithTarget:(id)target {
  self = [super init];
  if (self) {
    if ([target isMemberOfClass:[TestState class]]) {
      _targetState = target;
    }
  }
  return self;
}

- (void)addPlan:(TestPlanB *)plan {
  _targetState.boolean = plan.desiredBoolean;
}

@end

@implementation TestPerformerSubclass
@end

@implementation TestPlanA

- (Class)performerClass {
  return [TestPerformerA class];
}

@end

@implementation TestPlanB

- (Class)performerClass {
  return [TestPerformerSubclass class];
}

@end

@implementation TestPlanSubclassA
@end

@implementation TestPlanSubclassB

- (Class)performerClass {
  return [TestPerformerA class];
}

@end

@implementation TestState
@end
