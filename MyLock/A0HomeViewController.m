// A0HomeViewController.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0HomeViewController.h"

#import <Lock/Lock.h>
#import <SimpleKeychain/A0SimpleKeychain.h>
#import <JWTDecode/JWTDecode.h>

#define kClientIdKey @"Auth0ClientId"
#define kTenantKey @"Auth0Tenant"

#ifdef DEBUG
static BOOL isRunningTests(void) {
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *injectBundle = environment[@"XCInjectBundle"];
    return [[injectBundle pathExtension] isEqualToString:@"xctest"];
}
#endif

@interface A0HomeViewController ()

@property (strong, nonatomic) A0SimpleKeychain *keychain;
@end

@implementation A0HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

#ifdef DEBUG
    if (isRunningTests()) {
        return;
    }
#endif

    self.keychain = [A0SimpleKeychain keychainWithService:@"Auth0"];
    NSString* refreshToken = [self.keychain stringForKey: @"refresh_token"];
    NSString* idToken = [self.keychain stringForKey: @"id_token"];
    A0APIClient *client = [[A0Lock sharedLock] apiClient];
    if (refreshToken) {
        [client fetchNewIdTokenWithRefreshToken:refreshToken parameters:nil success:^(A0Token * _Nonnull token) {
            [self.keychain setString:token.idToken forKey:@"id_token"];
            [self performSegueWithIdentifier:@"LoggedIn" sender:self];
        } failure:^(NSError * _Nonnull error) {
            [self.keychain clearAll];
        }];
    } else if (idToken) {
        [self performSegueWithIdentifier:@"LoggedIn" sender:self];
    }

    A0Lock *lock = [A0Lock sharedLock];
    self.clientIdLabel.text = [lock clientId];
    self.tenantLabel.text = [[lock domainURL] host];
}

- (void)loginNative:(id)sender {
    [self.keychain clearAll];
    A0Lock *lock = [A0Lock sharedLock];
    A0LockViewController *controller = [lock newLockViewController];
    controller.closable = YES;
    controller.loginAfterSignUp = YES;
    controller.usesEmail = YES;
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        if (!token) {
            return;
        }
        NSLog(@"SUCCESS %@", profile);
        [self.keychain setString:token.idToken forKey:@"id_token"];
        [self.keychain setString:token.refreshToken forKey:@"refresh_token"];
        [self.keychain setData:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:@"profile"];
        [self dismissViewControllerAnimated:YES completion:^(){
            [self performSegueWithIdentifier:@"LoggedIn" sender:self];
        }];
    };
    [lock presentLockController:controller fromController:self];
}

- (void)loginTouchID:(id)sender {
    [self.keychain clearAll];
    A0Lock *lock = [A0Lock sharedLock];

    A0TouchIDLockViewController *controller = [lock newTouchIDViewController];
    controller.closable = YES;
    controller.cleanOnError = YES;
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        NSLog(@"SUCCESS %@", profile);
        [self.keychain setString:token.idToken forKey:@"id_token"];
        [self.keychain setString:token.refreshToken forKey:@"refresh_token"];
        [self.keychain setData:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:@"profile"];
        [self dismissViewControllerAnimated:YES completion:^(){
            [self performSegueWithIdentifier:@"LoggedIn" sender:self];
        }];
    };
    [lock presentTouchIDController:controller fromController:self];
}

- (void)loginSMS:(id)sender {
    [self.keychain clearAll];
    A0Lock *lock = [A0Lock sharedLock];
    A0SMSLockViewController *controller = [lock newSMSViewController];
    controller.closable = YES;
    controller.useMagicLink = YES;
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        NSLog(@"SUCCESS %@", profile);
        [self.keychain setString:token.idToken forKey:@"id_token"];
        [self.keychain setString:token.refreshToken forKey:@"refresh_token"];
        [self.keychain setData:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:@"profile"];
        [self dismissViewControllerAnimated:YES completion:^(){
            [self performSegueWithIdentifier:@"LoggedIn" sender:self];
        }];
    };
    [lock presentSMSController:controller fromController:self];
}

- (void)loginEmail:(id)sender {
    [self.keychain clearAll];
    A0Lock *lock = [A0Lock sharedLock];
    A0EmailLockViewController *controller = [lock newEmailViewController];
    controller.closable = YES;
    controller.useMagicLink = YES;
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        NSLog(@"SUCCESS %@", profile);
        [self.keychain setString:token.idToken forKey:@"id_token"];
        [self.keychain setString:token.refreshToken forKey:@"refresh_token"];
        [self.keychain setData:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:@"profile"];
        [self dismissViewControllerAnimated:YES completion:^(){
            [self performSegueWithIdentifier:@"LoggedIn" sender:self];
        }];
    };
    [lock presentEmailController:controller fromController:self];
}

@end
