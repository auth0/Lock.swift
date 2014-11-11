//  A0ChangePasswordViewController.m
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

#import "A0ChangePasswordViewController.h"
#import "UIButton+A0SolidButton.h"
#import "A0Errors.h"
#import "A0ChangePasswordCredentialValidator.h"
#import "A0ProgressButton.h"
#import "A0APIClient.h"
#import "A0Theme.h"
#import "A0CredentialFieldView.h"

#import <CoreGraphics/CoreGraphics.h>
#import <libextobjc/EXTScope.h>

static void showAlertErrorView(NSString *title, NSString *message) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:A0LocalizedString(@"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

@interface A0ChangePasswordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *credentialBoxView;
@property (weak, nonatomic) IBOutlet A0CredentialFieldView *passwordField;
@property (weak, nonatomic) IBOutlet A0CredentialFieldView *repeatPasswordField;
@property (weak, nonatomic) IBOutlet A0ProgressButton *recoverButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)recover:(id)sender;
- (IBAction)goToPasswordField:(id)sender;
- (IBAction)goToRepeatPasswordField:(id)sender;

@end

@implementation A0ChangePasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = A0LocalizedString(@"Reset Password");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.credentialBoxView.layer.borderWidth = 1.0f;
    self.credentialBoxView.layer.borderColor = [[UIColor colorWithWhite:0.600 alpha:1.000] CGColor];
    self.credentialBoxView.layer.cornerRadius = 3.0f;

    A0Theme *theme = [A0Theme sharedInstance];
    [theme configurePrimaryButton:self.recoverButton];
    [theme configureSecondaryButton:self.cancelButton];
    [theme configureLabel:self.messageLabel];
    [theme configureTextField:self.userField.textField];
    [theme configureTextField:self.passwordField.textField];
    [theme configureTextField:self.repeatPasswordField.textField];
    self.userField.textField.text = self.defaultEmail;
    self.userField.textField.placeholder = A0LocalizedString(@"Email");
    self.passwordField.textField.placeholder = A0LocalizedString(@"Password");
    self.repeatPasswordField.textField.placeholder = A0LocalizedString(@"Confirm New Password");
    [self.recoverButton setTitle:A0LocalizedString(@"SEND") forState:UIControlStateNormal];
    self.messageLabel.text = A0LocalizedString(@"Please enter your email and the new password. We will send you an email to confirm the password change.");
}

- (IBAction)recover:(id)sender {
    [self.recoverButton setInProgress:YES];
    NSError *error;
    [self.validator setUsername:self.userField.textField.text password:self.passwordField.textField.text repeatPassword:self.repeatPasswordField.textField.text];
    if ([self.validator validateCredential:&error]) {
        [self hideKeyboard];
        NSString *username = [self.userField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *password = self.passwordField.textField.text;
        @weakify(self);
        void(^success)() = ^ {
            @strongify(self);
            [self.recoverButton setInProgress:NO];
            showAlertErrorView(A0LocalizedString(@"Reset Password"), A0LocalizedString(@"We've just sent you an email to reset your password."));
            if (self.onChangePasswordBlock) {
                self.onChangePasswordBlock();
            }
        };
        A0APIClientError failure = ^(NSError *error) {
            @strongify(self);
            [self.recoverButton setInProgress:NO];
            showAlertErrorView(A0LocalizedString(@"Couldn't change your password"), [A0Errors localizedStringForChangePasswordError:error]);
        };
        [[A0APIClient sharedClient] changePassword:password
                                       forUsername:username
                                        parameters:self.parameters
                                           success:success
                                           failure:failure];

    } else {
        [self.recoverButton setInProgress:NO];
        showAlertErrorView(error.localizedDescription, error.localizedFailureReason);
    }
    [self updateUIWithError:error];
}

- (IBAction)goToPasswordField:(id)sender {
    [self.passwordField.textField becomeFirstResponder];
}

- (IBAction)goToRepeatPasswordField:(id)sender {
    [self.repeatPasswordField.textField becomeFirstResponder];
}

- (void)hideKeyboard {
    [self.userField.textField resignFirstResponder];
    [self.passwordField.textField resignFirstResponder];
    [self.repeatPasswordField.textField resignFirstResponder];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect buttonFrame = [view convertRect:self.recoverButton.frame fromView:self.recoverButton.superview];
    return buttonFrame;
}

- (void)updateUIWithError:(NSError *)error {
    self.userField.invalid = NO;
    self.passwordField.invalid = NO;
    self.repeatPasswordField.invalid = NO;
    if (error) {
        switch (error.code) {
            case A0ErrorCodeInvalidCredentials:
                self.userField.invalid = YES;
                self.passwordField.invalid = YES;
                self.repeatPasswordField.invalid = YES;
                break;
            case A0ErrorCodeInvalidPassword:
                self.passwordField.invalid = YES;
                break;
            case A0ErrorCodeInvalidUsername:
                self.userField.invalid = YES;
                break;
            case A0ErrorCodeInvalidRepeatPassword:
                self.repeatPasswordField.invalid = YES;
                break;
            case A0ErrorCodeInvalidPasswordAndRepeatPassword:
                self.passwordField.invalid = YES;
                self.repeatPasswordField.invalid = YES;
                break;
        }
    }
}

@end
