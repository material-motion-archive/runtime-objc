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

import XCTest
import MaterialMotionRuntime

class SchedulerTests: XCTestCase {

  // Verify that a plan committed to a scheduler immediately executes its add(plan:) logic.
  func testAddPlanInvokedImmediately() {
    let state = State()
    state.boolean = false

    let plan = ChangeBoolean(desiredBoolean: true)

    let scheduler = Scheduler()

    let transaction = Transaction()
    transaction.add(plan: plan, to: state)
    scheduler.commit(transaction: transaction)

    XCTAssertEqual(state.boolean, plan.desiredBoolean)
  }

  // Simple instantiable target with a mutable boolean property.
  private class State {
    var boolean = false
  }

  private class ChangeBoolean: NSObject, Plan {
    var desiredBoolean: Bool

    init(desiredBoolean: Bool) {
      self.desiredBoolean = desiredBoolean
    }

    func performerClass() -> AnyClass {
      return Performer.self
    }

    private class Performer: NSObject, Performing, PlanPerforming {
      let target: State
      required init(target: Any) {
        self.target = target as! State
      }

      func add(plan: Plan) {
        let testPlan = plan as! ChangeBoolean
        target.boolean = testPlan.desiredBoolean
      }
    }
  }

  // Verify that two plans of the same type creates only one performer.
  func testTwoSamePlansCreatesOnePerformer() {
    let state = State()
    state.boolean = false

    let scheduler = Scheduler()

    expectation(forNotification: EventName.performersCreated._rawValue as String, object: scheduler) { notification -> Bool in
      let event = notification.userInfo![EventNotificationEventKey] as! SchedulerPerformersCreatedEvent
      return event.createdPerformers.count == 1
    }

    let transaction = Transaction()
    transaction.add(plan: ChangeBoolean(desiredBoolean: true), to: state)
    transaction.add(plan: ChangeBoolean(desiredBoolean: false), to: state)
    scheduler.commit(transaction: transaction)

    waitForExpectations(timeout: 0.1)
  }

  // Verify that two plans of different types creates two performers.
  func testTwoDifferentPlansCreatesTwoPerformers() {
    let state = State()
    state.boolean = false

    let scheduler = Scheduler()

    expectation(forNotification: EventName.performersCreated._rawValue as String, object: scheduler) { notification -> Bool in
      let event = notification.userInfo![EventNotificationEventKey] as! SchedulerPerformersCreatedEvent
      return event.createdPerformers.count == 2
    }

    let transaction = Transaction()
    transaction.add(plan: ChangeBoolean(desiredBoolean: true), to: state)
    transaction.add(plan: NoopDelegation(), to: state)
    scheduler.commit(transaction: transaction)

    waitForExpectations(timeout: 0.1)
  }

  // Verify that order of plans is respected in a transaction.
  func testTwoPlansOrderIsRespected() {
    let state = State()
    state.boolean = false

    let scheduler = Scheduler()

    var transaction = Transaction()
    transaction.add(plan: ChangeBoolean(desiredBoolean: true), to: state)
    transaction.add(plan: ChangeBoolean(desiredBoolean: false), to: state)
    scheduler.commit(transaction: transaction)

    XCTAssertEqual(state.boolean, false)

    transaction = Transaction()
    transaction.add(plan: ChangeBoolean(desiredBoolean: false), to: state)
    transaction.add(plan: ChangeBoolean(desiredBoolean: true), to: state)
    scheduler.commit(transaction: transaction)

    XCTAssertEqual(state.boolean, true)
  }

  // Verify that we're unable to request a delegated performance token after the scheduler has been
  // released.
  func testDelayedDelegationIsIgnored() {
    var scheduler: Scheduler? = Scheduler()

    let transaction = Transaction()
    let plan = HijackedDelegation()
    transaction.add(plan: plan, to: NSObject())
    scheduler!.commit(transaction: transaction)

    // Force the scheduler to be deallocated.
    scheduler = nil

    XCTAssertNil(plan.willStart!())
    plan.didEnd!(FakeToken()) // Should silently succeed because scheduler is gone
  }

  // A fake token for use in tests.
  private class FakeToken: NSObject, DelegatedPerformingToken {}

  // A plan that enables hijacking of the delegated performance token blocks.
  private class HijackedDelegation: NSObject, Plan {
    var willStart: DelegatedPerformanceTokenReturnBlock?
    var didEnd: DelegatedPerformanceTokenArgBlock?

    func performerClass() -> AnyClass {
      return Performer.self
    }

    private class Performer: NSObject, PlanPerforming, DelegatedPerforming {
      let target: Any
      required init(target: Any) {
        self.target = target
      }

      func add(plan: Plan) {
        let delayedDelegation = plan as! HijackedDelegation
        delayedDelegation.willStart = willStart
        delayedDelegation.didEnd = didEnd
      }

      var willStart: DelegatedPerformanceTokenReturnBlock!
      var didEnd: DelegatedPerformanceTokenArgBlock!
      func setDelegatedPerformance(willStart: @escaping DelegatedPerformanceTokenReturnBlock,
                                   didEnd: @escaping DelegatedPerformanceTokenArgBlock) {
        self.willStart = willStart
        self.didEnd = didEnd
      }
    }
  }
}
