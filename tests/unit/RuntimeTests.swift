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
import Foundation
import MaterialMotionRuntime

// Simple instantiable target with a mutable boolean property.
class State {
  var boolean = false
}

class RuntimeTests: XCTestCase {

  // Verify that a plan committed to a runtime is copied.
  func testPlansAreCopied() {
    let state = State()
    state.boolean = false

    let plan = ChangeBoolean(desiredBoolean: true)

    let runtime = MotionRuntime()
    let spy = RuntimeSpy()
    runtime.addTracer(spy)

    runtime.addPlan(plan, to: state)

    XCTAssertEqual(spy.countOf(.didAddPlan(plan: ChangeBoolean.self, target: state)), 1)
  }

  // Verify that a plan committed to a runtime immediately executes its add(plan:) logic.
  func testAddPlanInvokedImmediately() {
    let state = State()
    state.boolean = false

    let plan = ChangeBoolean(desiredBoolean: true)

    let runtime = MotionRuntime()
    runtime.addPlan(plan, to: state)

    XCTAssertEqual(state.boolean, plan.desiredBoolean)
  }

  private class ChangeBoolean: NSObject, Plan {
    var desiredBoolean: Bool

    init(desiredBoolean: Bool) {
      self.desiredBoolean = desiredBoolean
    }

    func performerClass() -> AnyClass {
      return Performer.self
    }

    public func copy(with zone: NSZone? = nil) -> Any {
      return ChangeBoolean(desiredBoolean: desiredBoolean)
    }

    private class Performer: NSObject, Performing {
      let target: State
      required init(target: Any) {
        self.target = target as! State
      }

      func addPlan(_ plan: Plan) {
        let testPlan = plan as! ChangeBoolean
        target.boolean = testPlan.desiredBoolean
      }
    }
  }

  // Verify that two plans of the same type creates only one performer.
  func testTwoSamePlansCreatesOnePerformer() {
    let state = State()
    state.boolean = false

    let runtime = MotionRuntime()
    let spy = RuntimeSpy()
    runtime.addTracer(spy)

    runtime.addPlans([ChangeBoolean(desiredBoolean: true),
                      ChangeBoolean(desiredBoolean: false)], to: state)

    XCTAssertEqual(spy.countOf(.didCreatePerformer(target: state)), 1)
  }

  // Verify that two plans of different types creates two performers.
  func testTwoDifferentPlansCreatesTwoPerformers() {
    let state = State()
    state.boolean = false

    let runtime = MotionRuntime()
    let spy = RuntimeSpy()
    runtime.addTracer(spy)

    runtime.addPlans([ChangeBoolean(desiredBoolean: true),
                      InstantlyInactive()], to: state)

    XCTAssertEqual(spy.countOf(.didCreatePerformer(target: state)), 2)
  }

  // Verify that order of plans is respected in a runtime.
  func testTwoPlansOrderIsRespected() {
    let state = State()
    state.boolean = false

    let runtime = MotionRuntime()

    runtime.addPlans([ChangeBoolean(desiredBoolean: true),
                      ChangeBoolean(desiredBoolean: false)], to: state)

    XCTAssertEqual(state.boolean, false)

    runtime.addPlans([ChangeBoolean(desiredBoolean: false),
                      ChangeBoolean(desiredBoolean: true)], to: state)

    XCTAssertEqual(state.boolean, true)
  }

  func testRuntimeIsDeallocatedWhenNotReferenced() {
    var runtime: MotionRuntime? = MotionRuntime()
    weak var weakRuntime: MotionRuntime? = runtime

    autoreleasepool {
      runtime!.addPlan(InstantlyInactive(), to: NSObject())

      // Remove our only strong reference to the runtime.
      runtime = nil
    }

    // If this fails it means there's a retain cycle within the runtime somewhere. Place a
    // breakpoint here and use the Debug Memory Graph tool to debug.
    XCTAssertNil(weakRuntime)
  }
}
