//  ViewController.m
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

#import "ViewController.h"

#import <Lock/Lock.h>
#import <SimpleKeychain/A0SimpleKeychain.h>
#import <Firebase/Firebase.h>

#define kFirebaseURLString @"https://sizzling-heat-5516.firebaseio.com/"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *idToken = [[A0SimpleKeychain keychain] stringForKey:@"id_token"];
    self.firstStepLabel.text = idToken ? [NSString stringWithFormat:@"Auth0 JWT %@", idToken] : nil;
    if (!idToken) {
        [self showLogin];
    }
}

- (IBAction)logout:(id)sender {
    [[A0SimpleKeychain keychain] clearAll];
    [self showLogin];
    self.secondStepLabel.text = nil;
    self.thirdStepLabel.text = nil;
}

- (IBAction)fetchFromFirebase:(id)sender {
    [self setInProgress:YES button:sender];
    A0APIClient *client = [A0APIClient sharedClient];
    NSString *jwt = [[A0SimpleKeychain keychain] stringForKey:@"id_token"];
    A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{
                                                                         A0ParameterAPIType: @"firebase",
                                                                         @"id_token": jwt,
                                                                         }];
    [client fetchDelegationTokenWithParameters:parameters
                                       success:^(NSDictionary *credentials) {
                                           NSString *firebaseToken = credentials[@"id_token"];
                                           self.secondStepLabel.text = [NSString stringWithFormat:@"Firebase JWT %@", firebaseToken];
                                           NSLog(@"Obtained Firebase credentials %@", credentials);
                                           Firebase *ref = [[Firebase alloc] initWithUrl:kFirebaseURLString];
                                           [ref authWithCustomToken:firebaseToken withCompletionBlock:^(NSError *error, FAuthData *authData) {
                                               if (!error) {
                                                   self.thirdStepLabel.text = [authData description];
                                                   NSLog(@"Obtained data %@", authData);
                                               } else {
                                                   self.thirdStepLabel.text = error.localizedDescription;
                                                   NSLog(@"Failed to auth with Firebase. Error %@", error);
                                               }
                                               [self setInProgress:NO button:sender];
                                           }];
                                       }
                                       failure:^(NSError *error) {
                                           self.secondStepLabel.text = error.localizedDescription;
                                           NSLog(@"An error ocurred %@", error);
                                           [self setInProgress:NO button:sender];
                                       }];
}

- (void)setInProgress:(BOOL)inProgress button:(UIButton *)button {
    if (inProgress) {
        button.enabled = NO;
        [self.activityIndicator startAnimating];
        self.activityIndicator.hidden = NO;
        self.secondStepLabel.text = nil;
        self.thirdStepLabel.text = nil;
    } else {
        button.enabled = YES;
        [self.activityIndicator stopAnimating];
    }

}

- (void)showLogin {
    A0LockViewController *lock = [[A0LockViewController alloc] init];
    lock.closable = NO;
    lock.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        [[A0SimpleKeychain keychain] setString:token.idToken forKey:@"id_token"];
        [self dismissViewControllerAnimated:YES completion:nil];
        self.firstStepLabel.text = [NSString stringWithFormat:@"Auth0 JWT %@", token.idToken];
    };
    [self presentViewController:lock animated:YES completion:nil];
}

@end
