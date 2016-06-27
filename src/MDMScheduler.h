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
 A class conforming to MDMPlan is expected to describe a plan of motion for a target.

 Plans are translated into performers by an instance of MDMScheduler.
 */
@protocol MDMPlan <NSObject>

/**
 Asks the receiver to return a class conforming to MDMPerformer.

 The returned class will be instantiated by an MDMScheduler. The instantiated performer is expected to
 execute the plan.
 */
- (nonnull Class)performerClass;

@end

/**
 A class conforming to MDMPerforming is expected to implement the plan of motion described by objects
 that conform to MDMPlan.
 */
@protocol MDMPerforming <NSObject>

/** The receiver is expected to execute its plan to the provided target. */
- (nonnull instancetype)initWithTarget:(nonnull id)target;

@end

/** A class conforming to this protocol will be provided with plan instances. */
@protocol MDMPlanPerforming <MDMPerforming>

/**
 * Provides the performer with an plan.
 *
 * The performer may choose to store this plan or to simply extract necessary information and cache
 * it separately.
 */
- (void)addPlan:(nullable id<MDMPlan>)plan;

@end

/**
 A class conforming to MDMDelegatedPerforming is expected to delegate execution to an external system.
 */
@protocol MDMDelegatedPerforming <MDMPerforming>

/**
 The performer must call this method before remote execution begins.

 This is not recursive.
 */
@property(nonnull, copy) void (^remoteExecutionWillStartNamed)(NSString *_Nonnull);

/**
 The performer must call this method after remote execution ends.

 This is not recursive.
 */
@property(nonnull, copy) void (^remoteExecutionDidEndNamed)(NSString *_Nonnull);

@end

typedef enum : NSUInteger {
  MDMSchedulerActivityStateIdle,
  MDMSchedulerActivityStateActive,
} MDMSchedulerActivityState;

@class MDMTransaction;
@protocol MDMSchedulerDelegate;

/**
 The MDMScheduler class coordinates the registration and execution of motion intent, as expressed by
 the MDMPlan type.
 */
@interface MDMScheduler : NSObject

/**
 The current activity state of the scheduler.

 A scheduler is Active if any Performer is active. Otherwise, the scheduler is Idle.

 An Performer conforming to MDMDelegatedPerforming is active if it has ongoing remote execution.
 */
@property(nonatomic, assign, readonly) MDMSchedulerActivityState activityState;

/** Commits the provided transaction to the receiver. */
- (void)commitTransaction:(nonnull MDMTransaction *)transaction;

@property(nonatomic, weak, nullable) id<MDMScheduleDelegate> delegate;

@end

@protocol MDMSchedulerDelegate <NSObject>
@required

- (void)schedulerActivityStateDidChange:(nonnull MDMScheduler *)scheduler;

@end
