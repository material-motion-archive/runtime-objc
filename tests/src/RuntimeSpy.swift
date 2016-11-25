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

import Foundation
import MaterialMotionRuntime

/**
 A fuzzy representation of a RuntimeTracing event.

 Plans are copied and performers are implementation details, so this event enum allows you to
 describe runtime tracing events in a fuzzy manner.
 */
public enum RuntimeSpyTestEvent {
  /** Equates to any didAddPlan event with a matching plan type and target. */
  case didAddPlan(plan: AnyClass, target: AnyObject)

  /** Equates to any didAddPlan:named event with a matching plan type, name, and target. */
  case didAddPlanNamed(plan: AnyClass, name: String, target: AnyObject)

  /** Equates to any didRemovePlanedNamed event with a matching name and target. */
  case didRemovePlanNamed(name: String, target: AnyObject)

  /** Equates to any didCreatePerformer event with a matching target. */
  case didCreatePerformer(target: AnyObject)
}

/**
 A runtime spy logs the events received by a runtime instance and exposes methods for checking
 the logged events in a fuzzy manner.
 */
public class RuntimeSpy: NSObject {
  var events: [RuntimeSpyEvent] = []

  /**
   Checks for exact equality.

   Use sparingly because new events may start being logged in the future.
   */
  public func isEqual(to: [RuntimeSpyTestEvent]) -> Bool {
    return events == to
  }

  /**
   Returns the number of event instances that match the provided event.

   This is the preferred mechanism a unit test can make use of to validate existance of events.
   */
  public func countOf(_ event: RuntimeSpyTestEvent) -> Int {
    return events.filter { $0 == event }.count
  }
}

extension RuntimeSpy: Tracing {
  public func didAddPlan(_ plan: Plan, to target: Any) {
    events.append(.didAddPlan(plan: plan, target: target))
  }

  public func didAddPlan(_ plan: NamedPlan, named name: String, to target: Any) {
    events.append(.didAddPlanNamed(plan: plan, name: name, target: target))
  }

  public func didRemovePlanNamed(_ name: String, from target: Any) {
    events.append(.didRemovePlanNamed(name: name, target: target))
  }

  public func didCreatePerformer(_ performer: Performing, for target: Any) {
    events.append(.didCreatePerformer(performer: performer, target: target))
  }
}

enum RuntimeSpyEvent {
  case didAddPlan(plan: Plan, target: Any)
  case didAddPlanNamed(plan: NamedPlan, name: String, target: Any)
  case didRemovePlanNamed(name: String, target: Any)
  case didCreatePerformer(performer: Performing, target: Any)
}

// Fuzzy comparator of MotionRuntime Tracing events with their public equivalent.
func ==(lhs: RuntimeSpyEvent, rhs: RuntimeSpyTestEvent) -> Bool {
  switch (lhs, rhs) {
  case (.didAddPlan(let plan1, let target1),
        .didAddPlan(let plan2, let target2))
    where plan1.isMember(of: plan2) && (target1 as AnyObject) === target2:
    return true
  case (.didAddPlanNamed(let plan1, let name1, let target1),
        .didAddPlanNamed(let plan2, let name2, let target2))
    where plan1.isMember(of: plan2) && name1 == name2 && (target1 as AnyObject) === target2:
    return true
  case (.didRemovePlanNamed(let name1, let target1),
        .didRemovePlanNamed(let name2, let target2))
    where name1 == name2 && (target1 as AnyObject) === target2:
    return true
  case (.didCreatePerformer(_, let target1),
        .didCreatePerformer(let target2))
    where (target1 as AnyObject) === target2:
    return true
  default: return false
  }
}

func ==(lhs: [RuntimeSpyEvent], rhs: [RuntimeSpyTestEvent]) -> Bool {
  if lhs.count != rhs.count {
    return false
  }
  for index in 0..<lhs.count {
    if !(lhs[index] == rhs[index]) {
      return false
    }
  }
  return true
}
