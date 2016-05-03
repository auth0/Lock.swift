// A0ChangePasswordView.m
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

#import "A0ChangePasswordView.h"
#import "A0Theme.h"
#import "A0RoundedBoxView.h"
#import "A0CredentialFieldView.h"
#import "Constants.h"
#import "A0ProgressButton.h"
#import <Masonry/Masonry.h>

@implementation A0ChangePasswordView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _identifierValid = YES;
        [self setupLayoutWithTheme:[A0Theme sharedInstance]];
    }
    return self;
}

- (instancetype)initWithTheme:(A0Theme *)theme {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _identifierValid = YES;
        [self setupLayoutWithTheme:theme];
    }
    return self;
}

- (void)setupLayoutWithTheme:(A0Theme *)theme {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    A0RoundedBoxView *boxView = [[A0RoundedBoxView alloc] init];
    A0CredentialFieldView *identifierField = [[A0CredentialFieldView alloc] init];
    A0ProgressButton *submitButton = [A0ProgressButton progressButton];

    [self addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 20, 0, 20));
    }];

    [boxView addSubview:identifierField];
    [identifierField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(boxView);
        make.height.equalTo(@50);
    }];

    [containerView addSubview:titleLabel];
    [containerView addSubview:boxView];
    [containerView addSubview:submitButton];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.centerX.equalTo(self);
    }];

    [boxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(18);
        make.left.and.right.equalTo(containerView).offset(1);
    }];

    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(boxView.mas_bottom).offset(18);
        make.left.bottom.and.right.equalTo(containerView);
        make.height.equalTo(@55);
    }];

    [theme configureMultilineLabel:titleLabel withText:A0LocalizedString(@"Please enter your email address. We will send you an email to reset your password.")];

    containerView.backgroundColor = [UIColor clearColor];

    identifierField.type = A0CredentialFieldViewEmail;
    identifierField.returnKeyType = UIReturnKeyGo;
    [identifierField.textField addTarget:self action:@selector(submitChangePasswordFromSender:) forControlEvents:UIControlEventEditingDidEndOnExit];

    [theme configureTextField:identifierField.textField];

    [submitButton addTarget:self action:@selector(submitChangePasswordFromSender:) forControlEvents:UIControlEventTouchUpInside];
    [submitButton setTitle:A0LocalizedString(@"SEND") forState:UIControlStateNormal];
    submitButton.accessibilityHint = A0LocalizedString(@"Send reset password email");
    [theme configurePrimaryButton:submitButton];

    self.identifierField = identifierField;
    self.submitButton = submitButton;
}

- (void)setIdentifierType:(A0ChangePasswordIndentifierType)identifierType {
    [self willChangeValueForKey:NSStringFromSelector(@selector(identifierType))];
    _identifierType = identifierType;
    BOOL isEmail = identifierType & A0ChangePasswordIndentifierTypeEmail;
    BOOL isUsername = identifierType & A0ChangePasswordIndentifierTypeUsername;
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

- (void)setIdentifierValid:(BOOL)identifierValid {
    _identifierValid = identifierValid;
    self.identifierField.invalid = !identifierValid;
}

- (BOOL)resignFirstResponder {
    [self.identifierField.textField resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)submitChangePasswordFromSender:(id)sender {
    [self.submitButton setInProgress:YES];
    [self.delegate changePasswordView:self didSubmitWithCompletionHandler:^(BOOL success) {
        [self.submitButton setInProgress:NO];
    }];
}

@end
