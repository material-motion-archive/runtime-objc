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

import UIKit
import MaterialMotionRuntime

// This example demonstrates how to create a Timeline and observe changes to its state by
// implementing the TimelineObserving protocol. We create a rudimentary API to mimic the ability to
// attach/detach a scrubber and to be able to change its timeOffset.
class TimelineObservationExampleViewController: UIViewController, TimelineObserving {

  let timeline = Timeline()
  let maximumTimeOffset: Float = 10

  func commonInit() {
    self.title = "Enable the slider to scrub the timeline"

    timeline.addObserver(self)
  }

  // MARK: Configuring views and interactions

  var slider: UISlider!

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .white

    let toggle = UISwitch()
    let toggleSize = toggle.sizeThatFits(view.bounds.size)
    toggle.frame = CGRect(x: view.bounds.width / 2 - toggleSize.width / 2,
                          y: 100,
                          width: toggleSize.width,
                          height: toggleSize.height)
    toggle.addTarget(self, action: #selector(toggleDidChange(_:)), for: .valueChanged)
    view.addSubview(toggle)

    slider = UISlider()
    let sliderSize = slider.sizeThatFits(view.bounds.size)
    slider.frame = CGRect(x: 24,
                          y: view.bounds.height - sliderSize.height - 24,
                          width: view.bounds.width - 48,
                          height: sliderSize.height)
    slider.addTarget(self, action: #selector(sliderDidChange(_:)), for: .valueChanged)
    slider.maximumValue = maximumTimeOffset
    view.addSubview(slider)
  }

  func toggleDidChange(_ toggle: UISwitch) {
    slider.isEnabled = toggle.isOn
    if toggle.isOn {
      let scrubber = TimelineScrubber()
      scrubber.timeOffset = TimeInterval(slider.value)
      timeline.scrubber = scrubber
    } else {
      timeline.scrubber = nil
    }
  }

  func sliderDidChange(_ slider: UISlider) {
    timeline.scrubber?.timeOffset = TimeInterval(slider.value)
  }

  // MARK: TimelineObserving

  func timeline(_ timeline: Timeline, scrubberDidScrub timeOffset: TimeInterval) {
    print("Scrubber did scrub: \(timeOffset)")
  }

  func timeline(_ timeline: Timeline, didAttach scrubber: TimelineScrubber) {
    print("Did attach scrubber")
    dump(scrubber)
  }

  func timeline(_ timeline: Timeline, didDetach scrubber: TimelineScrubber) {
    print("Did detach scrubber")
    dump(scrubber)
  }

  // MARK: Routing initializers

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

    self.commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)

    self.commonInit()
  }
}
