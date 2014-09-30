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

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) A0Session *session;

@end

@implementation ProfileViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.session = [Application sharedInstance].session;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [self.profileImage sd_setImageWithURL: self.session.profile.picture];
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@!", self.session.profile.name];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
