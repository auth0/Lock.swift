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

#import "UIViewController+LockNotification.h"
#import "A0AuthParameters.h"
#import "A0Connection.h"

#import <CoreGraphics/CoreGraphics.h>
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "NSError+A0APIError.h"
#import "NSError+A0LockErrors.h"
#import "Constants.h"
#import "A0SignUpView.h"
#import "A0Connection+DatabaseValidation.h"
#import <Masonry/Masonry.h>

@interface A0SignUpViewController () <A0SignUpViewDelegate>

@property (weak, nonatomic) UIView *disclaimerContainerView;
@property (weak, nonatomic) UIView *userDisclaimerView;
@property (weak, nonatomic) A0SignUpView *signUpView;

@property (assign, nonatomic) BOOL requiresUsername;

@end

@implementation A0SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = A0LocalizedString(@"Sign Up");
    self.requiresUsername = [self.defaultConnection[A0ConnectionRequiresUsername] boolValue];

    A0Theme *theme = [A0Theme sharedInstance];

    A0SignUpView *signUpView = [[A0SignUpView alloc] initWithTheme:theme requiresUsername:self.requiresUsername];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];

    [self.view addSubview:signUpView];
    [self.view addSubview:containerView];

    [signUpView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.centerY.equalTo(self.view.mas_centerY);
    }];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.and.right.equalTo(self.view);
        make.top.equalTo(signUpView.mas_bottom);
    }];
    self.disclaimerContainerView = containerView;
    self.signUpView = signUpView;
    [self layoutDisclaimerView:self.userDisclaimerView];


    self.signUpView.identifierType = self.forceUsername ? A0SignUpIndentifierTypeUsername : A0SignUpIndentifierTypeEmail;
    self.signUpView.title = self.customMessage;
    self.signUpView.delegate = self;
    self.signUpView.identifier = _identifier;

    A0UsernameValidationInfo info;
    if (self.defaultConnection) {
        self.parameters[A0ParameterConnection] = self.defaultConnection.name;
        info = self.defaultConnection.usernameValidation;
    } else {
        info.min = 1;
        info.max = 15;
    }

    NSMutableArray *validators = [@[
                                    [[A0PasswordValidator alloc] initWithField:signUpView.passwordField.textField],
                                    ] mutableCopy];
    if (self.requiresUsername) {
        [validators addObject:[[A0EmailValidator alloc] initWithField:signUpView.identifierField.textField]];
        [validators addObject:[A0UsernameValidator databaseValidatorForField:signUpView.usernameField.textField withMinimum:info.min andMaximum:info.max]];
    } else if (self.forceUsername) {
        [validators addObject:[A0UsernameValidator nonEmtpyValidatorForField:signUpView.identifierField.textField]];
    } else {
        [validators addObject:[[A0EmailValidator alloc] initWithField:signUpView.identifierField.textField]];
    }
    self.validator = [[A0CredentialsValidator alloc] initWithValidators:validators];
}

- (void)addDisclaimerSubview:(UIView *)view {
    self.userDisclaimerView = view;
}

- (NSString *)identifier {
    return self.signUpView ? self.signUpView.identifier : _identifier;
}

#pragma mark - A0KeyboardEnabledView

- (void)hideKeyboard {
    [self.signUpView resignFirstResponder];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.signUpView.submitButton.frame fromView:self.signUpView.submitButton.superview];
    return rect;
}

#pragma mark - Error Handling

- (void)updateUIWithError:(NSError *)error {
    if (!error) {
        self.signUpView.identifierValid = YES;
        self.signUpView.usernameValid = YES;
        self.signUpView.passwordValid = YES;
        return;
    }
    NSInteger code = error.code;
    self.signUpView.identifierValid = code != A0ErrorCodeInvalidCredentials && ((self.requiresUsername && code != A0ErrorCodeInvalidEmail) || (!self.requiresUsername && code != A0ErrorCodeInvalidUsername));
    self.signUpView.usernameValid = code != A0ErrorCodeInvalidCredentials && code != A0ErrorCodeInvalidUsername;
    self.signUpView.passwordValid = code != A0ErrorCodeInvalidCredentials && code != A0ErrorCodeInvalidPassword;
}

#pragma mark - A0SignUpViewDelegate

- (void)signUpView:(A0SignUpView *)signUpView didSubmitWithCompletionHandler:(A0SignUpViewCompletionHandler)completionHandler {
    NSError *error = [self.validator validate];
    if (!error) {
        [self hideKeyboard];
        NSString *email = self.signUpView.identifier;
        NSString *username = self.signUpView.username;
        NSString *password = self.signUpView.password;
        A0APIClientAuthenticationSuccess success = ^(A0UserProfile *profile, A0Token *token){
            [self postSignUpSuccessfulWithEmail:email];
            if (token) {
                [self postLoginSuccessfulWithUsername:email andParameters:self.parameters];
            }
            if (self.onSignUpBlock) {
                self.onSignUpBlock(profile, token);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(YES);
            });
        };
        A0APIClientError failure = ^(NSError *error) {
            [self postSignUpErrorNotificationWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([error a0_mfaRequired]) {
                    completionHandler(YES);
                    self.onMFARequired();
                    return;
                }
                NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error signing up");
                NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [error a0_localizedStringForSignUpError];
                [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                    alert.title = title;
                    alert.message = message;
                }];
                completionHandler(NO);
            });
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
        completionHandler(NO);
        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
            alert.title = A0LocalizedString(@"Invalid credentials");
            alert.message = error.localizedFailureReason;
        }];
    }
    [self updateUIWithError:error];
}

#pragma mark - Utility methods

- (void)layoutDisclaimerView:(UIView *)disclaimerView {
    [self.disclaimerContainerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if (!disclaimerView) {
        return;
    }
    [self.disclaimerContainerView addSubview:disclaimerView];
    [disclaimerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.disclaimerContainerView);
    }];
}
@end
