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

@interface A0ChangePasswordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *credentialBoxView;
@property (weak, nonatomic) IBOutlet A0ProgressButton *recoverButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (IBAction)recover:(id)sender;

@end

@implementation A0ChangePasswordViewController

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = A0LocalizedString(@"Reset Password");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0Theme *theme = [A0Theme sharedInstance];
    [theme configurePrimaryButton:self.recoverButton];
    [theme configureSecondaryButton:self.cancelButton];
    [theme configureLabel:self.messageLabel];
    [theme configureTextField:self.userField.textField];

    self.userField.textField.text = self.defaultEmail;
    [self.userField setFieldPlaceholderText:A0LocalizedString(@"Email")];
    [self.recoverButton setTitle:A0LocalizedString(@"SEND") forState:UIControlStateNormal];
    self.messageLabel.text = A0LocalizedString(@"Please enter your email address. We will send you an email to reset your password.");

    if (self.defaultConnection) {
        self.parameters[A0ParameterConnection] = self.defaultConnection.name;
    }

    if (self.forceUsername) {
        self.validator = [[A0UsernameValidator alloc] initWithField:self.userField.textField];
    } else {
        self.validator = [[A0EmailValidator alloc] initWithField:self.userField.textField];
    }
}

- (IBAction)recover:(id)sender {
    [self.recoverButton setInProgress:YES];
    NSError *error = [self.validator validate];
    if (!error) {
        [self hideKeyboard];
        NSString *username = [self.userField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        void(^success)() = ^ {
            [self postChangePasswordSuccessfulWithEmail:username];
            [self.recoverButton setInProgress:NO];
            [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                alert.title = A0LocalizedString(@"Reset Password");
                alert.message = A0LocalizedString(@"We've just sent you an email to reset your password.");
            }];
            if (self.onChangePasswordBlock) {
                self.onChangePasswordBlock();
            }
        };
        A0APIClientError failure = ^(NSError *error) {
            [self postChangePasswordErrorNotificationWithError:error];
            [self.recoverButton setInProgress:NO];
            NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"Couldn't request to reset your password");
            NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [A0Errors localizedStringForChangePasswordError:error];
            [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                alert.title = title;
                alert.message = message;
            }];
        };
        A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
        [client requestChangePasswordForUsername:username parameters:self.parameters success:success failure:failure];
    } else {
        [self.recoverButton setInProgress:NO];
        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
            alert.title = error.localizedDescription;
            alert.message = error.localizedFailureReason;
        }];
    }
    [self updateUIWithError:error];
}

- (void)hideKeyboard {
    [self.userField.textField resignFirstResponder];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect buttonFrame = [view convertRect:self.recoverButton.frame fromView:self.recoverButton.superview];
    return buttonFrame;
}

- (void)updateUIWithError:(NSError *)error {
    self.userField.invalid = NO;
    if (error) {
        switch (error.code) {
            case A0ErrorCodeInvalidUsername:
            case A0ErrorCodeInvalidEmail:
                self.userField.invalid = YES;
                break;
        }
    }
}

@end
