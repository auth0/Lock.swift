//
//  ProfileViewController.m
//  basic-sample
//
//  Created by Martin Gontovnikas on 30/09/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

#import "ProfileViewController.h"
#import "Application.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <Auth0.iOS/Auth0.h>
#import <UICKeyChainStore/UICKeyChainStore.h>

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UICKeyChainStore *store = [[Application sharedInstance] store];
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:[store dataForKey:@"profile"]];
    [self.profileImage sd_setImageWithURL:profile.picture];
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@!", profile.name];
}

@end
