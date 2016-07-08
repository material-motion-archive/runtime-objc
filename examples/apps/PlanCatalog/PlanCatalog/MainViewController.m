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

#import "MainViewController.h"
#import "Plan/PlanFadeViewController.h"

NSString *const title = @"Material Motion";

@interface MainViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic) UITableView *tableView;

@end

@implementation MainViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = title;
  }
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];

  self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
  self.tableView.translatesAutoresizingMaskIntoConstraints = false;
  [self.view addSubview:self.tableView];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[tableView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:@{ @"tableView" : self.tableView }]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[tableView]|"
                                                                    options:0
                                                                    metrics:nil
                                                                      views:@{ @"tableView" : self.tableView }]];

  self.tableView.delegate = self;
  self.tableView.dataSource = self;
  [self.tableView registerClass:[UITableViewCell class]
         forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:true];
}

- (NSArray<Class> *)controllers {
  NSArray<Class> *controllers = @[ PlanFadeViewController.class ];

  return controllers;
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([UITableViewCell class])
                                      forIndexPath:indexPath];
  Class controllerClass = [self controllers][indexPath.row];
  if (controllerClass) {
    cell.textLabel.text = NSStringFromClass(controllerClass);
  }

  return cell;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  id controller = [[[self controllers][indexPath.row] alloc] init];
  if ([controller isKindOfClass:[UIViewController class]]) {
    [self.navigationController pushViewController:controller animated:true];
  }
}

@end
