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
#import "A0ProgressButton.h"
#import "A0APIClient.h"
#import "A0Theme.h"
#import "A0CredentialFieldView.h"
#import "A0Alert.h"
#import "UIViewController+LockNotification.h"
#import "A0AuthParameters.h"
#import "A0Connection.h"
#import "A0CredentialsValidator.h"
#import "A0UsernameValidator.h"
#import "A0EmailValidator.h"
#import "A0PasswordValidator.h"
#import <CoreGraphics/CoreGraphics.h>
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "NSError+A0APIError.h"
#import "Constants.h"
#import "A0ChangePasswordView.h"
#import <Masonry/Masonry.h>
#import "NSError+A0LockErrors.h"

@interface A0ChangePasswordViewController () <A0ChangePasswordViewDelegate>

@property (weak, nonatomic) A0ChangePasswordView *changePasswordView;

@end

@implementation A0ChangePasswordViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = A0LocalizedString(@"Reset Password");

    A0Theme *theme = [A0Theme sharedInstance];

    A0ChangePasswordView *changePasswordView = [[A0ChangePasswordView alloc] initWithTheme:theme];
    [self.view addSubview:changePasswordView];
    [changePasswordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    changePasswordView.delegate = self;
    changePasswordView.identifier = self.email;
    changePasswordView.identifierType = self.forceUsername ? A0ChangePasswordIndentifierTypeUsername : A0ChangePasswordIndentifierTypeEmail;

    if (self.defaultConnection) {
        self.parameters[A0ParameterConnection] = self.defaultConnection.name;
    }

    if (self.forceUsername) {
        self.validator = [A0UsernameValidator nonEmtpyValidatorForField:changePasswordView.identifierField.textField];
    } else {
        self.validator = [[A0EmailValidator alloc] initWithField:changePasswordView.identifierField.textField];
    }
    self.changePasswordView = changePasswordView;
}

- (NSString *)email {
    return self.changePasswordView ? self.changePasswordView.identifier : _email;
}

- (void)hideKeyboard {
    [self.changePasswordView resignFirstResponder];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect buttonFrame = [view convertRect:self.changePasswordView.submitButton.frame fromView:self.changePasswordView.submitButton.superview];
    return buttonFrame;
}

- (void)updateUIWithError:(NSError *)error {
    self.changePasswordView.identifierValid = !error;
}

- (void)changePasswordView:(A0ChangePasswordView *)changePasswordView didSubmitWithCompletionHandler:(A0ChangePasswordViewCompletionHandler)completionHandler {
    NSError *error = [self.validator validate];
    if (!error) {
        [self hideKeyboard];
        NSString *username = self.changePasswordView.identifier;
        void(^success)() = ^ {
            [self postChangePasswordSuccessfulWithEmail:username];
            dispatch_async(dispatch_get_main_queue(), ^{
                [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                    alert.title = A0LocalizedString(@"Reset Password");
                    alert.message = A0LocalizedString(@"We've just sent you an email to reset your password.");
                }];
                if (self.onChangePasswordBlock) {
                    self.onChangePasswordBlock();
                }
                completionHandler(YES);
            });
        };
        A0APIClientError failure = ^(NSError *error) {
            [self postChangePasswordErrorNotificationWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"Couldn't request to reset your password");
                NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [error a0_localizedStringForChangePasswordError];
                [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                    alert.title = title;
                    alert.message = message;
                }];
                completionHandler(NO);
            });
        };
        A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
        [client requestChangePasswordForUsername:username parameters:self.parameters success:success failure:failure];
    } else {
        completionHandler(NO);
        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
            alert.title = error.localizedDescription;
            alert.message = error.localizedFailureReason;
        }];
    }
    [self updateUIWithError:error];
}
@end
