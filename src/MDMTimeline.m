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

#import "MDMTimeline.h"

@interface MDMTimeline ()
- (void)scrubberDidScrub:(NSTimeInterval)timeOffset;
@end

@interface MDMTimelineScrubber ()
@property(nonatomic, weak) MDMTimeline *timeline;
@end

@implementation MDMTimelineScrubber

- (void)setTimeOffset:(NSTimeInterval)timeOffset {
  if (_timeOffset == timeOffset) {
    return;
  }

  _timeOffset = timeOffset;

  [self.timeline scrubberDidScrub:_timeOffset];
}

@end

@implementation MDMTimeline {
  NSHashTable *_observers;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _observers = [NSHashTable weakObjectsHashTable];
  }
  return self;
}

#pragma mark - Public

- (void)begin {
  NSAssert(_beginTime == nil, @"Begin was already invoked on this timeline.");
  _beginTime = @(CACurrentMediaTime());
}

- (void)setScrubber:(MDMTimelineScrubber *)scrubber {
  if (_scrubber == scrubber) {
    return;
  }
  if (_scrubber) {
    _scrubber.timeline = nil;

    for (id<MDMTimelineObserving> observer in _observers) {
      [observer timeline:self didDetachScrubber:_scrubber];
    }
  }

  _scrubber = scrubber;

  _scrubber.timeline = self;

  if (_scrubber) {
    for (id<MDMTimelineObserving> observer in _observers) {
      [observer timeline:self didAttachScrubber:_scrubber];
    }
  }
}

- (void)addTimelineObserver:(id<MDMTimelineObserving>)observer {
  [_observers addObject:observer];
}

- (void)removeTimelineObserver:(nonnull id<MDMTimelineObserving>)observer {
  [_observers removeObject:observer];
}

- (void)scrubberDidScrub:(NSTimeInterval)timeOffset {
  for (id<MDMTimelineObserving> observer in _observers) {
    [observer timeline:self scrubberDidScrub:timeOffset];
  }
}

@end
