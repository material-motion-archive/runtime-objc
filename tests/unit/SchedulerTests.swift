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

    let transaction = Transaction()
    transaction.add(plan: plan, to: state)

    let scheduler = Scheduler()
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
}
