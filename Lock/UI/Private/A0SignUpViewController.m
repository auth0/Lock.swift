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
#import "A0ProgressButton.h"
#import "A0APIClient.h"
#import "A0Theme.h"
#import "A0CredentialFieldView.h"
#import "A0Alert.h"
#import "A0PasswordFieldView.h"
#import "A0CredentialsValidator.h"
#import "A0EmailValidator.h"
#import "A0UsernameValidator.h"
#import "A0PasswordValidator.h"

#if __has_include("A0PasswordManager.h")
#import "A0PasswordManager.h"
#endif
#import "UIViewController+LockNotification.h"
#import "A0AuthParameters.h"
#import "A0Connection.h"

#import <CoreGraphics/CoreGraphics.h>
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "NSError+A0APIError.h"
#import "Constants.h"

@interface A0SignUpViewController ()

@property (weak, nonatomic) IBOutlet A0CredentialFieldView *usernameField;
@property (weak, nonatomic) IBOutlet A0CredentialFieldView *userField;
@property (weak, nonatomic) IBOutlet A0PasswordFieldView *passwordField;
@property (weak, nonatomic) IBOutlet A0ProgressButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIView *disclaimerContainerView;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *credentialBoxView;
@property (weak, nonatomic) IBOutlet UIView *usernameSeparatorView;
@property (weak, nonatomic) UIView *userDisclaimerView;

@property (assign, nonatomic) BOOL requiresUsername;

- (IBAction)signUp:(id)sender;
- (IBAction)goToPasswordField:(id)sender;

@end

