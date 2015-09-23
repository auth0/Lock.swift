// A0EmailSendCodeViewController.m
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

#import "A0EmailSendCodeViewController.h"
#import "A0Theme.h"
#import "A0ProgressButton.h"
#import "A0CredentialFieldView.h"
#import "A0APIClient.h"
#import "A0RequestAccessTokenOperation.h"
#import "A0SendSMSOperation.h"
#import "A0Alert.h"
#import "A0EmailValidator.h"
#import "A0Errors.h"
#import "A0Lock.h"
#import "NSError+A0APIError.h"

#import <libextobjc/EXTScope.h>

@interface A0EmailSendCodeViewController ()

@property (weak, nonatomic) IBOutlet A0CredentialFieldView *emailFieldView;
@property (weak, nonatomic) IBOutlet A0ProgressButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (strong, nonatomic) A0EmailValidator *validator;

- (IBAction)registerSMS:(id)sender;

@end

@implementation A0EmailSendCodeViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = A0LocalizedString(@"Send Passcode");
    A0Theme *theme = [A0Theme sharedInstance];
    [theme configureTextField:self.emailFieldView.textField];
    [theme configurePrimaryButton:self.registerButton];
    [theme configureLabel:self.messageLabel];
    self.messageLabel.text = A0LocalizedString(@"Enter your email to sign in or create an account");
    [self.emailFieldView setFieldPlaceholderText:A0LocalizedString(@"Email")];
    [self.registerButton setTitle:A0LocalizedString(@"SEND") forState:UIControlStateNormal];

    self.emailFieldView.textField.text = self.currentEmail;
    self.validator = [[A0EmailValidator alloc] initWithField:self.emailFieldView.textField];
}

- (void)registerSMS:(id)sender {
    NSError *error = [self.validator validate];
    if (!error) {
        [self.emailFieldView setInvalid:NO];
        [self.emailFieldView.textField resignFirstResponder];
        A0LogDebug(@"Registering email %@", self.emailFieldView.textField.text);
        [self.registerButton setInProgress:YES];
        NSString *phoneNumber = self.emailFieldView.textField.text;
        @weakify(self);
        void(^onFailure)(NSError *) = ^(NSError *error) {
            @strongify(self);
            A0LogError(@"Failed to send SMS code with error %@", error);
            NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error sending the email code");
            NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : A0LocalizedString(@"Couldn't send the email with your login code. Please try again later.");
            [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                alert.title = title;
                alert.message = message;
            }];
            [self.registerButton setInProgress:NO];
        };
        A0LogDebug(@"About to send Email code to %@", phoneNumber);
        A0APIClient *client = self.lock.apiClient;
        [client startPasswordlessWithEmail:phoneNumber success:^{
            @strongify(self);
            A0LogDebug(@"Email code sent to %@", phoneNumber);
            [self.registerButton setInProgress:NO];
            if (self.onRegisterBlock) {
                self.onRegisterBlock(phoneNumber);
            }
        } failure:onFailure];
    } else {
        [self.emailFieldView setInvalid:YES];
        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
            alert.title = error.localizedDescription;
            alert.message = error.localizedFailureReason;
        }];
    }
}

#pragma mark - A0KeyboardEnabledView

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.registerButton.frame fromView:self.registerButton.superview];
    return rect;
}

- (void)hideKeyboard {
    [self.emailFieldView.textField resignFirstResponder];
}
@end
