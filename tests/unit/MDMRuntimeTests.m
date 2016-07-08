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

#import <XCTest/XCTest.h>
@import MaterialMotionRuntime;

@interface TestState : NSObject
@property(nonatomic) bool boolean;
@end

@interface TestPlan : NSObject <MDMPlan>
@property(nonatomic) bool desiredBoolean;
@end

@interface TestPerformer : NSObject <MDMPlanPerforming>
@end

@interface MDMRuntimeTests : XCTestCase
@end

@implementation MDMRuntimeTests

- (void)testLifeOfAPlan {
  TestState *state = [TestState new];
  state.boolean = false;

  TestPlan *plan = [TestPlan new];
  plan.desiredBoolean = true;

  MDMTransaction *transaction = [MDMTransaction new];
  [transaction addPlan:plan toTarget:state];

  MDMScheduler *scheduler = [MDMScheduler new];
  [scheduler commitTransaction:transaction];

  XCTAssertEqual(state.boolean, plan.desiredBoolean);
}

@end

@implementation TestPlan

- (Class)performerClass {
  return [TestPerformer class];
}

@end

@implementation TestPerformer {
  TestState *_targetState;
}

- (instancetype)initWithTarget:(id)target {
  self = [super init];
  if (self) {
    _targetState = target;
  }
  return self;
}

- (void)addPlan:(TestPlan *)plan {
  _targetState.boolean = plan.desiredBoolean;
}

@end

@implementation TestState
@end
