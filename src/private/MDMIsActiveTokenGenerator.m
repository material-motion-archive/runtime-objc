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

#import "MDMIsActiveTokenGenerator.h"

@interface MDMIsActiveTokenGenerator ()
@property(nonatomic, weak) id<MDMIsActiveTokenGeneratorDelegate> delegate;
@end

@interface MDMIsActiveToken : NSObject <MDMIsActiveTokenable>

- (nonnull instancetype)initWithDelegate:(nonnull id<MDMIsActiveTokenGeneratorDelegate>)delegate
    NS_DESIGNATED_INITIALIZER;

- (nonnull instancetype)init NS_UNAVAILABLE;
+ (nonnull instancetype) new NS_UNAVAILABLE;

@property(nonatomic, weak) id<MDMIsActiveTokenGeneratorDelegate> delegate;
@property(nonatomic, assign, getter=isTerminated) BOOL terminated;

@end

@implementation MDMIsActiveToken

- (void)dealloc {
  if (!self.isTerminated) {
    [self terminate];
  }
}

- (instancetype)initWithDelegate:(id<MDMIsActiveTokenGeneratorDelegate>)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;

    [self.delegate registerIsActiveToken:self];
  }
  return self;
}

- (void)terminate {
  NSAssert(!self.terminated, @"Is-active already terminated.");
  self.terminated = true;

  [self.delegate terminateIsActiveToken:self];
}

@end

@implementation MDMIsActiveTokenGenerator

- (instancetype)initWithDelegate:(id<MDMIsActiveTokenGeneratorDelegate>)delegate {
  self = [super init];
  if (self) {
    _delegate = delegate;
  }
  return self;
}

- (id<MDMIsActiveTokenable>)generate {
  if (!self.delegate) {
    return nil;
  }
  return [[MDMIsActiveToken alloc] initWithDelegate:self.delegate];
}

@end
