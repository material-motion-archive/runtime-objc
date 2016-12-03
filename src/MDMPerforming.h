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

@protocol MDMPlan;
@protocol MDMNamedPlan;

/**
 A class conforming to MDMPerforming is expected to implement the plan of motion described by objects
 that conform to MDMPlan.
 */
NS_SWIFT_NAME(Performing)
@protocol MDMPerforming <NSObject>

#pragma mark Designated initializer

/** The receiver is expected to execute its plan to the provided target. */
- (nonnull instancetype)initWithTarget:(nonnull id)target;

#pragma mark Adding plans to a performer

/**
 Provides the performer with a plan.

 The performer may choose to store this plan or to simply extract necessary information and cache
 it separately.

 @param plan The plan that required this type of performer.
 */
- (void)addPlan:(nonnull id<MDMPlan>)plan
    NS_SWIFT_NAME(addPlan(_:));

@end

/** Specifics for a named plan performer to allow named plans to be added and removed. */
NS_SWIFT_NAME(NamedPlanPerforming)
@protocol MDMNamedPlanPerforming <MDMPerforming>

/**
 Provides the performer with a plan and an associated name.

 @param plan The plan that required this type of performer.
 @param name The name by which the plan can be identified.
 */
- (void)addPlan:(nonnull id<MDMNamedPlan>)plan
          named:(nonnull NSString *)name
    NS_SWIFT_NAME(addPlan(_:named:));

/**
 Removes a named plan from a performer.

 @param name The name by which the plan can be identified.
 */
- (void)removePlanNamed:(nonnull NSString *)name
    NS_SWIFT_NAME(removePlan(named:));

@end

#pragma mark - Continuous performing

@protocol MDMPlanTokenizing;

/**
 A performer that conforms to MDMContinuousPerforming is able to fetch tokens for plans.

 The runtime uses these tokens to inform its active state. If any token is active then the runtime
 is active. Otherwise, the runtime is idle.

 The performer should store a strong reference to the token generator. Fetch a token when a plan is
 added. When some continuous work is about to begin, such as adding an animation or starting a
 gesture recognizer, active the token. Deactivate the token when the continuous work completes, such
 as when an animation reaches its resting state or when a gesture recognizer is ended or canceled.
 */
NS_SWIFT_NAME(ContinuousPerforming)
@protocol MDMContinuousPerforming <MDMPerforming>

#pragma mark Continuous performing

/**
 Provides the performer with a plan tokenizer instance.

 Invoked before any add(plan:) invocations occur.
 */
- (void)givePlanTokenizer:(nonnull id<MDMPlanTokenizing>)planTokenizer
    NS_SWIFT_NAME(givePlanTokenizer(_:));

@end

/**
 A token is a representation of potential activity for a specific plan.

 When activity for a plan begins, the token should be activated. When the activity ends, the token
 should be deactivated. Tokens can be reactivated.

 Tokens will deactivate themselves on dealloc.
 */
NS_SWIFT_NAME(Tokened)
@protocol MDMTokened <NSObject>

#pragma mark Modifying token active state

/** An active token will be added to the runtime's pool of active tokens. */
@property(nonatomic, assign, getter=isActive) BOOL active;

@end

/** A tokenizer turns plans into motion tokens. */
NS_SWIFT_NAME(PlanTokenizing)
@protocol MDMPlanTokenizing <NSObject>

/**
 Returns a token for a given plan.

 The receiver of this token is expected to activate the token when work associated with the plan
 has started. Similarly, the token should be deactivated when the work completes.

 May fail to generate a token if the performer's runtime has been deallocated.

 Will always return the same token instance for a given plan instance.
 */
- (nullable id<MDMTokened>)tokenForPlan:(nonnull id<MDMPlan>)plan;

@end

#pragma mark - Composition

/**
 A plan emitter allows an object to emit new plans to a backing runtime for the target to which the
 performer is associated.
 */
NS_SWIFT_NAME(PlanEmitting)
@protocol MDMPlanEmitting <NSObject>

/** Emit a new plan. The plan will immediately be added to the backing runtime. */
- (void)emitPlan:(nonnull NSObject<MDMPlan> *)plan
    NS_SWIFT_NAME(emitPlan(_:));

@end

/** A class conforming to MDMComposablePerforming is able to commit new plans. */
NS_SWIFT_NAME(ComposablePerforming)
@protocol MDMComposablePerforming <MDMPerforming>

#pragma mark Composable performing

/** The performer is provided a plan emitter shortly after initialization. */
- (void)setPlanEmitter:(nonnull id<MDMPlanEmitting>)planEmitter
    NS_SWIFT_NAME(setPlanEmitter(_:));

@end
