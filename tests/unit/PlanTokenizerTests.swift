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

class TokenPoolTests: XCTestCase {

  func testAlwaysSameTokenForSamePlan() {
    let runtime = MotionRuntime()
    runtime.addPlan(TokenFetching(), to: NSObject())
  }

  private class TokenFetching: NSObject, Plan {
    func performerClass() -> AnyClass {
      return Performer.self
    }

    public func copy(with zone: NSZone? = nil) -> Any {
      return TokenFetching()
    }

    private class Performer: NSObject, ContinuousPerforming {
      let target: Any
      required init(target: Any) {
        self.target = target
      }

      func addPlan(_ plan: Plan) {
        let token1 = planTokenizer.token(for: plan)!
        let token2 = planTokenizer.token(for: plan)!
        XCTAssertTrue(token1 === token2)
      }

      var planTokenizer: PlanTokenizing!
      func givePlanTokenizer(_ planTokenizer: PlanTokenizing) {
        self.planTokenizer = planTokenizer
      }
    }
  }

}
