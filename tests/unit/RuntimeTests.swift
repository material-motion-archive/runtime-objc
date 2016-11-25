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

  // Verify that we're unable to request a delegated performance token after the runtime has been
  // released.
  func testPostDeallocTokenGenerationIsIgnored() {
    var runtime: MotionRuntime? = MotionRuntime()

    let plan = HijackedIsActiveTokenGenerator()
    runtime!.addPlan(plan, to: NSObject())

    // Force the runtime to be deallocated.
    runtime = nil

    XCTAssertNil(plan.state.tokenGenerator!.generate())
  }

  // A plan that enables hijacking of the delegated performance token blocks.
  private class HijackedIsActiveTokenGenerator: NSObject, Plan {
    // We must store the generator in an intermediary "state" object that we can share across plan
    // copies. This breaks the separation of concerns between plans and performers and should not
    // be used in a production setting.
    class State {
      var tokenGenerator: IsActiveTokenGenerating?
    }
    var state = State()

    func performerClass() -> AnyClass {
      return Performer.self
    }

    public func copy(with zone: NSZone? = nil) -> Any {
      let copy = HijackedIsActiveTokenGenerator()
      copy.state = state
      return copy
    }

    private class Performer: NSObject, ContinuousPerforming {
      let target: Any
      required init(target: Any) {
        self.target = target
      }

      func addPlan(_ plan: Plan) {
        let delayedDelegation = plan as! HijackedIsActiveTokenGenerator
        delayedDelegation.state.tokenGenerator = tokenGenerator
      }

      var tokenGenerator: IsActiveTokenGenerating!
      func set(isActiveTokenGenerator: IsActiveTokenGenerating) {
        tokenGenerator = isActiveTokenGenerator
      }
    }
  }
}
