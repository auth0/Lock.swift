//
//  A0ViewController.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 06/26/2014.
//  Copyright (c) 2014 Hernan Zalazar. All rights reserved.
//

#import "A0ViewController.h"

#import <Auth0Client/A0LoginViewController.h>

@interface A0ViewController ()

@end

@implementation A0ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    A0LoginViewController *controller = [[A0LoginViewController alloc] init];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
