// A0MFACodeViewController.m
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

#import "A0MFACodeViewController.h"
#import "Constants.h"
#import "A0MFACodeView.h"
#import "A0Theme.h"
#import "A0AuthParameters.h"
#import "A0ProgressButton.h"
#import "A0APIClient.h"
#import "A0Lock.h"
#import "UIViewController+LockNotification.h"
#import "NSError+A0APIError.h"
#import "A0Errors.h"
#import "A0Alert.h"
#import "NSError+A0LockErrors.h"

#import <Masonry/Masonry.h>

@interface A0MFACodeViewController () <A0MFACodeViewDelegate>
@property (weak, nonatomic) A0MFACodeView *codeView;
@property (copy, nonatomic) NSString *identifier;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *connectionName;


@end

@implementation A0MFACodeViewController

- (instancetype)initWithIdentifier:(NSString *)identifier password:(NSString *)password connectionName:(NSString *)connectionName {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _identifier = identifier;
        _password = password;
        _connectionName = connectionName;
        self.title = A0LocalizedString(@"Two Step Verification");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0Theme *theme = [A0Theme sharedInstance];
    A0MFACodeView *codeView = [[A0MFACodeView alloc] initWithTheme:theme];
    [self.view addSubview:codeView];
    self.codeView = codeView;

    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    if (self.connectionName) {
        self.parameters[A0ParameterConnection] = self.connectionName;
    }

    self.codeView.delegate = self;
}

#pragma mark - A0KeyboardEnabledView

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.codeView.submitButton.frame fromView:self.codeView.submitButton.superview];
    return rect;
}

- (void)hideKeyboard {
    [self.codeView resignFirstResponder];
}

#pragma mark - A0MFACodeViewDelegate

- (void)mfaCodeView:(A0MFACodeView *)mfaCodeView didSubmitWithCompletionHandler:(A0MFACodeViewCompletionHandler)completionHandler {
    NSString *code = [self.codeView.code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    BOOL valid = code.length > 0;
    if (valid) {
        [self hideKeyboard];
        A0APIClient *client = self.lock ? [self.lock apiClient] : [[A0Lock sharedLock] apiClient];
        A0AuthParameters *parameters = [self.parameters copy];
        A0APIClientAuthenticationSuccess success = ^(A0UserProfile *profile, A0Token *token){
            [self postLoginSuccessfulWithUsername:self.identifier andParameters:self.parameters];
            if (self.onLoginBlock) {
                self.onLoginBlock(profile, token);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(YES);
            });
        };
        A0APIClientError failure = ^(NSError *error) {
            [self postLoginErrorNotificationWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(NO);
                NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error logging in");
                NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [error a0_localizedStringForLoginError];
                [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                    alert.title = title;
                    alert.message = message;
                }];
            });
        };
        parameters[@"mfa_code"] = code;
        [client loginWithUsername:self.identifier password:self.password parameters:parameters success:success failure:failure];
    } else {
        completionHandler(NO);
    }

    self.codeView.codeValid = valid;
}
@end
