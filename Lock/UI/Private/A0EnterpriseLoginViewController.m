//  A0EnterpriseLoginViewController.m
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

#import "A0Connection.h"

#import "A0EnterpriseLoginViewController.h"
#import "A0AuthParameters.h"
#import "A0CredentialFieldView.h"
#import "A0CredentialsValidator.h"
#import "A0UsernameValidator.h"
#import "A0PasswordValidator.h"
#import "A0PasswordFieldView.h"
#import "Constants.h"
#import "A0LoginView.h"
#import <Masonry/Masonry.h>

@interface A0EnterpriseLoginViewController ()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation A0EnterpriseLoginViewController

- (instancetype)initWithEmail:(NSString *)email {
    self = [super init];
    if (self) {
        NSArray *parts = [email componentsSeparatedByString:@"@"];
        NSString *localPart = [parts firstObject];
        self.identifier = [localPart copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    UILabel *mesageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    A0LoginView *loginView = self.loginView;
    [loginView removeFromSuperview];
    [self.view addSubview:mesageLabel];
    [self.view addSubview:loginView];

    [mesageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(8);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    [loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mesageLabel.mas_bottom).offset(18);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);
    }];

    self.messageLabel = mesageLabel;
    self.loginView = loginView;

    NSString *message = A0LocalizedString(@"Please enter your corporate credentials at %@");
    self.messageLabel.text = [NSString stringWithFormat:message, self.connection[A0ConnectionDomain]];
    self.messageLabel.numberOfLines = 4;
    self.messageLabel.textAlignment = NSTextAlignmentCenter;
    self.loginView.identifier = self.identifier;
    self.parameters[A0ParameterConnection] = self.connection.name;
    self.validator = [[A0CredentialsValidator alloc] initWithValidators:@[
                                                                          [A0UsernameValidator nonEmtpyValidatorForField:self.loginView.identifierField.textField],
                                                                          [[A0PasswordValidator alloc] initWithField:self.loginView.passwordField.textField],
                                                                          ]];
}

@end
