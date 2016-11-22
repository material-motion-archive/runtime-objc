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

class RuntimeTests: XCTestCase {

  var target:UITextView!
  private var incrementerTarget:IncrementerTarget!
  var firstViewTargetAlteringPlan:NamedPlan!

  override func setUp() {
    super.setUp()
    target = UITextView()
    incrementerTarget = IncrementerTarget()
    firstViewTargetAlteringPlan = ViewTargetAltering()
    target.text = ""
  }

  // Verify that a plan committed to a runtime is copied.
  func testPlansAreCopied() {
    let state = State()
    state.boolean = false

    let plan = ChangeBoolean(desiredBoolean: true)

    let runtime = Runtime()
    let tracer = StorageTracer()
    runtime.addTracer(tracer)

    runtime.addPlan(plan, to: state)

    XCTAssertEqual(tracer.addedPlans.count, 1)
    XCTAssertNotEqual(tracer.addedPlans[0] as! ChangeBoolean, plan)
  }

  // Verify that a plan committed to a runtime immediately executes its add(plan:) logic.
  func testAddPlanInvokedImmediately() {
    let state = State()
    state.boolean = false

    let plan = ChangeBoolean(desiredBoolean: true)

    let runtime = Runtime()
    runtime.addPlan(plan, to: state)

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

  private class ChangeBooleanNamedPlan: NSObject, NamedPlan {
    var desiredBoolean: Bool

    init(desiredBoolean: Bool) {
      self.desiredBoolean = desiredBoolean
    }

    func performerClass() -> AnyClass {
      return Performer.self
    }

    public func copy(with zone: NSZone? = nil) -> Any {
      return ChangeBooleanNamedPlan(desiredBoolean: desiredBoolean)
    }

    private class Performer: NSObject, Performing, NamedPlanPerforming {
      let target: State
      required init(target: Any) {
        self.target = target as! State
      }

      public func addPlan(_ plan: Plan) {
        // No-op
      }

      func addPlan(_ plan: NamedPlan, named name: String) {
        let testPlan = plan as! ChangeBooleanNamedPlan
        target.boolean = testPlan.desiredBoolean
      }

      func removePlan(named name: String) {

      }
    }
  }

  // Verify that two plans of the same type creates only one performer.
  func testTwoSamePlansCreatesOnePerformer() {
    let state = State()
    state.boolean = false

    let runtime = Runtime()
    let tracer = StorageTracer()
    runtime.addTracer(tracer)

    runtime.addPlan(ChangeBoolean(desiredBoolean: true), to: state)
    runtime.addPlan(ChangeBoolean(desiredBoolean: false), to: state)

    XCTAssertEqual(tracer.createdPerformers.count, 1)
  }

  // Verify that two plans of different types creates two performers.
  func testTwoDifferentPlansCreatesTwoPerformers() {
    let state = State()
    state.boolean = false

    let runtime = Runtime()
    let tracer = StorageTracer()
    runtime.addTracer(tracer)

    runtime.addPlan(ChangeBoolean(desiredBoolean: true), to: state)
    runtime.addPlan(InstantlyContinuous(), to: state)

    XCTAssertEqual(tracer.createdPerformers.count, 2)
  }

  // Verify that order of plans is respected in a runtime.
  func testTwoPlansOrderIsRespected() {
    let state = State()
    state.boolean = false

    let runtime = Runtime()

    runtime.addPlan(ChangeBoolean(desiredBoolean: true), to: state)
    runtime.addPlan(ChangeBoolean(desiredBoolean: false), to: state)

    XCTAssertEqual(state.boolean, false)

    runtime.addPlan(ChangeBoolean(desiredBoolean: false), to: state)
    runtime.addPlan(ChangeBoolean(desiredBoolean: true), to: state)

    XCTAssertEqual(state.boolean, true)
  }

  // Verify that we're unable to request a delegated performance token after the runtime has been
  // released.
  func testPostDeallocTokenGenerationIsIgnored() {
    var runtime: Runtime? = Runtime()

    let plan = HijackedIsActiveTokenGenerator()
    runtime!.addPlan(plan, to: NSObject())

    // Force the runtime to be deallocated.
    runtime = nil

    XCTAssertNil(plan.state.tokenGenerator!.generate())
  }

  func testAddingNamedPlan() {
    let runtime = Runtime()

    runtime.addPlan(firstViewTargetAlteringPlan, named: "common_name", to: target)

    XCTAssertTrue(target.text! == "addPlanInvoked")
  }

  func testAddAndRemoveTheSameNamedPlan() {
    let runtime = Runtime()

    runtime.addPlan(firstViewTargetAlteringPlan, named: "name_one", to: target)
    runtime.removePlan(named: "name_one", from: target)

    XCTAssertTrue(target.text! == "addPlanInvokedremovePlanInvoked")
  }

  func testRemoveNamedPlanThatIsntThere() {
    let runtime = Runtime()

    runtime.addPlan(firstViewTargetAlteringPlan, named: "common_name", to: target)
    runtime.removePlan(named: "was_never_added_plan", from: target)

    XCTAssertTrue(target.text! == "addPlanInvoked")
  }

  func testNamedPlansOverwiteOneAnother() {
    let runtime = Runtime()
    let planA = IncrementerTargetPlan()
    let planB = IncrementerTargetPlan()
    runtime.addPlan(planA, named: "common_name", to: incrementerTarget)
    runtime.addPlan(planB, named: "common_name", to: incrementerTarget)

    XCTAssertTrue(incrementerTarget.addCounter == 2)
    XCTAssertTrue(incrementerTarget.removeCounter == 1)
  }

  func testNamedPlansMakeAddAndRemoveCallbacks() {
    let runtime = Runtime()
    let plan = ViewTargetAltering()
    runtime.addPlan(plan, named: "one_name", to: target)
    runtime.removePlan(named: "one_name", from: target)
    runtime.addPlan(plan, named: "two_name", to: target)

    XCTAssertTrue(target.text! == "addPlanInvokedremovePlanInvokedaddPlanInvoked")
  }

  func testAddingTheSameNamedPlanTwiceToTheSameTarget() {
    let runtime = Runtime()
    let plan = IncrementerTargetPlan()
    runtime.addPlan(plan, named: "one", to: incrementerTarget)
    runtime.addPlan(plan, named: "one", to: incrementerTarget)

    XCTAssertTrue(incrementerTarget.addCounter == 2)
    XCTAssertTrue(incrementerTarget.removeCounter == 1)
  }

  func testAddingTheSamePlanWithSimilarNamesToTheSameTarget() {
    let runtime = Runtime()
    let firstPlan = IncrementerTargetPlan()
    runtime.addPlan(firstPlan, named: "one", to: incrementerTarget)
    runtime.addPlan(firstPlan, named: "One", to: incrementerTarget)
    runtime.addPlan(firstPlan, named: "1", to: incrementerTarget)
    runtime.addPlan(firstPlan, named: "ONE", to: incrementerTarget)

    XCTAssertTrue(incrementerTarget.addCounter == 4)
    XCTAssertTrue(incrementerTarget.removeCounter == 0)
  }

  func testAddingTheSameNamedPlanToDifferentTargets() {
    let runtime = Runtime()
    let firstPlan = IncrementerTargetPlan()
    let secondIncrementerTarget = IncrementerTarget()
    runtime.addPlan(firstPlan, named: "one", to: incrementerTarget)
    runtime.addPlan(firstPlan, named: "one", to: secondIncrementerTarget)

    XCTAssertTrue(incrementerTarget.addCounter == 1)
    XCTAssertTrue(incrementerTarget.removeCounter == 0)
    XCTAssertTrue(secondIncrementerTarget.addCounter == 1)
    XCTAssertTrue(secondIncrementerTarget.removeCounter == 0)
  }

  func testNamedPlanOnlyInvokesNamedCallbacks() {
    let runtime = Runtime()
    let plan = ViewTargetAltering()
    runtime.addPlan(plan, named: "one_name", to: target)

    XCTAssertTrue(target.text!.range(of: "addInvoked") == nil)
  }

  func testPlanOnlyInvokesPlanCallbacks() {
    let runtime = Runtime()
    let plan = RegularPlanTargetAlteringPlan()
    runtime.addPlan(plan, to: target)

    XCTAssertTrue(target.text!.range(of: "addPlanInvoked") == nil)
    XCTAssertTrue(target.text!.range(of: "removePlanInvoked") == nil)
  }

  func testNamedPlansReusePerformers() {
    let runtime = Runtime()
    let tracer = StorageTracer()
    runtime.addTracer(tracer)

    runtime.addPlan(firstViewTargetAlteringPlan, named: "name_one", to: target)
    runtime.removePlan(named: "name_one", from: target)

    XCTAssertEqual(tracer.createdPerformers.count, 1)
  }

  func testNamedPlansAdditionsAreCommunicatedViaTracers() {
    let runtime = Runtime()
    let tracer = StorageTracer()
    runtime.addTracer(tracer)

    runtime.addPlan(firstViewTargetAlteringPlan, named: "name_one", to: target)
    runtime.removePlan(named: "name_one", from: target)

    XCTAssertEqual(tracer.addedNamedPlans.count, 1)
    XCTAssertEqual(tracer.removedPlanNames.count, 1)
    XCTAssertTrue(tracer.removedPlanNames[0] == "name_one")
  }

  func testNamedPlansRespectTracers() {
    let differentPlan = ChangeBooleanNamedPlan(desiredBoolean:true)
    let state = State()
    let runtime = Runtime()
    let tracer = StorageTracer()
    runtime.addTracer(tracer)

    runtime.addPlan(firstViewTargetAlteringPlan, named: "name_one", to: target)
    runtime.addPlan(differentPlan, named: "name_two", to: state)

    XCTAssertEqual(tracer.addedNamedPlans.count, 2)

    XCTAssert(target.text == "addPlanInvoked")
    XCTAssert(state.boolean)
  }

  func testPerformerCallbacksAreInvokedBeforeTracers() {
    let trackingPlan = TrackingPlan()
    let runtime = Runtime()
    let tracer = TrackingTracer()
    runtime.addTracer(tracer)

    runtime.addPlan(trackingPlan, named: "name_one", to: tracer)
    runtime.removePlan(named: "name_one", from: tracer)

    XCTAssertTrue(tracer.events == ["addPlan", "didAddPlanNamed", "removePlan", "didRemovePlanNamed"])
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

  private class IncrementerTarget: NSObject {
    var addCounter = 0
    var removeCounter = 0
  }

  private class RegularPlanTargetAlteringPlan: NSObject, Plan {

    func performerClass() -> AnyClass {
      return Performer.self
    }

    public func copy(with zone: NSZone? = nil) -> Any {
      return RegularPlanTargetAlteringPlan()
    }

    private class Performer: NSObject, NamedPlanPerforming {
      let target: Any
      required init(target: Any) {
        self.target = target
      }

      func addPlan(_ plan: Plan) {
        if let unwrappedTarget = self.target as? UITextView {
          unwrappedTarget.text = unwrappedTarget.text + "addInvoked"
        }
      }

      func addPlan(_ plan: NamedPlan, named name: String) {
        if let unwrappedTarget = self.target as? UITextView {
          unwrappedTarget.text = unwrappedTarget.text + "addPlanInvoked"
        }
      }

      func removePlan(named name: String) {
        if let unwrappedTarget = self.target as? UITextView {
          unwrappedTarget.text = unwrappedTarget.text + "removePlanInvoked"
        }
      }
    }
  }

  private class TrackingTracer: NSObject, Tracing {
    var events: [String] = [];

    func didAddPlan(_ plan: NamedPlan, named name: String, to target: Any) {
      events.append("didAddPlanNamed")
    }

    func didRemovePlanNamed(_ name: String, from target: Any) {
      events.append("didRemovePlanNamed")
    }
  }

  private class TrackingPlan: NSObject, NamedPlan {

    func performerClass() -> AnyClass {
      return Performer.self
    }

    public func copy(with zone: NSZone? = nil) -> Any {
      return TrackingPlan()
    }

    private class Performer: NSObject, NamedPlanPerforming {
      let target: Any
      required init(target: Any) {
        self.target = target
      }

      func addPlan(_ plan: NamedPlan, named name: String) {
        if let unwrappedTracer = self.target as? TrackingTracer {
          unwrappedTracer.events.append("addPlan")
        }
      }

      func removePlan(named name: String) {
        if let unwrappedTracer = self.target as? TrackingTracer {
          unwrappedTracer.events.append("removePlan")
        }
      }
    }
  }

  private class IncrementerTargetPlan: NSObject, NamedPlan {

    func performerClass() -> AnyClass {
      return Performer.self
    }

    public func copy(with zone: NSZone? = nil) -> Any {
      return IncrementerTargetPlan()
    }

    private class Performer: NSObject, NamedPlanPerforming {
      let target: Any
      required init(target: Any) {
        self.target = target
      }

      public func addPlan(_ plan: Plan) {
        // No-op
      }

      func addPlan(_ plan: NamedPlan, named name: String) {
        if let unwrappedTarget = self.target as? IncrementerTarget {
          unwrappedTarget.addCounter = unwrappedTarget.addCounter + 1
        }
      }

      func removePlan(named name: String) {
        if let unwrappedTarget = self.target as? IncrementerTarget {
          unwrappedTarget.removeCounter = unwrappedTarget.removeCounter + 1
        }
      }
    }
  }
}
