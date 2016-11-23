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

class TimelineTests: XCTestCase {

  func testScrubberAttachementSendsEvents() {
    let timeline = Timeline()

    let spy = TimelineSpy()
    timeline.addObserver(spy)

    timeline.attachScrubber(withTimeOffset: 0)
    timeline.detachScrubber()

    XCTAssert(spy.events == [.didAttach, .didDetach])
  }

  func testRemovedObserverReceivesNoEvents() {
    let timeline = Timeline()

    let spy = TimelineSpy()
    timeline.addObserver(spy)

    timeline.attachScrubber(withTimeOffset: 0)
    timeline.removeObserver(spy)
    timeline.detachScrubber()

    XCTAssert(spy.events == [.didAttach])
  }

  func testScrubberReAttachementSendsScrubEvent() {
    let timeline = Timeline()

    let spy = TimelineSpy()
    timeline.addObserver(spy)

    timeline.attachScrubber(withTimeOffset: 0)
    timeline.attachScrubber(withTimeOffset: 0.5)

    XCTAssert(spy.events == [.didAttach, .didScrub(timeOffset: 0.5)])
  }

  func testScrubberDetachAndReAttachementSendsScrubEvent() {
    let timeline = Timeline()

    let spy = TimelineSpy()
    timeline.addObserver(spy)

    timeline.attachScrubber(withTimeOffset: 0)
    timeline.detachScrubber()
    timeline.attachScrubber(withTimeOffset: 0.5)

    XCTAssert(spy.events == [.didAttach, .didDetach, .didAttach, .didScrub(timeOffset: 0.5)])
  }

  func testScrubberDetachAndReAttachementSameValueSendsNoScrubEvent() {
    let timeline = Timeline()

    let spy = TimelineSpy()
    timeline.addObserver(spy)

    timeline.attachScrubber(withTimeOffset: 0)
    timeline.detachScrubber()
    timeline.attachScrubber(withTimeOffset: 0)

    XCTAssert(spy.events == [.didAttach, .didDetach, .didAttach])
  }

  func testAttachedScrubberChangesSendsEvents() {
    let timeline = Timeline()

    timeline.attachScrubber(withTimeOffset: 0)
    let scrubber = timeline.scrubber!

    let spy = TimelineSpy()
    timeline.addObserver(spy)

    scrubber.timeOffset = 10
    scrubber.timeOffset = 0
    scrubber.timeOffset = 0.5

    XCTAssert(spy.events == [.didScrub(timeOffset: 10),
                             .didScrub(timeOffset: 0),
                             .didScrub(timeOffset: 0.5)])
  }

  func testAttachedScrubberRepeatedChangeSendsNoEvents() {
    let timeline = Timeline()

    timeline.attachScrubber(withTimeOffset: 0)
    let scrubber = timeline.scrubber!

    let spy = TimelineSpy()
    timeline.addObserver(spy)

    scrubber.timeOffset = 10
    scrubber.timeOffset = 0
    scrubber.timeOffset = 0.5
    scrubber.timeOffset = 0.5

    XCTAssert(spy.events == [.didScrub(timeOffset: 10),
                             .didScrub(timeOffset: 0),
                             .didScrub(timeOffset: 0.5)])
  }

  func testDetachedScrubberSendsNoEvents() {
    let timeline = Timeline()

    timeline.attachScrubber(withTimeOffset: 0)
    let scrubber = timeline.scrubber!
    timeline.detachScrubber()

    let spy = TimelineSpy()
    timeline.addObserver(spy)

    scrubber.timeOffset = 10
    scrubber.timeOffset = 0
    scrubber.timeOffset = 0.5

    XCTAssert(spy.events == [])
  }

  func testBeginTimeIsNonnullAfterBegin() {
    let timeline = Timeline()
    XCTAssertNil(timeline.beginTime)
    timeline.begin()
    XCTAssertNotNil(timeline.beginTime)
  }
}
