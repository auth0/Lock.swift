// A0LoginView.m
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
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

#import "A0LoginView.h"
#import "A0Theme.h"
#import "A0RoundedBoxView.h"
#import "A0CredentialFieldView.h"
#import "Constants.h"
#import "A0ProgressButton.h"
#import <Masonry/Masonry.h>

@implementation A0LoginView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _enterpriseSSOEnabled = NO;
        _identifierValid = YES;
        _passwordValid = YES;
        [self setupLayoutWithTheme:[A0Theme sharedInstance]];
    }
    return self;
}

- (instancetype)initWithTheme:(A0Theme *)theme {
    self = [super init];
    if (self) {
        _enterpriseSSOEnabled = NO;
        _identifierValid = YES;
        _passwordValid = YES;
        [self setupLayoutWithTheme:theme];
    }
    return self;
}

- (void)setupLayoutWithTheme:(A0Theme *)theme {
    UIView *containerView = [[UIView alloc] init];
    A0RoundedBoxView *boxView = [[A0RoundedBoxView alloc] init];
    A0CredentialFieldView *identifierField = [[A0CredentialFieldView alloc] init];
    A0CredentialFieldView *passwordField = [[A0CredentialFieldView alloc] init];
    UIView *separatorView = [[UIView alloc] init];
    UIView *ssoView = [[UIView alloc] init];
    UIImageView *ssoImageView = [[UIImageView alloc] init];
    UILabel *ssoLabel = [[UILabel alloc] init];
    A0ProgressButton *submitButton = [A0ProgressButton progressButton];

    [self addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 20, 0, 20));
    }];

    [boxView addSubview:identifierField];
    [boxView addSubview:separatorView];
    [boxView addSubview:passwordField];
    boxView.separators = @[separatorView];
    [identifierField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.and.right.equalTo(boxView);
        make.bottom.equalTo(separatorView.mas_top);
        make.height.equalTo(@50);
    }];
    [separatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(boxView.mas_left);
        make.right.equalTo(boxView.mas_right);
    }];
    [passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.and.right.equalTo(boxView);
        make.top.equalTo(separatorView.mas_bottom);
        make.height.equalTo(identifierField.mas_height);
    }];

    [containerView addSubview:boxView];
    [containerView insertSubview:ssoView aboveSubview:boxView];
    [containerView addSubview:submitButton];
    [boxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView.mas_left).with.offset(1);
        make.right.equalTo(containerView.mas_right).with.offset(1);
        make.top.equalTo(containerView.mas_top).with.offset(10);
        make.height.equalTo(@101);
        make.bottom.equalTo(ssoView.mas_bottom);
    }];
    [ssoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView.mas_left);
        make.right.equalTo(containerView.mas_right);
        make.height.equalTo(@50);
    }];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView.mas_left).with.offset(1);
        make.right.equalTo(containerView.mas_right).with.offset(1);
        make.height.equalTo(@55);
        make.top.equalTo(boxView.mas_bottom).with.offset(19);
    }];

    [ssoView addSubview:ssoImageView];
    [ssoView addSubview:ssoLabel];
    [ssoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(ssoView);
    }];
    [ssoImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(ssoLabel.mas_left).with.offset(-8);
        make.centerY.equalTo(ssoView.mas_centerY);
        make.height.and.with.equalTo(@14);
    }];

    containerView.backgroundColor = [UIColor clearColor];

    UIColor *separatorColor = [theme colorForKey:A0ThemeCredentialBoxSeparatorColor];
    [boxView.separators enumerateObjectsUsingBlock:^(UIView *separator, NSUInteger idx, BOOL *stop) {
        separator.backgroundColor = separatorColor;
    }];
    identifierField.type = A0CredentialFieldViewEmail;
    identifierField.returnKeyType = UIReturnKeyNext;
    identifierField.textField.text = self.identifier;
    [identifierField.textField addTarget:self action:@selector(finishedEditingField:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [identifierField.textField addTarget:self action:@selector(textChangedInTextField:) forControlEvents:UIControlEventEditingChanged];
    [theme configureTextField:identifierField.textField];

    passwordField.type = A0CredentialFieldViewPassword;
    passwordField.returnKeyType = UIReturnKeyGo;
    [passwordField.textField addTarget:self action:@selector(finishedEditingField:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [theme configureTextField:passwordField.textField];

    [submitButton addTarget:self action:@selector(submitLoginFromSender:) forControlEvents:UIControlEventTouchUpInside];
    [theme configurePrimaryButton:submitButton];

    ssoImageView.image = [[theme imageForKey:A0ThemeIconLock] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    ssoImageView.tintColor = [theme colorForKey:A0ThemeTextFieldIconColor];
    ssoLabel.text = A0LocalizedString(@"SINGLE SIGN-ON ENABLED");
    ssoLabel.textColor = [theme colorForKey:A0ThemeDescriptionTextColor];
    ssoLabel.font = [theme fontForKey:A0ThemeDescriptionFont];
    ssoView.backgroundColor = [theme colorForKey:A0ThemeCredentialBoxBackgroundColor];

    self.identifierField = identifierField;
    self.passwordField = passwordField;
    self.submitButton = submitButton;
    self.ssoView = ssoView;
    [self disableEnterpriseSSO];
}

- (void)setIdentifierType:(A0LoginIndentifierType)identifierType {
    [self willChangeValueForKey:NSStringFromSelector(@selector(identifierType))];
    _identifierType = identifierType;
    BOOL isEmail = identifierType & A0LoginIndentifierTypeEmail;
    BOOL isUsername = identifierType & A0LoginIndentifierTypeUsername;
    if (isEmail && isUsername) {
        self.identifierField.type = A0CredentialFieldViewEmailOrUsername;
    } else if(isEmail) {
        self.identifierField.type = A0CredentialFieldViewEmail;
    } else {
        self.identifierField.type = A0CredentialFieldViewUsername;
    }
    [self didChangeValueForKey:NSStringFromSelector(@selector(identifierType))];
}

- (NSString *)identifier {
    return [self.identifierField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)setIdentifier:(NSString *)identifier {
    self.identifierField.textField.text = identifier;
}

- (void)setPassword:(NSString *)password {
    self.passwordField.textField.text = password;
}

- (NSString *)password {
    return self.passwordField.textField.text;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(280, 185);
}

- (void)showEnterpriseSSOForConnectionName:(NSString *)connectionName {
    _enterpriseSSOEnabled = YES;
    NSString *title = [NSString stringWithFormat:A0LocalizedString(@"Login with %@"), connectionName];
    [self.submitButton setTitle:title.uppercaseString forState:UIControlStateNormal];
    self.ssoView.hidden = NO;
    self.passwordField.hidden = YES;
    UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, A0LocalizedString(@"SINGLE SIGN-ON ENABLED"));
    self.submitButton.accessibilityHint = nil;
}

- (void)disableEnterpriseSSO {
    _enterpriseSSOEnabled = NO;
    self.ssoView.hidden = YES;
    self.passwordField.hidden = NO;
    [self.submitButton setTitle:A0LocalizedString(@"ACCESS") forState:UIControlStateNormal];
    self.submitButton.accessibilityHint = A0LocalizedString(@"Login with email and password");
}

- (void)setIdentifierValid:(BOOL)identifierValid {
    _identifierValid = identifierValid;
    self.identifierField.invalid = !identifierValid;
}

- (void)setPasswordValid:(BOOL)passwordValid {
    _passwordValid = passwordValid;
    self.passwordField.invalid = !passwordValid;
}

- (BOOL)resignFirstResponder {
    [self.identifierField.textField resignFirstResponder];
    [self.passwordField.textField resignFirstResponder];
    return [super resignFirstResponder];
}

#pragma mark - UIKit actions

- (void)finishedEditingField:(id)sender {
    if (sender == self.passwordField.textField || self.enterpriseSSOEnabled) {
        [self submitLoginFromSender:sender];
    } else {
        [self.passwordField.textField becomeFirstResponder];
    }
}

- (void)submitLoginFromSender:(id)sender {
    [self.submitButton setInProgress:YES];
    [self.delegate loginView:self didSubmitWithCompletionHandler:^(BOOL success) {
        [self.submitButton setInProgress:NO];
    }];
}

- (void)textChangedInTextField:(UITextField *)textField {
    if (textField == self.identifierField.textField) {
        [self.delegate loginView:self didChangeUsername:textField.text];
    }
}
@end
