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

#import "MDMPlan.h"

@protocol MDMTimelineObserving;

/** A scrubber can be attached to a timeline in order to control the timeline's timeOffset. */
NS_SWIFT_NAME(TimelineScrubber)
@interface MDMTimelineScrubber : NSObject

/** Unavailable. Use timeline.attachScrubberWithTimeOffset instead. */
- (nonnull instancetype)init NS_UNAVAILABLE;

/** Unavailable. Use timeline.attachScrubberWithTimeOffset instead. */
+ (nonnull instancetype) new NS_UNAVAILABLE;

/** The desired time offset. */
@property(nonatomic, assign) NSTimeInterval timeOffset;

@end

/** A timeline provides an API for scrubbing time. */
NS_SWIFT_NAME(Timeline)
@interface MDMTimeline : NSObject

/** Populates beginTime with the current absolute time. Can only be invoked once. */
- (void)begin;

/** The time at which the timeline began, if it has. */
@property(nonatomic, strong, nullable, readonly) NSNumber *beginTime;

/**
 Attaches a scrubber to the timeline if one wasn't already attached.

 Sends a didAttachScrubber event to all observers if a scrubber was attached.

 If a scrubber was already attached then the existing scrubber's timeOffset will be modified
 instead.
 */
- (void)attachScrubberWithTimeOffset:(NSTimeInterval)timeOffset;

/**
 Detaches a scrubber from the timeline if one was already attached.

 Sends a didDetachScrubber event to all observers.
 */
- (void)detachScrubber;

/**
 Returns the scrubber if one is attached.

 Modifications to the scrubber's timeOffset will generate scrubberDidScrub events on all observers.
 */
@property(nonatomic, strong, nullable, readonly) MDMTimelineScrubber *scrubber;

/** Add a timeline observer to the timeline. */
- (void)addTimelineObserver:(nonnull id<MDMTimelineObserving>)observer;

/** Remove a timeline observer from the timeline. */
- (void)removeTimelineObserver:(nonnull id<MDMTimelineObserving>)observer;

@end

/** A timeline observer may receive events in relation to state changes from a Timeline instance. */
NS_SWIFT_NAME(TimelineObserving)
@protocol MDMTimelineObserving <NSObject>

/** Informs the receiver that a scrubber has been attached to a timeline. */
- (void)timeline:(nonnull MDMTimeline *)timeline didAttachScrubber:(nonnull MDMTimelineScrubber *)scrubber;

/** Informs the receiver that a scrubber has been detached from a timeline. */
- (void)timeline:(nonnull MDMTimeline *)timeline didDetachScrubber:(nonnull MDMTimelineScrubber *)scrubber;

/** Informs the receiver that a timeline scrubber's timeOffset has changed. */
- (void)timeline:(nonnull MDMTimeline *)timeline scrubberDidScrub:(NSTimeInterval)timeOffset;

@end
