//
//  A0UserProfileViewController.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 7/6/14.
//  Copyright (c) 2014 Hernan Zalazar. All rights reserved.
//

#import "A0UserProfileViewController.h"

@interface A0UserProfileViewController ()

@end

@implementation A0UserProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userIdLabel.text = self.authInfo[@"user_id"];
    self.usernameLabel.text = self.authInfo[@"name"];
    self.emailLabel.text = self.authInfo[@"email"];
    self.nicknameLabel.text = self.authInfo[@"nickname"];
}

@end
