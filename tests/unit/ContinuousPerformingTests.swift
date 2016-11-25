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

// Tests related to continuous performers.
class ContinuousPerformingTests: XCTestCase {

  func testContinuousPerformerCausesActivityStateChange() {
    let runtime = MotionRuntime()

    let delegate = ExpectableRuntimeDelegate()
    runtime.delegate = delegate

    runtime.addPlan(InstantlyInactive(), to: NSObject())

    XCTAssertTrue(delegate.activityStateDidChange)
    XCTAssertFalse(runtime.isActive)
  }

  func testForeverActivePerformerCausesActivityStateChange() {
    let runtime = MotionRuntime()

    let delegate = ExpectableRuntimeDelegate()
    runtime.delegate = delegate

    runtime.addPlan(ForeverActive(), to: NSObject())

    XCTAssertTrue(delegate.activityStateDidChange)
    XCTAssertTrue(runtime.isActive)
  }
}
