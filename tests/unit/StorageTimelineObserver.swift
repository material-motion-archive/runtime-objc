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

import MaterialMotionRuntime

enum TimelineObserverEvent {
  case didAttach
  case didDetach
  case didScrub(timeOffset: TimeInterval)
}

class StorageTimelineObserver: NSObject, TimelineObserving {
  var events: [TimelineObserverEvent] = []

  func timeline(_ timeline: Timeline, didAttach scrubber: TimelineScrubber) {
    events.append(.didAttach)
  }

  func timeline(_ timeline: Timeline, didDetach scrubber: TimelineScrubber) {
    events.append(.didDetach)
  }

  func timeline(_ timeline: Timeline, scrubberDidScrub timeOffset: TimeInterval) {
    events.append(.didScrub(timeOffset: timeOffset))
  }
}

func ==(lhs: TimelineObserverEvent, rhs: TimelineObserverEvent) -> Bool {
  switch (lhs, rhs) {
  case (.didAttach, .didAttach): return true
  case (.didDetach, .didDetach): return true
  case (.didScrub(let timeOffset1), .didScrub(let timeOffset2)) where timeOffset1 == timeOffset2:
    return true
  default: return false
  }
}

func ==(lhs: [TimelineObserverEvent], rhs: [TimelineObserverEvent]) -> Bool {
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
