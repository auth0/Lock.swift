// A0MFACodeView.m
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

#import "A0MFACodeView.h"
#import "A0Theme.h"
#import "A0RoundedBoxView.h"
#import "A0CredentialFieldView.h"
#import "Constants.h"
#import "A0ProgressButton.h"
#import <Masonry/Masonry.h>

@implementation A0MFACodeView

- (instancetype)initWithTheme:(A0Theme *)theme {
    self = [super init];
    if (self) {
        _codeValid = YES;
        [self setupLayoutWithTheme:theme];
    }
    return self;
}

- (void)setupLayoutWithTheme:(A0Theme *)theme {
    UIView *containerView = [[UIView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    A0RoundedBoxView *boxView = [[A0RoundedBoxView alloc] init];
    A0CredentialFieldView *codeField = [[A0CredentialFieldView alloc] init];
    A0ProgressButton *submitButton = [A0ProgressButton progressButton];

    [self addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).with.insets(UIEdgeInsetsMake(0, 20, 0, 20));
    }];

    [boxView addSubview:codeField];
    [codeField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(boxView);
        make.height.equalTo(@50);
    }];

    [containerView addSubview:titleLabel];
    [containerView addSubview:boxView];
    [containerView addSubview:submitButton];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(10);
        make.centerX.equalTo(self);
        make.height.equalTo(@47);
    }];

    [boxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleLabel.mas_bottom).offset(18);
        make.left.and.right.equalTo(containerView).offset(1);
    }];

    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView.mas_left).with.offset(1);
        make.right.equalTo(containerView.mas_right).with.offset(1);
        make.height.equalTo(@55);
        make.top.equalTo(boxView.mas_bottom).with.offset(19);
        make.bottom.equalTo(self);
    }];

    containerView.backgroundColor = [UIColor clearColor];

    codeField.type = A0CredentialFieldViewOTPCode;
    codeField.returnKeyType = UIReturnKeyGo;
    codeField.textField.text = self.code;
    [codeField.textField addTarget:self action:@selector(submitLoginFromSender:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [theme configureTextField:codeField.textField];

    [theme configureMultilineLabel:titleLabel withText:A0LocalizedString(@"Please enter a verification code from your code generator application.")];

    [submitButton setTitle:A0LocalizedString(@"SEND") forState:UIControlStateNormal];
    submitButton.accessibilityHint = A0LocalizedString(@"multi-factor authentication");
    [submitButton addTarget:self action:@selector(submitLoginFromSender:) forControlEvents:UIControlEventTouchUpInside];
    [theme configurePrimaryButton:submitButton];

    self.codeField = codeField;
    self.submitButton = submitButton;
}

- (NSString *)code {
    return self.codeField.textField.text;
}

- (void)setCode:(NSString *)code {
    self.codeField.textField.text = code;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(280, 185);
}

- (BOOL)resignFirstResponder {
    [self.codeField.textField resignFirstResponder];
    return [super resignFirstResponder];
}

- (void)setCodeValid:(BOOL)codeValid {
    _codeValid = codeValid;
    self.codeField.invalid = !codeValid;
}

#pragma mark - UIKit actions

- (void)submitLoginFromSender:(id)sender {
    [self.submitButton setInProgress:YES];
    [self.delegate mfaCodeView:self didSubmitWithCompletionHandler:^(BOOL success) {
        [self.submitButton setInProgress:NO];
    }];
}

@end
