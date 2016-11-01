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

#import "MDMRuntime.h"

@protocol MDMSchedulerDelegate;
@protocol MDMPlan;
@protocol MDMNamedPlan;
@protocol MDMTracing;

// clang-format off

/** Deprecated. Use MDMRuntimeActivityState instead. */
__deprecated_msg("Use MDMRuntimeActivityState instead. Deprecated in v4.0.0.")
typedef MDMRuntimeActivityState MDMSchedulerActivityState;

/** Deprecated. Use MDMRuntimeActivityStateIdle instead. */
__deprecated_msg("Use MDMRuntimeActivityStateIdle instead. Deprecated in v4.0.0.")
extern const MDMSchedulerActivityState MDMSchedulerActivityStateIdle;

/** Deprecated. Use MDMRuntimeActivityStateActive instead. */
__deprecated_msg("Use MDMRuntimeActivityStateActive instead. Deprecated in v4.0.0.")
extern const MDMSchedulerActivityState MDMSchedulerActivityStateActive;

/** Deprecated. Use Runtime instead. */
NS_SWIFT_NAME(Scheduler)
__deprecated_msg("Use Runtime instead. Deprecated in v4.0.0.")
@interface MDMScheduler : MDMRuntime
@end

/** Deprecated. Use RuntimeDelegate instead. */
NS_SWIFT_NAME(SchedulerDelegate)
__deprecated_msg("Use RuntimeDelegate instead. Deprecated in v4.0.0.")
@protocol MDMSchedulerDelegate <MDMRuntimeDelegate>

/** Informs the receiver that the scheduler's current activity state has changed. */
- (void)schedulerActivityStateDidChange:(nonnull MDMScheduler *)scheduler;

@end
    // clang-format on
