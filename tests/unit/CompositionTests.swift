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

// Tests related to the composition of plans.
class CompositionTests: XCTestCase {

  func testComposedDelegationCausesActivityStateChange() {
    let runtime = MotionRuntime()

    let delegate = ExpectableRuntimeDelegate()
    runtime.delegate = delegate

    runtime.addPlan(Emit(plan: InstantlyInactive()), to: NSObject())

    // The following steps are now expected to have occurred:
    //
    // 1. The Emit plan was committed to the runtime.
    // 2. The Emit plan's performer emitted the InstantlyInactive plan.
    // 3. The InstantlyInactive plan changed the runtime's activity state by immediately starting
    //    and completing some delegated work.

    XCTAssertTrue(delegate.activityStateDidChange)
    XCTAssertFalse(runtime.isActive)
  }
}
