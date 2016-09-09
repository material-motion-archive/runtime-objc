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
@protocol MDMSchedulerDelegate;
@protocol MDMPerforming;

/**
 The possible activity states a scheduler can be in.

 A scheduler can be either idle or active. If any performer in the scheduler is active, then the
 scheduler is active.
 */
typedef NS_ENUM(NSUInteger, MDMSchedulerActivityState) {
  /** An idle scheduler has no active performers. */
  MDMSchedulerActivityStateIdle,

  /** An active scheduler has at least one active performer. */
  MDMSchedulerActivityStateActive,
};

@class MDMTransaction;

/**
 An instance of MDMScheduler acts as the mediating agent between plans and performers.

 Plans are objects that conform to the MDMPlan protocol.
 Performers are objects that conform to the MDMPerforming protocol.

 ## Usage

 Many MDMScheduler instances may be instantiated throughout the lifetime of an app.
 Generally-speaking, one scheduler is created per interaction. An interaction might be a transition,
 a one-off animation, or a complex multi-state interaction.

 To add plans to a scheduler you must create an instance of MDMTransaction. A transaction captures
 a series of operations that associate plans with targets.

 Once a transaction is committed to a scheduler, the scheduler creates performer instances.
 Performers are expected to fulfill the described plans.

 ## Lifecycle

 When an instance of MDMScheduler is deallocated its performers will also be deallocated.
 */
NS_SWIFT_NAME(Scheduler)
@interface MDMScheduler : NSObject

#pragma mark Committing transactions

/** Commits the provided transaction to the receiver. */
- (void)commitTransaction:(nonnull MDMTransaction *)transaction
    NS_SWIFT_NAME(commit(transaction:));

#pragma mark State

/**
 The current activity state of the scheduler.

 A scheduler is Active if any Performer is active. Otherwise, the scheduler is Idle.

 An Performer conforming to MDMDelegatedPerforming is active if it has ongoing delegated performance.
 */
@property(nonatomic, assign, readonly) MDMSchedulerActivityState activityState;

#pragma mark Delegated events

/** A scheduler delegate can listen to specific state change events. */
@property(nonatomic, weak, nullable) id<MDMSchedulerDelegate> delegate;

@end

/**
 The MDMSchedulerDelegate protocol defines state change events that may be sent from an instance of
 MDMScheduler.
 */
NS_SWIFT_NAME(SchedulerDelegate)
@protocol MDMSchedulerDelegate <NSObject>

/** Informs the receiver that the scheduler's current activity state has changed. */
- (void)schedulerActivityStateDidChange:(nonnull MDMScheduler *)scheduler;

@end

#pragma mark - Event Broadcasting

/**
 This event is created when the perfomerGroup / log is executed. Performers are created. They are copied here.
 */
@interface MDMSchedulerExecutionPerformersCreatedEvent : NSObject <MDMEvent>

/**
 This is the object included in the event when it's sent.
 */
@property(nonatomic, nonnull) NSArray<MDMPerforming> *performers;

@end
