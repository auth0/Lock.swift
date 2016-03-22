//
//  A0SignUpView.m
//  Lock
//
//  Created by Hernan Zalazar on 3/22/16.
//  Copyright © 2016 Auth0. All rights reserved.
//

#import "A0SignUpView.h"
#import "A0Theme.h"
#import "A0RoundedBoxView.h"
#import "A0CredentialFieldView.h"
#import "Constants.h"
#import "A0ProgressButton.h"
#import <Masonry/Masonry.h>

@interface A0SignUpView ()

@property (weak, nonatomic) UILabel *titleLabel;

@end

@implementation A0SignUpView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _identifierValid = YES;
        _usernameValid = YES;
        _passwordValid = YES;
        [self setupLayoutWithTheme:[A0Theme sharedInstance] requiresUsername:NO];
    }
    return self;
}

- (instancetype)initWithTheme:(A0Theme *)theme requiresUsername:(BOOL)requiresUsername {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _identifierValid = YES;
        _usernameValid = YES;
        _passwordValid = YES;
        [self setupLayoutWithTheme:theme requiresUsername:requiresUsername];
    }
    return self;
}

- (void)setupLayoutWithTheme:(A0Theme *)theme requiresUsername:(BOOL)requiresUsername {
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    A0RoundedBoxView *boxView = [[A0RoundedBoxView alloc] init];
    A0CredentialFieldView *identifierField = [[A0CredentialFieldView alloc] init];
    A0CredentialFieldView *usernameField = [[A0CredentialFieldView alloc] init];
    A0CredentialFieldView *passwordField = [[A0CredentialFieldView alloc] init];
    UIView *firstSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *secondSeparator = [[UIView alloc] initWithFrame:CGRectZero];
    A0ProgressButton *submitButton = [A0ProgressButton progressButton];

    [self addSubview:containerView];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 20, 0, 20));
    }];

    [boxView addSubview:identifierField];
    [boxView addSubview:firstSeparator];
    if (requiresUsername) {
        [boxView addSubview:usernameField];
        [boxView addSubview:secondSeparator];
    }
    [boxView addSubview:passwordField];
    [boxView addSubview:firstSeparator];
    [identifierField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.and.right.equalTo(boxView);
        make.bottom.equalTo(firstSeparator.mas_top);
        make.height.equalTo(@50);
    }];
    [firstSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(boxView.mas_left);
        make.right.equalTo(boxView.mas_right);
        make.height.equalTo(@1);
    }];
    UIView *separatorView = firstSeparator;
    if (requiresUsername) {
        [usernameField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.and.right.equalTo(boxView);
            make.top.equalTo(firstSeparator.mas_bottom);
            make.bottom.equalTo(secondSeparator.mas_top);
            make.height.equalTo(identifierField.mas_height);
        }];
        [secondSeparator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(boxView.mas_left);
            make.right.equalTo(boxView.mas_right);
            make.height.equalTo(@1);
        }];
        separatorView = secondSeparator;
    }
    [passwordField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.and.right.equalTo(boxView);
        make.top.equalTo(separatorView.mas_bottom);
        make.height.equalTo(identifierField.mas_height);
    }];

    [containerView addSubview:titleLabel];
    [containerView addSubview:boxView];
    [containerView addSubview:submitButton];

    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self).offset(10);
        make.height.equalTo(@16);
    }];
    [boxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView.mas_left).with.offset(1);
        make.right.equalTo(containerView.mas_right).with.offset(1);
        make.top.equalTo(titleLabel.mas_bottom).with.offset(10);
    }];
    [submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(containerView.mas_left).with.offset(1);
        make.right.equalTo(containerView.mas_right).with.offset(1);
        make.height.equalTo(@55);
        make.top.equalTo(boxView.mas_bottom).with.offset(18);
    }];

    self.identifierField = identifierField;
    self.usernameField = requiresUsername ? usernameField : nil;
    self.passwordField = passwordField;
    self.submitButton = submitButton;
    self.titleLabel = titleLabel;

    containerView.backgroundColor = [UIColor clearColor];

    titleLabel.text = A0LocalizedString(@"Please enter your username and password");
    [theme configureLabel:titleLabel];

    UIColor *separatorColor = [theme colorForKey:A0ThemeCredentialBoxSeparatorColor];
    firstSeparator.backgroundColor = separatorColor;
    secondSeparator.backgroundColor = separatorColor;
    identifierField.type = A0CredentialFieldViewEmail;
    identifierField.returnKeyType = UIReturnKeyNext;
    [identifierField.textField addTarget:self action:@selector(finishedEditingField:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [theme configureTextField:identifierField.textField];

    usernameField.type = A0CredentialFieldViewUsername;
    usernameField.returnKeyType = UIReturnKeyNext;
    [usernameField.textField addTarget:self action:@selector(finishedEditingField:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [theme configureTextField:usernameField.textField];

    passwordField.type = A0CredentialFieldViewPassword;
    passwordField.returnKeyType = UIReturnKeyGo;
    [passwordField.textField addTarget:self action:@selector(finishedEditingField:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [theme configureTextField:passwordField.textField];

    [submitButton addTarget:self action:@selector(submitLoginFromSender:) forControlEvents:UIControlEventTouchUpInside];
    [submitButton setTitle:A0LocalizedString(@"SIGN UP") forState:UIControlStateNormal];
    [theme configurePrimaryButton:submitButton];

}

- (void)setIdentifierType:(A0SignUpIndentifierType)identifierType {
    [self willChangeValueForKey:NSStringFromSelector(@selector(identifierType))];
    _identifierType = identifierType;
    BOOL isEmail = identifierType & A0SignUpIndentifierTypeEmail;
    BOOL isUsername = identifierType & A0SignUpIndentifierTypeUsername;
    if (isEmail && isUsername) {
        self.identifierField.type = A0CredentialFieldViewEmailOrUsername;
    } else if(isEmail) {
        self.identifierField.type = A0CredentialFieldViewEmail;
    } else {
        self.identifierField.type = A0CredentialFieldViewUsername;
    }
    [self didChangeValueForKey:NSStringFromSelector(@selector(identifierType))];
    if (!self.title) {
        self.titleLabel.text = isUsername ? A0LocalizedString(@"Please enter your username and password") : A0LocalizedString(@"Please enter your email and password");
    }
}

- (void)setTitle:(NSString *)title {
    [self willChangeValueForKey:NSStringFromSelector(@selector(title))];
    _title = [title copy];
    [self didChangeValueForKey:NSStringFromSelector(@selector(title))];
    if (title) {
        self.titleLabel.text = title;
    }
}

- (NSString *)identifier {
    return [self.identifierField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)setIdentifier:(NSString *)identifier {
    self.identifierField.textField.text = identifier;
}

- (NSString *)username {
    return [self.usernameField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

- (void)setUsername:(NSString *)username {
    self.usernameField.textField.text = username;
}

- (void)setPassword:(NSString *)password {
    self.passwordField.textField.text = password;
}

- (NSString *)password {
    return self.passwordField.textField.text;
}

- (void)setIdentifierValid:(BOOL)identifierValid {
    _identifierValid = identifierValid;
    self.identifierField.invalid = !identifierValid;
}

- (void)setUsernameValid:(BOOL)usernameValid {
    _usernameValid = usernameValid;
    self.usernameField.invalid = !usernameValid;
}

- (void)setPasswordValid:(BOOL)passwordValid {
    _passwordValid = passwordValid;
    self.passwordField.invalid = !passwordValid;
}

- (CGSize)intrinsicContentSize {
    return CGSizeMake(280, 261);
}

- (BOOL)resignFirstResponder {
    [self.identifierField.textField resignFirstResponder];
    [self.usernameField.textField resignFirstResponder];
    [self.passwordField.textField resignFirstResponder];
    return [super resignFirstResponder];
}

#pragma mark - UIKit actions

- (void)finishedEditingField:(id)sender {
    if (sender == self.passwordField.textField) {
        [self submitLoginFromSender:sender];
    } else if (sender == self.identifierField.textField && self.usernameField) {
        [self.usernameField.textField becomeFirstResponder];
    } else {
        [self.passwordField.textField becomeFirstResponder];
    }
}

- (void)submitLoginFromSender:(id)sender {
    [self.submitButton setInProgress:YES];
    [self.delegate signUpView:self didSubmitWithCompletionHandler:^(BOOL success) {
        [self.submitButton setInProgress:NO];
    }];
}

@end
