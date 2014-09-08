// A0ViewController.m
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

#import "A0ViewController.h"

#import "A0UserProfileViewController.h"
#import <Auth0Client/A0AuthenticationViewController.h>
#import <Auth0Client/A0FacebookAuthentication.h>
#import <Auth0Client/A0TwitterAuthentication.h>
#import <Auth0Client/A0SocialAuthenticator.h>
#import <Auth0Client/A0AuthCore.h>
#import <libextobjc/EXTScope.h>

@interface A0ViewController ()

@property (strong, nonatomic) A0UserProfile *authInfo;
@property (strong, nonatomic) A0Session *session;

@end

@implementation A0ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    A0TwitterAuthentication *twitter = [A0TwitterAuthentication newAuthenticationWithKey:@"o8HFHDVB1yEVXSvxSO5F1WuKP"
                                                                               andSecret:@"v04WbftIrRJENoTFAr91eCEgLmVCDcaEm5brZlLJtS0ccJjHIz"
                                                                             callbackURL:[NSURL URLWithString:@"com.auth0.Auth0Client://twitter-auth"]];
    A0FacebookAuthentication *facebook = [A0FacebookAuthentication newAuthenticationWithDefaultPermissions];
    [[A0SocialAuthenticator sharedInstance] registerSocialAuthenticatorProviders:@[
                                                                                   twitter,
                                                                                   facebook,
                                                                                   ]];

    self.session = [A0Session newDefaultSession];
    @weakify(self);
    [self.session refreshWithSuccess:^(A0UserProfile *profile, A0Token *token) {
        @strongify(self);
        [self loadSessionInfoWithToken:token];
    } failure:^(NSError *error) {
        @strongify(self);
        [self clearSessionInfo];
    }];
}

- (void)signIn:(id)sender {
    [self clearSession:nil];
    A0AuthenticationViewController *controller = [[A0AuthenticationViewController alloc] init];
    @weakify(self);
    controller.allowDismiss = YES;
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        NSLog(@"SUCCESS %@", profile);
        @strongify(self);
        self.authInfo = profile;
        [self.session.dataSource storeToken:token andUserProfile:profile];
        [self loadSessionInfoWithToken:token];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)showProfileInfo:(id)sender {
    [self performSegueWithIdentifier:@"ShowInfo" sender:self];
}

- (IBAction)refreshSession:(id)sender {
    @weakify(self);
    [self.session renewWithSuccess:^(A0UserProfile *profile, A0Token *token) {
        @strongify(self);
        [self loadSessionInfoWithToken:token];
    } failure:^(NSError *error) {
        @strongify(self);
        [self clearSessionInfo];
    }];
}

- (IBAction)clearSession:(id)sender {
    [self.session clear];
    [self clearSessionInfo];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowInfo"]) {
        A0UserProfileViewController *controller = segue.destinationViewController;
        controller.authInfo = self.authInfo;
    }
}

- (void)clearSessionInfo {
    self.signInButton.enabled = YES;
    self.refreshButton.enabled = NO;
    self.showProfileButton.enabled = NO;
    self.idTokenLabel.text = nil;
    self.expiresLabel.text = nil;
    self.refreshTokenLabel.text = nil;
    self.welcomeLabel.text = @"No Session found";
}

- (void)loadSessionInfoWithToken:(A0Token *)token {
    A0UserProfile *profile = self.session.profile;
    self.authInfo = profile;
    self.refreshButton.enabled = YES;
    self.showProfileButton.enabled = YES;
    self.idTokenLabel.text = token.idToken;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.expiresLabel.text = [formatter stringFromDate:token.expiresAt];
    self.refreshTokenLabel.text = token.refreshToken;
    self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome %@!", profile.name];
    self.signInButton.enabled = NO;
}

@end
