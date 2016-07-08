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

#import "Tween.h"

@interface TweenPerformer : NSObject <MDMDelegatedPerforming>

@property(nonatomic, weak) UIView *target;

@end

@implementation Tween

- (nonnull instancetype)initWithProperty:(NSString *)property name:(NSString *)name {
  self = [super init];
  if (self) {
    _property = property;
    _name = name;
  }
  return self;
}

- (Class)performerClass {
  return [TweenPerformer class];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
  Tween *tweenCopy = [[[self class] alloc] initWithProperty:self.property name:self.name];

  if (tweenCopy) {
    tweenCopy.from = self.from;
    tweenCopy.to = self.to;
  }

  return tweenCopy;
}

@end

@implementation TweenPerformer

@synthesize delegatedPerformanceWillStartNamed;
@synthesize delegatedPerformanceDidEndNamed;

- (instancetype)initWithTarget:(UIView *)target {
  self = [super init];
  if (self) {
    _target = target;
  }
  return self;
}

- (void)addPlan:(Tween *)tweenPlan {
  [CATransaction begin];

  [CATransaction setCompletionBlock:^{
    [CATransaction begin];
    [CATransaction setDisableActions:true];

    [self.target.layer setValue:@(tweenPlan.to) forKeyPath:tweenPlan.property];
    [self.target.layer removeAnimationForKey:tweenPlan.name];

    [CATransaction commit];

    self.delegatedPerformanceDidEndNamed(tweenPlan.name);
  }];

  CABasicAnimation *animation = [CABasicAnimation animation];
  animation.fromValue = @(tweenPlan.from);
  animation.toValue = @(tweenPlan.to);
  animation.keyPath = tweenPlan.property;
  animation.removedOnCompletion = false;

  [self.target.layer addAnimation:animation forKey:tweenPlan.name];

  [CATransaction commit];

  self.delegatedPerformanceWillStartNamed(tweenPlan.name);
}

@end
