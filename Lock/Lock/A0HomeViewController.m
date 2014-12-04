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
#import <libextobjc/EXTScope.h>
#import <SimpleKeychain/A0SimpleKeychain.h>
#import <JWTDecode/A0JWTDecoder.h>

#define kClientIdKey @"Auth0ClientId"
#define kTenantKey @"Auth0Tenant"

@interface A0HomeViewController ()

@property (strong, nonatomic) A0SimpleKeychain *keychain;

@end

@implementation A0HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    A0TwitterAuthenticator *twitter = [A0TwitterAuthenticator newAuthenticatorWithKey:@""
                                                                            andSecret:@""];
    A0FacebookAuthenticator *facebook = [A0FacebookAuthenticator newAuthenticatorWithDefaultPermissions];
    [[A0IdentityProviderAuthenticator sharedInstance] registerAuthenticationProviders:@[
                                                                                        twitter,
                                                                                        facebook,
                                                                                        ]];


    self.keychain = [A0SimpleKeychain keychainWithService:@"Auth0"];
    @weakify(self);
    NSString* refreshToken = [self.keychain stringForKey: @"refresh_token"];
    NSString* idToken = [self.keychain stringForKey: @"id_token"];
    if (refreshToken) {
        [[[A0APIClient sharedClient] fetchNewIdTokenWithRefreshToken:refreshToken parameters:nil] subscribeNext:^(A0Token *token) {
            @strongify(self);
            [self.keychain setString:token.idToken forKey:@"id_token"];
            [self performSegueWithIdentifier:@"LoggedIn" sender:self];
        } error:^(NSError *error) {
            @strongify(self);
            [self.keychain clearAll];
        }];
    } else if (idToken) {
        [self performSegueWithIdentifier:@"LoggedIn" sender:self];
    }

    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    self.clientIdLabel.text = info[kClientIdKey];
    self.tenantLabel.text = info[kTenantKey];
}

- (void)loginNative:(id)sender {
    A0Theme *theme = [A0Theme sharedInstance];
    theme.statusBarStyle = UIStatusBarStyleLightContent;
    [theme registerColor:[UIColor colorWithWhite:1.000 alpha:0.300] forKey:A0ThemePrimaryButtonNormalColor];
    [theme registerColor:[UIColor colorWithWhite:0.500 alpha:0.300] forKey:A0ThemePrimaryButtonHighlightedColor];
    [theme registerColor:[UIColor clearColor] forKey:A0ThemeSecondaryButtonBackgroundColor];
    [theme registerColor:[UIColor whiteColor] forKey:A0ThemeSecondaryButtonTextColor];
    [theme registerColor:[UIColor whiteColor] forKey:A0ThemeTextFieldTextColor];
    [theme registerColor:[UIColor whiteColor] forKey:A0ThemeTitleTextColor];
    [theme registerColor:[UIColor whiteColor] forKey:A0ThemeSeparatorTextColor];
    [theme registerColor:[UIColor whiteColor] forKey:A0ThemeDescriptionTextColor];
    [theme registerColor:[UIColor colorWithWhite:1.000 alpha:0.700] forKey:A0ThemeTextFieldPlaceholderTextColor];
    [theme registerColor:[UIColor colorWithWhite:0.800 alpha:1.000] forKey:A0ThemeTextFieldIconColor];
    [theme registerColor:[UIColor clearColor] forKey:A0ThemeIconBackgroundColor];
    [theme registerImageWithName:@"mindjet-icon" forKey:A0ThemeIconImageName];
    [theme registerImageWithName:@"mindjet-bg" forKey:A0ThemeScreenBackgroundImageName];

    [self.keychain clearAll];
    A0LockViewController *controller = [[A0LockViewController alloc] init];
    @weakify(self);
    controller.closable = YES;
    controller.loginAfterSignUp = YES;
    controller.usesEmail = YES;
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        NSLog(@"SUCCESS %@", profile);
        @strongify(self);
        [self.keychain setString:token.idToken forKey:@"id_token"];
        [self.keychain setString:token.refreshToken forKey:@"refresh_token"];
        [self.keychain setData:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:@"profile"];
        [self dismissViewControllerAnimated:YES completion:^(){
            [self performSegueWithIdentifier:@"LoggedIn" sender:self];
        }];
    };
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)loginTouchID:(id)sender {
    [self.keychain clearAll];
    A0TouchIDLockViewController *controller = [[A0TouchIDLockViewController alloc] init];
    controller.closable = YES;
    @weakify(self);
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        NSLog(@"SUCCESS %@", profile);
        @strongify(self);
        [self.keychain setString:token.idToken forKey:@"id_token"];
        [self.keychain setString:token.refreshToken forKey:@"refresh_token"];
        [self.keychain setData:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:@"profile"];
        [self dismissViewControllerAnimated:YES completion:^(){
            [self performSegueWithIdentifier:@"LoggedIn" sender:self];
        }];
    };
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)loginSMS:(id)sender {
    [self.keychain clearAll];
    A0SMSLockViewController *controller = [[A0SMSLockViewController alloc] init];
    controller.closable = YES;
    @weakify(self);
    controller.auth0APIToken = ^{
        NSString *v2APIToken = [[NSBundle mainBundle] infoDictionary][@"Auth0SendSMSAPIToken"];
        return v2APIToken;
    };

    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        NSLog(@"SUCCESS %@", profile);
        @strongify(self);
        [self.keychain setString:token.idToken forKey:@"id_token"];
        [self.keychain setString:token.refreshToken forKey:@"refresh_token"];
        [self.keychain setData:[NSKeyedArchiver archivedDataWithRootObject:profile] forKey:@"profile"];
        [self dismissViewControllerAnimated:YES completion:^(){
            [self performSegueWithIdentifier:@"LoggedIn" sender:self];
        }];
    };
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:navController animated:YES completion:nil];
}
@end
