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
 This will allow const identifiers to be easily used in Swift 3.
 */
typedef NSString *MDMEventIdentifier NS_EXTENSIBLE_STRING_ENUM NS_SWIFT_NAME(Identifier);

/**
 A key used in the userInfo dictionary of an NSNotification. The key's value should be an instance of a class that implements MDMEvent.
 */
static NSString *_Nonnull MDMEventNotificationKeyEvent = @"MDMEventNotificationKeyEvent";

/**
 Classes implementing this protocol are official, testable events.
 */

NS_SWIFT_NAME(Event)
@protocol MDMEvent <NSObject>

@end
