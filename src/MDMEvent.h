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

@protocol MDMPerforming;

/**
 Enable support for treating event identifiers as Swift enums.

 Any event identifier defined with the MDMEventIdentifier type will be made available as an
 EventIdentifier.<eventName> type in Swift code.
 */
typedef NSNotificationName MDMEventName NS_EXTENSIBLE_STRING_ENUM NS_SWIFT_NAME(EventName);

/**
 A key whose value is an object conforming to MDMEvent that contains information relevant to the
 corresponding notification.

 This key is used with all MDMEventName notifications.
 */
FOUNDATION_EXTERN NSString* const _Nonnull MDMEventNotificationEventKey NS_SWIFT_NAME(EventNotificationEventKey);

/** All objects emitted by scheduler events conform to this type. */
NS_SWIFT_NAME(Event)
@protocol MDMEvent <NSObject>
@end

/**
 Name of the event that is fired when new performers are created as part of a transaction.

 Sent on completion of a MDMScheduler commitTransaction: invocation only if new performers were
 created.

 The notification's user info MDMEventNotificationEventKey's value is an instance of
 MDMSchedulerPerformersCreatedEvent.
 */
FOUNDATION_EXPORT MDMEventName _Nonnull MDMEventNamePerformersCreated;

/** Data for the MDMEventNamePerformersCreated event. */
NS_SWIFT_NAME(SchedulerPerformersCreatedEvent)
@interface MDMSchedulerPerformersCreatedEvent : NSObject <MDMEvent>

/** The set of performers that were created by the transaction. */
@property(nonatomic, copy, nonnull) NSSet<MDMPerforming>* createdPerformers;

@end
