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

/** A plan that will cause a runtime to be active forever. */
public class ForeverActive: NSObject, Plan {
  public func performerClass() -> AnyClass {
    return Performer.self
  }

  public func copy(with zone: NSZone? = nil) -> Any {
    return ForeverActive()
  }

  private class Performer: NSObject, ContinuousPerforming {
    let target: Any
    required init(target: Any) {
      self.target = target
    }

    func addPlan(_ plan: Plan) {
      tokenizer.token(for: plan)?.isActive = true
    }

    var tokenizer: PlanTokenizing!
    func givePlanTokenizer(_ tokenizer: PlanTokenizing) {
      self.tokenizer = tokenizer
    }
  }
}
