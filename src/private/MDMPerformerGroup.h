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

#import "MDMEvent.h"

@class MDMScheduler;
@class MDMTransactionLog;
@protocol MDMPerformerGroupDelegate;

/** An entity responsible for managing the performers associated with a given target. */
@interface MDMPerformerGroup : NSObject

- (nonnull instancetype)initWithTarget:(nonnull id)target scheduler:(nonnull MDMScheduler *)scheduler NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init NS_UNAVAILABLE;

@property(nonatomic, nonnull, readonly) id target;

@property(nonatomic, nullable, weak) id<MDMPerformerGroupDelegate> delegate;

// nil by default. Useful for view duplication.
@property(nonatomic, nullable) id schedulerTarget;

- (void)executeLog:(nonnull MDMTransactionLog *)log;

@end

#pragma mark - Event Broadcasting

/**
 This is the name of the NSNotification fired when this event happens. Its userInfo will contain an MDMEvent of the type below.
 */
FOUNDATION_EXPORT MDMEventIdentifier const _Nonnull MDMEventIdentifierPerformersCreated;
