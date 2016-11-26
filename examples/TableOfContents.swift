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

// MARK: Catalog by convention

import MaterialMotionRuntime

extension LifeOfAPlanViewController {
  class func catalogBreadcrumbs() -> [String] {
    return ["1. Life of a plan"]
  }
}

extension LifeOfAConfigurablePlanViewController {
  class func catalogBreadcrumbs() -> [String] {
    return ["2. Life of a configurable plan"]
  }
}

extension LifeOfAComposablePlanExampleController {
  class func catalogBreadcrumbs() -> [String] {
    return ["3. Life of a composable plan"]
  }
}

extension TimelineObservationExampleViewController {
  class func catalogBreadcrumbs() -> [String] {
    return ["4. Timeline observation"]
  }
}
