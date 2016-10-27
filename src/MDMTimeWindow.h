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

/** The possible directions of movement for the position in a time window. */
typedef NS_ENUM(NSUInteger, MDMTimeWindowDirection) {
  /** Moving towards 1.0. */
  MDMTimeWindowDirectionForward,

  /** Moving towards 0.0. */
  MDMTimeWindowDirectionBackward,
} NS_SWIFT_NAME(TimeWindowDirection);

/** A time window provides a normalized view of a period of time. */
NS_SWIFT_NAME(TimeWindow)
@interface MDMTimeWindow : NSObject

/** Initializes a newly-allocated time window with a direction and duration. */
- (nonnull instancetype)initWithInitialDirection:(MDMTimeWindowDirection)initialDirection
                                        duration:(NSTimeInterval)duration
    NS_DESIGNATED_INITIALIZER;

/** Unavailable. */
- (nonnull instancetype)init NS_UNAVAILABLE;

/** The initial direction of the time window position's movement. */
@property(nonatomic, assign, readonly) MDMTimeWindowDirection initialDirection;

/** The duration described by this time window. */
@property(nonatomic, assign, readonly) NSTimeInterval duration;

/** The current direction of the time window position's movement. */
@property(nonatomic, assign) MDMTimeWindowDirection currentDirection;

/**
 The current position within the time window.

 Expressed in the range [0,1].

 - 0 refers to the back side of the time window.
 - 1 refers to the front side of the time window.

 The initial value depends on the initialDirection.
 */
@property(nonatomic, assign) CGFloat position;

@end
