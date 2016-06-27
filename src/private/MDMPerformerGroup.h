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

@class MDMTransactionLog;
@protocol MDMPerformerGroupDelegate;

/** An entity responsible for managing the performers associated with a given target. */
@interface MDMPerformerGroup : NSObject

- (instancetype)initWithTarget:(id)target NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@property(nonatomic, readonly) id target;

@property(nonatomic, weak) id<MDMPerformerGroupDelegate> delegate;

// nil by default. Useful for view duplication.
@property(nonatomic) id schedulerTarget;

- (void)executeLog:(MDMTransactionLog *)log;

@end

@protocol MDMPerformerGroupDelegate <NSObject>
@required

- (void)performerGroup:(MDMPerformerGroup *)performerGroup activeStateDidChange:(BOOL)isActive;

@end
