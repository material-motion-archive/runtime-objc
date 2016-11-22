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

/** A plan that emits an arbitrary plan. */
public class Emit: NSObject, Plan {
  public var plan: Plan
  public init(plan: Plan) {
    self.plan = plan
  }

  public func performerClass() -> AnyClass {
    return Performer.self
  }

  public func copy(with zone: NSZone? = nil) -> Any {
    return Emit(plan: plan)
  }

  private class Performer: NSObject, ComposablePerforming {
    let target: Any
    required init(target: Any) {
      self.target = target
    }

    func addPlan(_ plan: Plan) {
      let emit = plan as! Emit
      emitter.emitPlan(emit.plan)
    }

    var emitter: PlanEmitting!
    func setPlanEmitter(_ planEmitter: PlanEmitting) {
      emitter = planEmitter
    }
  }
}
