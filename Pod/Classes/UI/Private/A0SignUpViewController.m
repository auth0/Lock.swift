//  A0SignUpViewController.m
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

#import "A0SignUpViewController.h"
#import "UIButton+A0SolidButton.h"
#import "A0Errors.h"
#import "A0SignUpCredentialValidator.h"
#import "A0ProgressButton.h"
#import "A0APIClient.h"
#import "A0Theme.h"
#import "A0CredentialFieldView.h"
#import "A0UIUtilities.h"
#import "A0PasswordFieldView.h"

#import <CoreGraphics/CoreGraphics.h>
#import <libextobjc/EXTScope.h>
#if __has_include("A0PasswordManager.h")
#import "A0PasswordManager.h"
#endif

@interface A0SignUpViewController ()

@property (weak, nonatomic) IBOutlet A0CredentialFieldView *userField;
@property (weak, nonatomic) IBOutlet A0PasswordFieldView *passwordField;
@property (weak, nonatomic) IBOutlet A0ProgressButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIView *disclaimerView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *credentialBoxView;

- (IBAction)signUp:(id)sender;
- (IBAction)goToPasswordField:(id)sender;

@end

@implementation A0SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = A0LocalizedString(@"Sign Up");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0Theme *theme = [A0Theme sharedInstance];
    [theme configurePrimaryButton:self.signUpButton];
    [theme configureTextField:self.userField.textField];
    [theme configureTextField:self.passwordField.textField];
    [theme configureLabel:self.messageLabel];

    self.userField.textField.placeholder = A0LocalizedString(@"Email");
    self.passwordField.textField.placeholder = A0LocalizedString(@"Password");
    [self.signUpButton setTitle:A0LocalizedString(@"SIGN UP") forState:UIControlStateNormal];
    self.messageLabel.text = A0LocalizedString(@"Please enter your email and password");

    [self.passwordField.passwordManagerButton addTarget:self action:@selector(storeLoginInfo:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    [self.passwordField.passwordManagerButton removeTarget:self action:@selector(storeLoginInfo:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)storeLoginInfo:(id)sender {
#ifdef AUTH0_1PASSWORD
    @weakify(self);
    [[A0PasswordManager sharedInstance] saveLoginInformationForUsername:self.userField.textField.text
                                                               password:self.passwordField.textField.text
                                                              loginInfo:nil
                                                             controller:self
                                                                 sender:sender
                                                             completion:^(NSString *username, NSString *password) {
                                                                 @strongify(self);
                                                                 self.userField.textField.text = username;
                                                                 self.passwordField.textField.text = password;
                                                                 [self signUp:sender];
                                                             }];
#endif
}

- (void)signUp:(id)sender {
    NSError *error;
    [self.signUpButton setInProgress:YES];
    [self.validator setUsername:self.userField.textField.text password:self.passwordField.textField.text];
    if ([self.validator validateCredential:&error]) {
        [self hideKeyboard];
        NSString *username = [self.userField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *password = self.passwordField.textField.text;
        @weakify(self);
        A0APIClientAuthenticationSuccess success = ^(A0UserProfile *profile, A0Token *token){
            @strongify(self);
            [self.signUpButton setInProgress:NO];
            if (self.onSignUpBlock) {
                self.onSignUpBlock(profile, token);
            }
        };
        A0APIClientError failure = ^(NSError *error) {
            [self.signUpButton setInProgress:NO];
            NSString *title = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error signing up");
            NSString *message = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [A0Errors localizedStringForSignUpError:error];
            A0ShowAlertErrorView(title, message);
        };
        [[A0APIClient sharedClient] signUpWithUsername:username
                                              password:password
                                        loginOnSuccess:self.shouldLoginUser
                                            parameters:self.parameters
                                               success:success failure:failure];
    } else {
        [self.signUpButton setInProgress:NO];
        A0ShowAlertErrorView(error.localizedDescription, error.localizedFailureReason);
    }
    [self updateUIWithError:error];
}

- (void)goToPasswordField:(id)sender {
    [self.passwordField.textField becomeFirstResponder];
}

- (void)addDisclaimerSubview:(UIView *)view {
    [self.disclaimerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.disclaimerView addSubview:view];
}

#pragma mark - A0KeyboardEnabledView

- (void)hideKeyboard {
    [self.userField.textField resignFirstResponder];
    [self.passwordField.textField resignFirstResponder];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.signUpButton.frame fromView:self.signUpButton.superview];
    return rect;
}

#pragma mark - Error Handling

- (void)updateUIWithError:(NSError *)error {
    self.userField.invalid = NO;
    self.passwordField.invalid = NO;
    if (error) {
        switch (error.code) {
            case A0ErrorCodeInvalidCredentials:
                self.userField.invalid = YES;
                self.passwordField.invalid = YES;
                break;
            case A0ErrorCodeInvalidPassword:
                self.passwordField.invalid = YES;
                break;
            case A0ErrorCodeInvalidUsername:
                self.userField.invalid = YES;
                break;
        }
    }
}

@end
