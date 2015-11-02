//
//  ViewController.m
//  MyLock
//
//  Created by Hernan Zalazar on 11/2/15.
//  Copyright © 2015 Auth0. All rights reserved.
//

#import "ViewController.h"
#import <Lock/Lock.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    A0Lock *lock = [A0Lock newLockWithClientId:@"U5MhUrbyQHSVWjlEqZSTCBUFABLbJAS3" domain:@"overmind.auth0.com"];
    A0LockViewController *controller = [lock newLockViewController];
    [lock presentLockController:controller fromController:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
