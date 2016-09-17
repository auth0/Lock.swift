// A0TouchIDSignupViewController.m
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

#import "A0TouchIDSignUpViewController.h"

#import "A0Theme.h"
#import "A0CredentialFieldView.h"
#import "A0ProgressButton.h"
#import "A0APIClient.h"
#import "A0Errors.h"
#import "A0Alert.h"

#import "A0EmailValidator.h"
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "NSError+A0APIError.h"
#import "Constants.h"
#import "A0AuthParameters.h"
#import "A0KeyUploader.h"
#import "A0Token.h"
#import "A0UserProfile.h"
#import "A0RoundedBoxView.h"
#import "NSError+A0LockErrors.h"
#import <Masonry/Masonry.h>

@interface A0TouchIDSignUpViewController ()

@property (weak, nonatomic) IBOutlet A0ProgressButton *signUpButton;

- (IBAction)signUp:(id)sender;

@property (strong, nonatomic) A0EmailValidator *validator;

@end

@implementation A0TouchIDSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    A0CredentialFieldView *emailField = [[A0CredentialFieldView alloc] init];
    A0RoundedBoxView *boxView = [[A0RoundedBoxView alloc] init];
    A0ProgressButton *signUpButton = [A0ProgressButton progressButton];

    [boxView addSubview:emailField];
    [emailField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(boxView);
    }];

    [self.view addSubview:boxView];
    [self.view addSubview:signUpButton];
    [boxView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view).offset(21);
        make.right.equalTo(self.view).offset(-21);
        make.height.equalTo(@50);
    }];
    [signUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(boxView.mas_bottom).offset(18);
        make.left.equalTo(self.view).offset(21);
        make.right.equalTo(self.view).offset(-21);
        make.height.equalTo(@55);
        make.bottom.equalTo(self.view);
    }];

    self.signUpButton = signUpButton;
    self.emailField = emailField;

    A0Theme *theme = [A0Theme sharedInstance];
    [theme configurePrimaryButton:self.signUpButton];

    self.validator = [[A0EmailValidator alloc] initWithField:self.emailField.textField];
    self.title = A0LocalizedString(@"Register");
    self.emailField.type = A0CredentialFieldViewEmail;
    self.emailField.returnKeyType = UIReturnKeyGo;
    [self.emailField.textField addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventEditingDidEndOnExit];
    [self.signUpButton addTarget:self action:@selector(signUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.signUpButton setTitle:A0LocalizedString(@"SIGN UP") forState:UIControlStateNormal];
}

- (void)signUp:(id)sender {
    [self.signUpButton setInProgress:YES];
    [self hideKeyboard];
    NSString *username = [self.emailField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [self randomStringWithLength:14];
    NSError *error = [self.validator validate];
    if (!error) {
        A0LogDebug(@"Registering user with email %@ for TouchID", username);
        A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
        [client signUpWithUsername:username
                          password:password
                    loginOnSuccess:YES
                        parameters:self.parameters
                           success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                               NSString *connection = self.parameters[@"connection"];
                               NSString *authorization = [A0KeyUploader authorizationWithUsername:username password:password connectionName:connection];
                               A0KeyUploader *uploader = [[A0KeyUploader alloc] initWithDomainURL:[self.lock domainURL]
                                                                                         clientId:[self.lock clientId]
                                                                                    authorization:authorization];
                               if (self.onRegisterBlock) {
                                   self.onRegisterBlock(uploader, profile.userId);
                                   [self.signUpButton setInProgress:NO];
                               }
                           } failure:^(NSError *error){
                               [self.signUpButton setInProgress:NO];
                               NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error signing up");
                               NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [error a0_localizedStringForSignUpError];
                               [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                                   alert.title = title;
                                   alert.message = message;
                               }];
                           }];
    } else {
        [self.signUpButton setInProgress:NO];
        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
            alert.title = error.localizedDescription;
            alert.message = error.localizedFailureReason;
        }];
    }
    [self updateUIWithError:error];
}

#pragma mark - A0KeyboardEnabledView

- (void)hideKeyboard {
    [self.emailField.textField resignFirstResponder];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.signUpButton.frame fromView:self.signUpButton.superview];
    return rect;
}

#pragma mark - Error Handling

- (void)updateUIWithError:(NSError *)error {
    self.emailField.invalid = NO;
    if (error) {
        self.emailField.invalid = YES;
    }
}

#pragma mark - Utility methods

- (NSString *) randomStringWithLength:(NSUInteger)len {
    static NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    for (NSUInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((u_int32_t)[letters length])]];
    }

    return randomString;
}

@end
