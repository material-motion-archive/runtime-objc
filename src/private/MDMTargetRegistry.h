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

@class MDMTokenPool;
@class MDMMotionRuntime;
@protocol MDMPlan;
@protocol MDMNamedPlan;
@protocol MDMTracing;

@interface MDMTargetRegistry : NSObject

- (nonnull instancetype)initWithRuntime:(nonnull MDMMotionRuntime *)runtime
                                tracers:(nonnull NSOrderedSet<id<MDMTracing>> *)tracers
    NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)init NS_UNAVAILABLE;
+ (nonnull instancetype) new NS_UNAVAILABLE;

@property(nonatomic, weak, nullable, readonly) MDMMotionRuntime *runtime;

@property(nonatomic, strong, nonnull, readonly) MDMTokenPool *tokenPool;

- (void)addPlan:(nonnull NSObject<MDMPlan> *)plan to:(nonnull id)target;

- (void)addPlan:(nonnull id<MDMNamedPlan>)plan
          named:(nonnull NSString *)name
             to:(nonnull id)target;
- (void)removePlanNamed:(nonnull NSString *)name
                   from:(nonnull id)target;

@end