@implementation A0SignUpViewController

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

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
    [theme configureTextField:self.usernameField.textField];
    [theme configureTextField:self.userField.textField];
    [theme configureTextField:self.passwordField.textField];
    [theme configureLabel:self.messageLabel];

    self.requiresUsername = [self.defaultConnection[A0ConnectionRequiresUsername] boolValue];
    if (!self.requiresUsername) {
        [self.usernameField removeFromSuperview];
        [self.usernameSeparatorView removeFromSuperview];
        [self.credentialBoxView addConstraint:[NSLayoutConstraint constraintWithItem:self.userField attribute:NSLayoutAttributeTop relatedBy: NSLayoutRelationEqual toItem:self.credentialBoxView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    }
    [self.usernameField setFieldPlaceholderText:A0LocalizedString(@"Username")];
    [self.userField setFieldPlaceholderText:self.forceUsername && !self.requiresUsername ? A0LocalizedString(@"Username") : A0LocalizedString(@"Email")];
    [self.passwordField setFieldPlaceholderText:A0LocalizedString(@"Password")];
    [self.signUpButton setTitle:A0LocalizedString(@"SIGN UP") forState:UIControlStateNormal];
    self.messageLabel.text = self.forceUsername ? A0LocalizedString(@"Please enter your username and password") : A0LocalizedString(@"Please enter your email and password");
    if (self.customMessage) {
        self.messageLabel.text = self.customMessage;
    }

    [self.passwordField.passwordManagerButton addTarget:self action:@selector(storeLoginInfo:) forControlEvents:UIControlEventTouchUpInside];

    if (self.defaultConnection) {
        self.parameters[A0ParameterConnection] = self.defaultConnection.name;
    }
    NSMutableArray *validators = [@[
                                    [[A0PasswordValidator alloc] initWithField:self.passwordField.textField],
                                    ] mutableCopy];
    if (self.requiresUsername) {
        [validators addObject:[[A0EmailValidator alloc] initWithField:self.userField.textField]];
        [validators addObject:[[A0UsernameValidator alloc] initWithField:self.usernameField.textField]];
    } else if (self.forceUsername) {
        [validators addObject:[[A0UsernameValidator alloc] initWithField:self.userField.textField]];
    } else {
        [validators addObject:[[A0EmailValidator alloc] initWithField:self.userField.textField]];
    }
    self.validator = [[A0CredentialsValidator alloc] initWithValidators:validators];
    [self layoutDisclaimerView:self.userDisclaimerView];
}

- (void)dealloc {
    [self.passwordField.passwordManagerButton removeTarget:self action:@selector(storeLoginInfo:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)storeLoginInfo:(id)sender {
#ifdef AUTH0_1PASSWORD
    UITextField *userField = self.usernameField.textField ?: self.userField.textField;
    [[A0PasswordManager sharedInstance] saveLoginInformationForUsername:userField.text
                                                               password:self.passwordField.textField.text
                                                              loginInfo:@{
                                                                          @"email": self.userField.textField,
                                                                          }
                                                             controller:self
                                                                 sender:sender
                                                             completion:^(NSString *username, NSString *password) {
                                                                 userField.text = username;
                                                                 self.passwordField.textField.text = password;
                                                                 [self signUp:sender];
                                                             }];
#endif
}

- (void)signUp:(id)sender {
    [self.signUpButton setInProgress:YES];
    NSError *error = [self.validator validate];
    if (!error) {
        [self hideKeyboard];
        NSString *email = [self.userField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *username = [self.usernameField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *password = self.passwordField.textField.text;
        A0APIClientAuthenticationSuccess success = ^(A0UserProfile *profile, A0Token *token){
            [self postSignUpSuccessfulWithEmail:email];
            if (token) {
                [self postLoginSuccessfulWithUsername:email andParameters:self.parameters];
            }
            [self.signUpButton setInProgress:NO];
            if (self.onSignUpBlock) {
                self.onSignUpBlock(profile, token);
            }
        };
        A0APIClientError failure = ^(NSError *error) {
            [self postSignUpErrorNotificationWithError:error];
            [self.signUpButton setInProgress:NO];
            NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error signing up");
            NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [A0Errors localizedStringForSignUpError:error];
            [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                alert.title = title;
                alert.message = message;
            }];
        };
        A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
        [client signUpWithEmail:email
                       username:username
                       password:password
                 loginOnSuccess:self.shouldLoginUser
                     parameters:self.parameters
                        success:success
                        failure:failure];
    } else {
        [self postSignUpErrorNotificationWithError:error];
        [self.signUpButton setInProgress:NO];
        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
            alert.title = A0LocalizedString(@"Invalid credentials");
            alert.message = error.localizedFailureReason;
        }];
    }
    [self updateUIWithError:error];
}

- (IBAction)goToEmailField:(id)sender {
    [self.userField.textField becomeFirstResponder];
}

- (IBAction)goToPasswordField:(id)sender {
    [self.passwordField.textField becomeFirstResponder];
}

- (void)addDisclaimerSubview:(UIView *)view {
    self.userDisclaimerView = view;
}

#pragma mark - A0KeyboardEnabledView

- (void)hideKeyboard {
    [self.usernameField.textField resignFirstResponder];
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
    self.usernameField.invalid = NO;
    if (error) {
        switch (error.code) {
            case A0ErrorCodeInvalidCredentials:
                self.userField.invalid = YES;
                self.passwordField.invalid = YES;
                self.usernameField.invalid = YES;
                break;
            case A0ErrorCodeInvalidPassword:
                self.passwordField.invalid = YES;
                break;
            case A0ErrorCodeInvalidUsername:
                if (self.requiresUsername) {
                    self.usernameField.invalid = YES;
                } else {
                    self.userField.invalid = YES;
                }
                break;
            case A0ErrorCodeInvalidEmail:
                self.userField.invalid = YES;
                break;
        }
    }
}

#pragma mark - Utility methods

- (void)layoutDisclaimerView:(UIView *)disclaimerView {
    [self.disclaimerContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!disclaimerView) {
        return;
    }
    [self.disclaimerContainerView addSubview:disclaimerView];
    disclaimerView.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(disclaimerView);
    [self.disclaimerContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[disclaimerView]-|" options:0 metrics:nil views:views]];
    [self.disclaimerContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-[disclaimerView]-|" options:0 metrics:nil views:views]];
}
@end
