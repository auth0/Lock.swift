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

#import <CoreGraphics/CoreGraphics.h>
#import <libextobjc/EXTScope.h>

static void showAlertErrorView(NSString *title, NSString *message) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                          otherButtonTitles:nil];
    [alert show];
}

@interface A0SignUpViewController ()

@property (weak, nonatomic) IBOutlet UIView *userContainerView;
@property (weak, nonatomic) IBOutlet UIView *passwordContainerView;

- (IBAction)signUp:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)goToPasswordField:(id)sender;

@end

@implementation A0SignUpViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Sign Up", nil);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userContainerView.layer.borderWidth = 1.0f;
    self.userContainerView.layer.borderColor = [[UIColor colorWithWhite:0.302 alpha:1.000] CGColor];
    self.passwordContainerView.layer.borderWidth = 1.0f;
    self.passwordContainerView.layer.borderColor = [[UIColor colorWithWhite:0.302 alpha:1.000] CGColor];

    [self.signUpButton setBackgroundColor:[UIColor colorWithRed:0.086 green:0.129 blue:0.302 alpha:1.000] forState:UIControlStateNormal];
    [self.signUpButton setBackgroundColor:[UIColor colorWithRed:0.043 green:0.063 blue:0.145 alpha:1.000] forState:UIControlStateHighlighted];
    self.signUpButton.layer.cornerRadius = 5;
    self.signUpButton.clipsToBounds = YES;
}

- (void)signUp:(id)sender {
    NSError *error;
    [self.signUpButton setInProgress:YES];
    [self.validator setUsername:self.userTextField.text password:self.passwordTextField.text];
    if ([self.validator validateCredential:&error]) {
        [self hideKeyboard];
        NSString *username = [self.userTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *password = self.passwordTextField.text;
        @weakify(self);
        A0APIClientAuthenticationSuccess success = ^(A0UserProfile *profile){
            @strongify(self);
            [self.signUpButton setInProgress:NO];
            if (self.onSignUpBlock) {
                self.onSignUpBlock(profile);
            }
        };
        A0APIClientError failure = ^(NSError *error) {
            [self.signUpButton setInProgress:NO];
            showAlertErrorView(NSLocalizedString(@"There was an error signing up", nil), [A0Errors localizedStringForLoginError:error]);
        };
        [[A0APIClient sharedClient] signUpWithUsername:username password:password success:success failure:failure];
    } else {
        [self.signUpButton setInProgress:NO];
        showAlertErrorView(error.localizedDescription, error.localizedFailureReason);
    }
    [self updateUIWithError:error];
}

- (void)goToPasswordField:(id)sender {
    [self.passwordTextField becomeFirstResponder];
}

- (void)cancel:(id)sender {
    if (self.onCancelBlock) {
        self.onCancelBlock();
    }
}

#pragma mark - A0KeyboardEnabledView

- (void)hideKeyboard {
    [self.userTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.signUpButton.frame fromView:self.signUpButton.superview];
    return rect;
}

#pragma mark - Error Handling

- (void)updateUIWithError:(NSError *)error {
    self.userTextField.textColor = [UIColor blackColor];
    self.passwordTextField.textColor = [UIColor blackColor];
    if (error) {
        switch (error.code) {
            case A0ErrorCodeInvalidCredentials:
                self.userTextField.textColor = [UIColor redColor];
                self.passwordTextField.textColor = [UIColor redColor];
                break;
            case A0ErrorCodeInvalidPassword:
                self.passwordTextField.textColor = [UIColor redColor];
                break;
            case A0ErrorCodeInvalidUsername:
                self.userTextField.textColor = [UIColor redColor];
                break;
        }
    }
}

@end
