//
//  ViewController.m
//  basic-sample
//
//  Created by Martin Gontovnikas on 30/09/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

#import "ViewController.h"
#import "Application.h"
#import <Auth0.iOS/Auth0.h>
#import <libextobjc/EXTScope.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showSignIn:(id)sender {
    A0AuthenticationViewController *controller = [[A0AuthenticationViewController alloc] init];
    controller.closable = false;
    @weakify(self);
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        @strongify(self);
        
        
        [[Application sharedInstance].session.dataSource storeToken:token andUserProfile:profile];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"showProfile" sender:self];
    };
    [self presentViewController:controller animated:YES completion:nil];
}

@end
