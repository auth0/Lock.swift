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
#import <UICKeyChainStore/UICKeyChainStore.h>
#import <JWTDecode/A0JWTDecoder.h>
#import <MBProgressHUD/MBProgressHUD.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UICKeyChainStore *store = [Application sharedInstance].store;
    NSString *idToken = [store stringForKey:@"id_token"];
    if (idToken) {
        if ([[A0JWTDecoder expireDateOfJWT:idToken error:nil] compare:[NSDate date]] == NSOrderedAscending) {
            NSString *refreshToken = [store stringForKey:@"refresh_token"];
            @weakify(self);
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[A0APIClient sharedClient] delegationWithRefreshToken:refreshToken parameters:nil success:^(A0Token *token) {
                @strongify(self);
                [store setString:token.idToken forKey:@"id_token"];
                [store synchronize];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self performSegueWithIdentifier:@"showProfile" sender:self];
            } failure:^(NSError *error) {
                @strongify(self);
                [store removeAllItems];
                [store synchronize];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        } else {
            [self performSegueWithIdentifier:@"showProfile" sender:self];
        }
    }
}

- (IBAction)showSignIn:(id)sender {
    A0AuthenticationViewController *controller = [[A0AuthenticationViewController alloc] init];
    controller.closable = true;
    @weakify(self);
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        @strongify(self);
        
        UICKeyChainStore *store = [Application sharedInstance].store;
        [store setString:token.idToken forKey:@"id_token"];
        [store setString:token.refreshToken forKey:@"refresh_token"];
        [store setData:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:@"profile"];
        [store synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"showProfile" sender:self];
    };
    [self presentViewController:controller animated:YES completion:nil];
}

@end
