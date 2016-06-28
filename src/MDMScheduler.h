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

@protocol MDMSchedulerDelegate <NSObject>
@required

- (void)schedulerActivityStateDidChange:(nonnull MDMScheduler *)scheduler;

@end

typedef enum : NSUInteger {
  MDMSchedulerActivityStateIdle,
  MDMSchedulerActivityStateActive,
} MDMSchedulerActivityState;

@class MDMTransaction;

/**
 The MDMScheduler class coordinates the registration and execution of motion intent, as expressed by
 the MDMPlan type.
 */
@interface MDMScheduler : NSObject

/**
 The current activity state of the scheduler.

 A scheduler is Active if any Performer is active. Otherwise, the scheduler is Idle.

 An Performer conforming to MDMDelegatedPerforming is active if it has ongoing delegated execution.
 */
@property(nonatomic, assign, readonly) MDMSchedulerActivityState activityState;

/** Commits the provided transaction to the receiver. */
- (void)commitTransaction:(nonnull MDMTransaction *)transaction;

@property(nonatomic, weak, nullable) id<MDMScheduleDelegate> delegate;

@end
