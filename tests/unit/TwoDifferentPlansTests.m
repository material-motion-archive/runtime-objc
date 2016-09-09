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

#import <XCTest/XCTest.h>
#import "RuntimeTestTypes.h"

#import <MaterialMotionRuntime/private/MDMPerformerGroup.h>

@import MaterialMotionRuntime;

@interface TwoPerformersTests : XCTestCase
@end

@implementation TwoPerformersTests

- (void)testDifferentPlansDifferentPerformers {
  TestState *state = [TestState new];
  state.boolean = false;

  TestPlanA *planA = [TestPlanA new];
  planA.desiredBoolean = true;

  TestPlanB *planB = [TestPlanB new];
  planB.desiredBoolean = true;

  MDMTransaction *transaction = [MDMTransaction new];
  [transaction addPlan:planA toTarget:state];
  [transaction addPlan:planB toTarget:state];

  MDMScheduler *scheduler = [MDMScheduler new];
  [scheduler commitTransaction:transaction];

  XCTAssertEqual(state.boolean, planA.desiredBoolean);
  XCTAssertEqual(state.boolean, planB.desiredBoolean);
}

- (void)testDifferentPlansPerformersTransactions {
  TestState *state = [TestState new];
  TestPlanA *planA = [TestPlanA new];
  TestPlanB *planB = [TestPlanB new];

  MDMTransaction *transactionA = [MDMTransaction new];
  [transactionA addPlan:planA toTarget:state];

  MDMTransaction *transactionB = [MDMTransaction new];
  [transactionB addPlan:planB toTarget:state];

  MDMScheduler *scheduler = [MDMScheduler new];

  __block MDMSchedulerExecutionPerformersCreatedEvent *eventA;
  __block id<NSObject> observer = [[NSNotificationCenter defaultCenter] addObserverForName:MDMEventIdentifierPerformersCreated
                                                                                    object:nil
                                                                                     queue:[NSOperationQueue currentQueue]
                                                                                usingBlock:^(NSNotification *_Nonnull note) {
                                                                                  eventA = note.userInfo[MDMEventNotificationKeyEvent];
                                                                                  XCTAssertTrue([eventA isMemberOfClass:[MDMSchedulerExecutionPerformersCreatedEvent class]]);

                                                                                  [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                                                }];
  [scheduler commitTransaction:transactionA];

  observer = [[NSNotificationCenter defaultCenter] addObserverForName:MDMEventIdentifierPerformersCreated
                                                               object:nil
                                                                queue:[NSOperationQueue currentQueue]
                                                           usingBlock:^(NSNotification *_Nonnull note) {
                                                             MDMSchedulerExecutionPerformersCreatedEvent *event = note.userInfo[MDMEventNotificationKeyEvent];
                                                             XCTAssertTrue([event isMemberOfClass:[MDMSchedulerExecutionPerformersCreatedEvent class]]);

                                                             XCTAssertFalse([event.performers.firstObject isMemberOfClass:[eventA.performers.firstObject class]]);

                                                             [[NSNotificationCenter defaultCenter] removeObserver:observer];
                                                           }];
  [scheduler commitTransaction:transactionB];
}

- (void)testDifferentPlansPerformersTargets {
  TestState *stateA = [TestState new];
  stateA.boolean = false;

  TestState *stateB = [TestState new];
  stateB.boolean = false;

  TestPlanA *planA = [TestPlanA new];
  planA.desiredBoolean = true;

  TestPlanB *planB = [TestPlanB new];
  planB.desiredBoolean = true;

  MDMTransaction *transaction = [MDMTransaction new];
  [transaction addPlan:planA toTarget:stateA];
  [transaction addPlan:planB toTarget:stateB];

  MDMScheduler *scheduler = [MDMScheduler new];
  [scheduler commitTransaction:transaction];

  XCTAssertEqual(stateA.boolean, planA.desiredBoolean);
  XCTAssertEqual(stateB.boolean, planB.desiredBoolean);
}

- (void)testDifferentPlansPerformersViaSubclass {
  TestState *state = [TestState new];
  state.boolean = false;

  TestPlanSubclassA *planSubclassA = [TestPlanSubclassA new];
  planSubclassA.desiredBoolean = true;

  TestPlanSubclassB *planSubclassB = [TestPlanSubclassB new];
  planSubclassB.desiredBoolean = true;

  MDMTransaction *transaction = [MDMTransaction new];
  [transaction addPlan:planSubclassA toTarget:state];
  [transaction addPlan:planSubclassB toTarget:state];

  MDMScheduler *scheduler = [MDMScheduler new];
  [scheduler commitTransaction:transaction];

  XCTAssertEqual(state.boolean, planSubclassA.desiredBoolean);
  XCTAssertEqual(state.boolean, planSubclassB.desiredBoolean);

  XCTAssert([planSubclassA isKindOfClass:[TestPlanA class]]);
  XCTAssertFalse([planSubclassA isMemberOfClass:[TestPlanA class]]);
}

@end
