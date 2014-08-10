//
//  A0UserProfileViewController.h
//  Auth0Client
//
//  Created by Hernan Zalazar on 7/6/14.
//  Copyright (c) 2014 Hernan Zalazar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class A0UserProfile;

@interface A0UserProfileViewController : UITableViewController

@property (strong, nonatomic) A0UserProfile *authInfo;

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end
