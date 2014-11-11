//
//  ViewController.m
//  basic-sample
//
//  Created by Martin Gontovnikas on 30/09/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

#import "ViewController.h"
#import "Application.h"

#import <Lock/Lock.h>
#import <libextobjc/EXTScope.h>
#import <JWTDecode/A0JWTDecoder.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <SimpleKeychain/A0SimpleKeychain.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    A0SimpleKeychain *store = [Application sharedInstance].store;
    NSString *idToken = [store stringForKey:@"id_token"];
    if (idToken) {
        if ([A0JWTDecoder isJWTExpired:idToken]) {
            NSString *refreshToken = [store stringForKey:@"refresh_token"];
            @weakify(self);
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [[A0APIClient sharedClient] fetchNewIdTokenWithRefreshToken:refreshToken parameters:nil success:^(A0Token *token) {
                @strongify(self);
                [store setString:token.idToken forKey:@"id_token"];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                [self performSegueWithIdentifier:@"showProfile" sender:self];
            } failure:^(NSError *error) {
                @strongify(self);
                [store clearAll];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            }];
        } else {
            [self performSegueWithIdentifier:@"showProfile" sender:self];
        }
    }
}

- (IBAction)showSignIn:(id)sender {
    A0LockViewController *controller = [[A0LockViewController alloc] init];
    controller.closable = true;
    @weakify(self);
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        @strongify(self);
        
        A0SimpleKeychain *keychain = [Application sharedInstance].store;
        [keychain setString:token.idToken forKey:@"id_token"];
        [keychain setString:token.refreshToken forKey:@"refresh_token"];
        [keychain setData:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:@"profile"];
        [self dismissViewControllerAnimated:YES completion:nil];
        [self performSegueWithIdentifier:@"showProfile" sender:self];
    };
    [self presentViewController:controller animated:YES completion:nil];
}

@end
