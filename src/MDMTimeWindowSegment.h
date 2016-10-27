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

#import <Foundation/Foundation.h>

/**
 A time window segment defines a specific region within a time window.

 position and length are expressed in normalized units between the range [0,1].

 The time window's position + length must never exceed 1.
 */
struct NS_SWIFT_NAME(TimeWindowSegment) MDMTimeWindowSegment {
  /** The position within the time window. Expressed in the range [0,1]. */
  CGFloat position;

  /** The length of the segment within the time window. Expressed in range [0,1]. */
  CGFloat length;
};

/** Epsilon for use when comparing TimeWindowSegment values. */
NS_SWIFT_NAME(TimeWindowSegmentEpsilon)
extern const CGFloat MDMTimeWindowSegmentEpsilon;
