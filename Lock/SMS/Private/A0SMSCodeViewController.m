// A0SMSCodeViewController.m
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

#import "A0SMSCodeViewController.h"
#import "A0CredentialFieldView.h"
#import "A0ProgressButton.h"
#import "A0Theme.h"
#import "A0Alert.h"
#import "A0APIClient.h"
#import "A0Errors.h"

#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "NSError+A0APIError.h"
#import "A0PasswordlessLockViewModel.h"
#import "Constants.h"
#import "A0RoundedBoxView.h"
#import "NSError+A0LockErrors.h"
#import <Masonry/Masonry.h>

@interface A0SMSCodeViewController ()

@property (strong, nonatomic) A0PasswordlessLockViewModel *model;

@property (weak, nonatomic) IBOutlet UIView *credentialBoxView;
@property (weak, nonatomic) IBOutlet A0CredentialFieldView *codeFieldView;
@property (weak, nonatomic) IBOutlet A0ProgressButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)login:(id)sender;

@end

@implementation A0SMSCodeViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)initWithViewModel:(A0PasswordlessLockViewModel *)viewModel {
    self = [self init];
    if (self) {
        _model = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    A0CredentialFieldView *codeField = [[A0CredentialFieldView alloc] init];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    A0ProgressButton *loginButton = [A0ProgressButton progressButton];
    A0RoundedBoxView *boxView = [[A0RoundedBoxView alloc] init];

    [boxView addSubview:codeField];
    [codeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(boxView);
    }];

    [self.view addSubview:messageLabel];
    [self.view addSubview:boxView];
    [self.view addSubview:loginButton];
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
    [loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(boxView.mas_bottom).offset(18);
        make.left.equalTo(self.view).offset(20);
        make.right.equalTo(self.view).offset(-20);
        make.bottom.equalTo(self.view);
        make.height.equalTo(@55);
    }];

    self.codeFieldView = codeField;
    self.messageLabel = messageLabel;
    self.loginButton = loginButton;

    self.title = A0LocalizedString(@"Enter SMS code");
    A0Theme *theme = [A0Theme sharedInstance];
    [theme configurePrimaryButton:self.loginButton];
    [theme configureLabel:self.messageLabel];
    [self.loginButton setTitle:A0LocalizedString(@"LOGIN") forState:UIControlStateNormal];
    [self.loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
    NSString *message = [NSString stringWithFormat:A0LocalizedString(@"Please check your phone %@.\nYou’ve received a message from us with your passcode"), self.model.identifier];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:message];
    if (self.model.hasIdentifier) {
        NSRange phoneRange = [message rangeOfString:self.model.identifier];
        [attrString setAttributes:@{
                                    NSFontAttributeName: [UIFont boldSystemFontOfSize:self.messageLabel.font.pointSize],
                                    }
                            range:phoneRange];
    }
    self.messageLabel.attributedText = attrString;
    self.messageLabel.preferredMaxLayoutWidth = 298;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.codeFieldView.type = A0CredentialFieldViewOTPCode;
    self.codeFieldView.returnKeyType = UIReturnKeyGo;
    [self.codeFieldView setFieldPlaceholderText:A0LocalizedString(@"SMS Code")];
    [self.codeFieldView.textField addTarget:self action:@selector(login:) forControlEvents:UIControlEventEditingDidEndOnExit];
}

- (void)login:(id)sender {
    A0LogVerbose(@"About to login with phone number %@", self.model.identifier);
    [self.codeFieldView.textField resignFirstResponder];
    NSString *passcode = [self.codeFieldView.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL valid = passcode.length > 0;
    [self.codeFieldView setInvalid:!valid];
    if (passcode.length > 0) {
        __weak A0SMSCodeViewController *weakSelf = self;
        [self.loginButton setInProgress:YES];
        [self.model authenticateWithVerificationCode:passcode callback:^(NSError * _Nullable error) {
            [weakSelf.loginButton setInProgress:NO];
            if (error) {
                NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error logging in");
                NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [error a0_localizedStringForPasswordlessSMSLoginError];
                [A0Alert showInController:weakSelf errorAlert:^(A0Alert *alert) {
                    alert.title = title;
                    alert.message = message;
                }];
            }
        }];
    } else {
        A0LogError(@"Must provide a non-empty passcode.");
        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
            alert.title = A0LocalizedString(@"There was an error logging in");
            alert.message = A0LocalizedString(@"You must enter a valid SMS code");
        }];
    }
}

#pragma mark - A0KeyboardEnabledView

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.loginButton.frame fromView:self.loginButton.superview];
    return rect;
}

- (void)hideKeyboard {
    [self.codeFieldView.textField resignFirstResponder];
}
@end
