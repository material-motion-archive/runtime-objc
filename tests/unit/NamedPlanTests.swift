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

class NamedPlanTests: XCTestCase {

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
    let spy = RuntimeSpy()
    runtime.addTracer(spy)

    runtime.addPlan(firstViewTargetAlteringPlan, named: "name_one", to: target)
    runtime.removePlan(named: "name_one", from: target)

    XCTAssertEqual(spy.countOf(.didCreatePerformer(target: target)), 1)
  }

  func testNamedPlansAdditionsAreCommunicatedViaTracers() {
    let runtime = Runtime()
    let spy = RuntimeSpy()
    runtime.addTracer(spy)

    runtime.addPlan(firstViewTargetAlteringPlan, named: "name_one", to: target)
    runtime.removePlan(named: "name_one", from: target)

    XCTAssertEqual(spy.countOf(.didAddPlanNamed(plan: ViewTargetAltering.self,
                                                name: "name_one",
                                                target: target)), 1)
    XCTAssertEqual(spy.countOf(.didRemovePlanNamed(name: "name_one", target: target)), 1)
  }

  func testNamedPlansRespectTracers() {
    let differentPlan = ChangeBooleanNamedPlan(desiredBoolean:true)
    let state = State()
    let runtime = Runtime()
    let spy = RuntimeSpy()
    runtime.addTracer(spy)

    runtime.addPlan(firstViewTargetAlteringPlan, named: "name_one", to: target)
    runtime.addPlan(differentPlan, named: "name_two", to: state)

    XCTAssertEqual(spy.countOf(.didAddPlanNamed(plan: ViewTargetAltering.self,
                                                name: "name_one",
                                                target: target)), 1)
    XCTAssertEqual(spy.countOf(.didAddPlanNamed(plan: ChangeBooleanNamedPlan.self,
                                                name: "name_two",
                                                target: state)), 1)

    XCTAssert(target.text == "addPlanInvoked")
    XCTAssert(state.boolean)
  }

  func testPerformerCallbacksAreInvokedBeforeTracers() {
    let trackingPlan = RegularPlanTargetAlteringPlan()
    let state = State()
    let runtime = Runtime()
    let spy = RuntimeSpy()
    runtime.addTracer(spy)

    runtime.addPlan(trackingPlan, named: "name_one", to: state)
    runtime.removePlan(named: "name_one", from: state)

    XCTAssert(spy.isEqual(to: [
      .didCreatePerformer(target: state),
      .didAddPlanNamed(plan: RegularPlanTargetAlteringPlan.self, name: "name_one", target: state),
      .didRemovePlanNamed(name: "name_one", target: state),
    ]))
  }

  private class IncrementerTarget: NSObject {
    var addCounter = 0
    var removeCounter = 0
  }

  private class RegularPlanTargetAlteringPlan: NSObject, NamedPlan {

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
