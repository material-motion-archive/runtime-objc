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
import MaterialMotionRuntime

class DelegatedPerformanceTests: XCTestCase {

  func testDelegatedPerformanceCausesActivityStateChange() {
    let transaction = MDMTransaction()
    transaction.add(DelegatedPlan(), toTarget: NSObject())

    let scheduler = MDMScheduler()
    let delegate = TestSchedulerDelegate()
    scheduler.delegate = delegate

    scheduler.commit(transaction)

    XCTAssertTrue(delegate.activityStateDidChange)
    XCTAssertTrue(scheduler.activityState == .idle)
  }
}

@objc class DelegatedPlan: NSObject, MDMPlan {
  func performerClass() -> AnyClass {
    return DelegatedPerformer.self
  }
}

@objc class DelegatedPerformer: NSObject, MDMPlanPerforming, MDMDelegatedPerforming {
  let target: AnyObject
  var willStart: MDMDelegatedPerformanceTokenReturnBlock!
  var didEnd: MDMDelegatedPerformanceTokenArgBlock!

  required init(target: AnyObject) {
    self.target = target
  }

  func add(_ plan: MDMPlan) {
    let token = self.willStart()!
    self.didEnd(token)
  }

  func setDelegatedPerformanceWillStart(_ willStart: MDMDelegatedPerformanceTokenReturnBlock, didEnd: MDMDelegatedPerformanceTokenArgBlock) {
    self.willStart = willStart
    self.didEnd = didEnd
  }
}
