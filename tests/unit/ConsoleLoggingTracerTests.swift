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

class ConsoleLoggingTracerTests: XCTestCase {

  var logPath:String!
  var logFile:UnsafeMutablePointer<FILE>!
  var target:UIView!
  var firstRegularPlan:InstantlyContinuous!
  var firstNamedPlan:ViewTargetAltering!
  var secondNamedPlan:ViewTargetAltering!
  var scheduler:Scheduler!
  var tracer:ConsoleLoggingTracer!

  override func setUp() {
    super.setUp()
    let allPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = allPaths.first!
    logPath = documentsDirectory + "/unit_test_output.log"
    // delete any existing files - start with a clean slate
    let fileManager = FileManager.default
    do {
      try fileManager.removeItem(atPath: logPath)
    } catch let error as NSError {
      print(error.debugDescription)
    }
    // re-open the file for writing
    logFile = freopen(logPath.cString(using: String.Encoding.utf8)!, "a+", stderr)
    target = UIView()
    // instantiate a few variables which are used throughout testing
    firstRegularPlan = InstantlyContinuous()
    firstNamedPlan = ViewTargetAltering()
    secondNamedPlan = ViewTargetAltering()
    scheduler = Scheduler()
    tracer = ConsoleLoggingTracer()
  }

  override func tearDown() {
    super.tearDown()
    fflush(logFile);
    fclose(logFile);
  }

  func testInvokingMethodsDirectlyOnConsoleLoggingTracer() {
    tracer.didAddPlan(firstRegularPlan, to: target)
    tracer.didAddPlan(firstRegularPlan, to: NSObject())
    tracer.didAddPlan(firstRegularPlan, to: CALayer())
    tracer.didAddPlan(firstRegularPlan, to: "")
    tracer.didAddPlan(firstRegularPlan, to: "🐶")
    tracer.didAddPlan(firstRegularPlan, to: "nil")
    tracer.didAddPlan(firstRegularPlan, to: "NULL")
    tracer.didAddPlan(firstRegularPlan, to: NSNull())
    tracer.didAddPlan(firstRegularPlan, to: [NSNull(), NSNull()])
    tracer.didAddPlan(firstRegularPlan, to: [])
    tracer.didAddPlan(firstRegularPlan, to: [String:String]())
    tracer.didAddPlan(firstRegularPlan, to: UIViewController())
    tracer.didAddPlan(firstRegularPlan, to: -1)
    tracer.didAddPlan(firstRegularPlan, to: 0)
    tracer.didAddPlan(firstRegularPlan, to: 1)
    tracer.didAddPlan(firstRegularPlan, to: 123)
    tracer.didAddPlan(firstRegularPlan, to: 123.321)
    tracer.didAddPlan(firstRegularPlan, to: Int.max)
    tracer.didAddPlan(firstRegularPlan, to: Int.min)
    tracer.didAddPlan(firstRegularPlan, to: UInt.max)
    tracer.didAddPlan(firstRegularPlan, to: UInt.min)
  }

  func testEmojiCharactersInTheTracers() {
    scheduler.addTracer(tracer)

    scheduler.addPlan(firstNamedPlan, named: "🐶", to: target)
    scheduler.addPlan(secondNamedPlan, named: "🐱", to: target)
    scheduler.removePlan(named: "🐱", from: target)

    do {
      let text = try String(contentsOfFile: logPath, encoding: String.Encoding.utf8)
      // adding the first named plan
      XCTAssert(text.contains("named: 🐶"))
      // adding the second named plan
      XCTAssert(text.contains("named: 🐱"))
    } catch let e {
      dump(e)
      // fail the unit test immediately if an exception is thrown from simply reading the file
      XCTAssert(1 == 0)
    }
  }

  func testPlanOperationsRespectLoggingTracer() {
    scheduler.addTracer(tracer)

    scheduler.addPlan(firstRegularPlan, to: target)
    scheduler.addPlan(firstNamedPlan, named: "name_one", to: target)
    scheduler.addPlan(secondNamedPlan, named: "name_two", to: target)
    scheduler.removePlan(named: "name_one", from: target)

    do {
      let text = try String(contentsOfFile: logPath, encoding: String.Encoding.utf8)
      // adding the first regular plan
      XCTAssert(text.contains("didAddPlan:"))
      // adding the first named plan
      XCTAssert(text.contains("named: name_one"))
      // adding the second named plan
      XCTAssert(text.contains("named: name_two"))
      // removing the first named plan
      XCTAssert(text.contains("didRemovePlanNamed:"))
      // a performer was created while running this unit test
      XCTAssert(text.contains("didCreatePerformer:"))
    } catch let e {
      dump(e)
      // fail the unit test immediately if an exception is thrown from simply reading the file
      XCTAssert(1 == 0)
    }
  }
}
