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

#import "PlanFadeViewController.h"
#import "Tween.h"

@import MaterialMotionRuntime;

@interface PlanFadeViewController ()

@property(nonatomic) UIView *redView;

@end

@implementation PlanFadeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = NSStringFromClass(self.class);
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.view.backgroundColor = [UIColor grayColor];

  self.redView = [[UIView alloc] initWithFrame:CGRectZero];
  self.redView.backgroundColor = [UIColor redColor];
  self.redView.translatesAutoresizingMaskIntoConstraints = false;
  [self.view addSubview:self.redView];

  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-100-[subView]-100-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:@{ @"subView" : self.redView }]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[subView]-100-|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:@{ @"subView" : self.redView }]];

  self.redView.alpha = 0;
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  Tween *fade = [[Tween alloc] init];
  fade.property = @"opacity";
  fade.from = 0;
  fade.to = 1;

  MDMTransaction *transaction = [MDMTransaction new];
  [transaction addPlan:fade toTarget:self.redView];

  MDMScheduler *scheduler = [MDMScheduler new];
  [scheduler commitTransaction:transaction];
}

@end
