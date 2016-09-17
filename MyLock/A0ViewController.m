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
#import <Lock/Lock.h>
#import <SimpleKeychain/A0SimpleKeychain.h>
#import <JWTDecode/JWTDecode.h>

@interface A0ViewController ()

@property (strong, nonatomic) A0SimpleKeychain *keychain;

@end

@implementation A0ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keychain = [A0SimpleKeychain keychainWithService:@"Auth0"];
    NSString* token = [self.keychain stringForKey: @"id_token"];
    [self loadSessionInfoWithToken:token];
    [self.refreshButton addTarget:self action:@selector(refreshToken:) forControlEvents:UIControlEventTouchUpInside];
}

- (IBAction)clearSession:(id)sender {
    [self.keychain clearAll];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowInfo"]) {
        A0UserProfileViewController *controller = segue.destinationViewController;
        controller.authInfo = [NSKeyedUnarchiver unarchiveObjectWithData:[self.keychain dataForKey:@"profile"]];
    }
}

- (void)loadSessionInfoWithToken:(NSString *)token {
    A0UserProfile *profile = [NSKeyedUnarchiver unarchiveObjectWithData:[self.keychain dataForKey:@"profile"]];
    self.refreshButton.enabled = YES;
    NSString* refreshToken = [self.keychain stringForKey: @"refresh_token"];
    self.idTokenLabel.text = token;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateStyle = NSDateFormatterShortStyle;
    formatter.timeStyle = NSDateFormatterShortStyle;
    self.expiresLabel.text = [formatter stringFromDate:[[A0JWT decodeWithJwt:token error:nil] expiresAt]];
    self.refreshTokenLabel.text = refreshToken;
    self.welcomeLabel.text = profile.name;
}

- (void)refreshToken:(UIButton *)button {
    NSString* refreshToken = [self.keychain stringForKey: @"refresh_token"];
    A0APIClient *client = [[A0Lock sharedLock] apiClient];
    [client fetchNewIdTokenWithRefreshToken:refreshToken parameters:nil success:^(A0Token * _Nonnull token) {
        [self.keychain setString:token.idToken forKey:@"id_token"];
        [self loadSessionInfoWithToken:token.idToken];
    } failure:^(NSError * _Nonnull error) {
        [self.keychain clearAll];
    }];
}
@end
