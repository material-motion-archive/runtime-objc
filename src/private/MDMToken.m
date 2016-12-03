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

#import "MDMToken.h"
#import "MDMToken+Private.h"

#import "MDMPlan.h"

@implementation MDMToken {
  NSHashTable<id<MDMTokenActivityObserving>> *_observers;
}

@synthesize active = _active;

- (void)dealloc {
  self.active = false;
}

- (instancetype)initInternal {
  self = [super init];
  if (self) {
    _observers = [NSHashTable weakObjectsHashTable];
  }
  return self;
}

- (void)setActive:(BOOL)active {
  if (_active == active) {
    return;
  }

  _active = active;

  if (_active) {
    for (id<MDMTokenActivityObserving> observer in _observers) {
      [observer tokenDidActivate:self];
    }
  } else {
    for (id<MDMTokenActivityObserving> observer in _observers) {
      [observer tokenDidDeactivate:self];
    }
  }
}

- (void)addActivityObserver:(nonnull id<MDMTokenActivityObserving>)observer {
  [_observers addObject:observer];
}

@end
