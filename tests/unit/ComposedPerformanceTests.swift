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

class ComposedPerformanceTests: XCTestCase {

  func testCausesActivityStateChange() {
    let transaction = Transaction()
    transaction.add(plan: RootPlan(), to: NSObject())

    let scheduler = Scheduler()
    let delegate = TestSchedulerDelegate()
    scheduler.delegate = delegate

    scheduler.commit(transaction: transaction)

    XCTAssertTrue(delegate.activityStateDidChange)
    XCTAssertTrue(scheduler.activityState == .idle)
  }
}

class RootPlan: NSObject, Plan {
  func performerClass() -> AnyClass {
    return ComposingPerformer.self
  }
}

class LeafPlan: NSObject, Plan {
  func performerClass() -> AnyClass {
    return LeafPerformer.self
  }
}

class ComposingPerformer: NSObject, PlanPerforming, ComposablePerforming {
  let target: Any
  var emitter: TransactionEmitting!

  required init(target: Any) {
    self.target = target
  }

  func add(plan: Plan) {
    let transaction = Transaction()
    transaction.add(plan: LeafPlan(), to: self.target)
    self.emitter.emit(transaction: transaction)
  }

  func set(transactionEmitter: TransactionEmitting) {
    self.emitter = transactionEmitter
  }
}

class LeafPerformer: NSObject, PlanPerforming, DelegatedPerforming {
  let target: Any
  var willStart: DelegatedPerformanceTokenReturnBlock!
  var didEnd: DelegatedPerformanceTokenArgBlock!

  required init(target: Any) {
    self.target = target
  }

  func add(plan: Plan) {
    let token = self.willStart()!
    self.didEnd(token)
  }

  func setDelegatedPerformance(willStart: @escaping DelegatedPerformanceTokenReturnBlock,
                               didEnd: @escaping DelegatedPerformanceTokenArgBlock) {
    self.willStart = willStart
    self.didEnd = didEnd
  }
}
