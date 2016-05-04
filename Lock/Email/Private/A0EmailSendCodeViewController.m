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
#import "A0Alert.h"
#import "A0Errors.h"
#import "NSError+A0APIError.h"
#import "NSError+A0LockErrors.h"
#import "A0PasswordlessLockViewModel.h"
#import "Constants.h"
#import "A0RoundedBoxView.h"
#import <Masonry/Masonry.h>

@interface A0EmailSendCodeViewController ()

@property (weak, nonatomic) A0CredentialFieldView *emailFieldView;
@property (weak, nonatomic) A0ProgressButton *registerButton;
@property (weak, nonatomic) UILabel *messageLabel;

@property (strong, nonatomic) A0PasswordlessLockViewModel *viewModel;
- (IBAction)registerEmail:(id)sender;

@end

@implementation A0EmailSendCodeViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)initWithViewModel:(A0PasswordlessLockViewModel *)viewModel {
    self = [super init];
    if (self) {
        _viewModel = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0CredentialFieldView *emailField = [[A0CredentialFieldView alloc] init];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    A0ProgressButton *registerButton = [A0ProgressButton progressButton];
    A0RoundedBoxView *boxView = [[A0RoundedBoxView alloc] init];

    [boxView addSubview:emailField];
    [emailField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(boxView);
    }];

    [self.view addSubview:messageLabel];
    [self.view addSubview:boxView];
    [self.view addSubview:registerButton];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view).offset(10);
    }];
    [boxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.top.equalTo(messageLabel.mas_bottom).offset(8);
        make.height.equalTo(@50);
    }];
    [registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(boxView.mas_bottom).offset(18);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view);
        make.height.equalTo(@55);
    }];

    self.emailFieldView = emailField;
    self.messageLabel = messageLabel;
    self.registerButton = registerButton;

    self.title = A0LocalizedString(@"Send Passcode");
    A0Theme *theme = [A0Theme sharedInstance];
    [theme configurePrimaryButton:self.registerButton];
    [theme configureLabel:self.messageLabel];

    self.messageLabel.text = A0LocalizedString(@"Enter your email to sign in or create an account");
    self.emailFieldView.type = A0CredentialFieldViewEmail;
    self.emailFieldView.returnKeyType = UIReturnKeySend;
    [self.emailFieldView.textField addTarget:self action:@selector(registerEmail:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.registerButton setTitle:A0LocalizedString(@"SEND") forState:UIControlStateNormal];
    [self.registerButton addTarget:self action:@selector(registerEmail:) forControlEvents:UIControlEventTouchUpInside];

    self.emailFieldView.textField.text = self.viewModel.identifier;
    [self.emailFieldView.textField addTarget:self action:@selector(emailDidChangeInTextField:) forControlEvents:UIControlEventEditingChanged];
}

- (void)registerEmail:(id)sender {
    NSError *error = self.viewModel.identifierError;
    if (!error) {
        [self.emailFieldView setInvalid:NO];
        [self.emailFieldView.textField resignFirstResponder];
        A0LogDebug(@"Registering email %@", self.emailFieldView.textField.text);
        [self.registerButton setInProgress:YES];
        __weak A0EmailSendCodeViewController *weakSelf = self;
        A0LogDebug(@"About to send Email code to %@", self.viewModel.identifier);
        [self.viewModel requestVerificationCodeWithCallback:^(NSError * _Nullable error) {
            if (error) {
                A0LogError(@"Failed to send SMS code with error %@", error);
                NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error sending the email code");
                NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : A0LocalizedString(@"Couldn't send the email with your login code. Please try again later.");
                [A0Alert showInController:weakSelf errorAlert:^(A0Alert *alert) {
                    alert.title = title;
                    alert.message = message;
                }];
                [weakSelf.registerButton setInProgress:NO];
                return;
            }
            A0LogDebug(@"Email code sent to %@", weakSelf.viewModel.identifier);
            [weakSelf.registerButton setInProgress:NO];
            if (weakSelf.didRequestVerificationCode) {
                weakSelf.didRequestVerificationCode();
            }
        }];
    } else {
        [self.emailFieldView setInvalid:YES];
        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
            alert.title = error.localizedDescription;
            alert.message = error.localizedFailureReason;
        }];
    }
}

- (void)emailDidChangeInTextField:(UITextField *)textField {
    self.viewModel.identifier = textField.text;
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
