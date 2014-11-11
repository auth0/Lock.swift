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
#import <Lock/Lock.h>
#import <SimpleKeychain/A0SimpleKeychain.h>
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <libextobjc/EXTScope.h>

@interface ProfileViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;

- (IBAction)callAPI:(id)sender;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    A0SimpleKeychain *keychain = [[Application sharedInstance] store];
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:[keychain dataForKey:@"profile"]];
    [self.profileImage sd_setImageWithURL:profile.picture];
    self.welcomeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Welcome %@!", nil), profile.name];
}

- (void)callAPI:(id)sender {
    NSString *baseURLString = [[NSBundle mainBundle] infoDictionary][@"SampleAPIBaseURL"];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:baseURLString]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    @weakify(self);
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        [self showMessage:@"We got the secured data successfully"];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        @strongify(self);
        [self showMessage:@"Please download the API seed so that you can call it."];
    }];
    [operation start];
}

- (void)showMessage:(NSString *)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:message message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

@end
