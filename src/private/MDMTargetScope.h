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

@class MDMPerformerInfo;
@class MDMMotionRuntime;
@protocol MDMIsActiveTokenable;
@protocol MDMTargetScopeDelegate;
@protocol MDMPlan;
@protocol MDMNamedPlan;

/** An entity responsible for managing the performers associated with a given target. */
@interface MDMTargetScope : NSObject

- (nonnull instancetype)initWithTarget:(nonnull id)target runtime:(nonnull MDMMotionRuntime *)runtime NS_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init NS_UNAVAILABLE;

@property(nonatomic, nonnull, readonly) id target;

// nil by default. Useful for view duplication.
@property(nonatomic, nullable) id runtimeTarget;

- (void)addPlan:(nonnull id<MDMPlan>)plan to:(nonnull id)target;

- (void)addPlan:(nonnull id<MDMNamedPlan>)plan named:(nonnull NSString *)name to:(nonnull id)target;

- (void)removePlanNamed:(nonnull NSString *)name from:(nonnull id)target;

@end