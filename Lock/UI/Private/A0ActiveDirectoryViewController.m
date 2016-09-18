//  A0ActiveDirectoryViewController.m
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

#import "A0ActiveDirectoryViewController.h"
#import "A0DatabaseLoginViewController.h"
#import "A0ProgressButton.h"
#import "UIButton+A0SolidButton.h"
#import "A0Errors.h"
#import "A0APIClient.h"
#import "A0Theme.h"
#import "A0CredentialFieldView.h"
#import "A0SimpleConnectionDomainMatcher.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "A0Connection.h"
#import "A0IdentityProviderAuthenticator.h"
#import "A0AuthParameters.h"
#import "A0Alert.h"
#import "A0LockConfiguration.h"
#import "NSError+A0LockErrors.h"

#import <CoreGraphics/CoreGraphics.h>
#import "UIViewController+LockNotification.h"
#import "A0CredentialsValidator.h"
#import "A0UsernameValidator.h"
#import "A0PasswordValidator.h"
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "NSObject+A0AuthenticatorProvider.h"
#import "NSError+A0APIError.h"
#import "Constants.h"
#import "A0LoginView.h"
#import <Masonry/Masonry.h>

@interface A0ActiveDirectoryViewController () <A0LoginViewDelegate>

@property (strong, nonatomic) A0Connection *matchedConnection;

@end

@implementation A0ActiveDirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    A0LoginView *loginView = [[A0LoginView alloc] initWithTheme:[A0Theme sharedInstance]];
    [self.view addSubview:loginView];

    [loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.loginView = loginView;
    self.title = A0LocalizedString(@"Login");
    self.loginView.identifierType = A0CredentialFieldViewUsername;
    self.loginView.delegate = self;
    self.loginView.identifier = _identifier;

    self.validator = [[A0CredentialsValidator alloc] initWithValidators:@[
                                                                          [A0UsernameValidator nonEmtpyValidatorForField:self.loginView.identifierField.textField],
                                                                          [[A0PasswordValidator alloc] initWithField:self.loginView.passwordField.textField],
                                                                          ]];
}

- (NSString *)identifier {
    return self.loginView ? self.loginView.identifier : _identifier;
}

#pragma mark - Enterprise login

- (void)loginUserWithConnection:(A0Connection *)connection completion:(A0LoginViewCompletionHandler)completion {
    __weak A0ActiveDirectoryViewController *weakSelf = self;

    NSString *connectionName = connection.name;

    A0APIClientAuthenticationSuccess successBlock = ^(A0UserProfile *profile, A0Token *token){
        [weakSelf postLoginSuccessfulForConnection:connection];
        if (weakSelf.onLoginBlock) {
            weakSelf.onLoginBlock(profile, token);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(YES);
        });
    };

    void(^failureBlock)(NSError *error) = ^(NSError *error) {
        [weakSelf postLoginErrorNotificationWithError:error];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(NO);
            if (![error a0_cancelledSocialAuthenticationError]) {
                switch (error.code) {
                    case A0ErrorCodeTwitterAppNotAuthorized:
                    case A0ErrorCodeTwitterInvalidAccount:
                    case A0ErrorCodeTwitterNotConfigured:
                    case A0ErrorCodeAuth0NotAuthorized:
                    case A0ErrorCodeAuth0InvalidConfiguration:
                    case A0ErrorCodeAuth0NoURLSchemeFound:
                    case A0ErrorCodeNotConnectedToInternet:
                    case A0ErrorCodeGooglePlusFailed: {
                        [A0Alert showInController:weakSelf errorAlert:^(A0Alert *alert) {
                            alert.title = error.localizedDescription;
                            alert.message = error.localizedFailureReason;
                        }];
                        break;
                    }
                    default: {
                        [A0Alert showInController:weakSelf errorAlert:^(A0Alert *alert) {
                            alert.title = A0LocalizedString(@"There was an error logging in");
                            alert.message = [error a0_localizedStringErrorForConnectionName:connectionName];
                        }];
                        break;
                    }
                }
            }
        });
    };

    A0IdentityProviderAuthenticator *authenticator = [self a0_identityAuthenticatorFromProvider:self.lock];
    A0AuthParameters *parameters = self.parameters.copy;
    NSString *hint = self.loginView.identifier;
    NSRange range = [hint rangeOfString:@"@"];
    if (connection[A0ConnectionDomain] && range.location != NSNotFound) {
        hint = [hint substringToIndex:range.location];
    }
    parameters[@"login_hint"] = hint;
    A0LogVerbose(@"Authenticating with connection %@", connectionName);
    [authenticator authenticateWithConnectionName:connectionName parameters:parameters success:successBlock failure:failureBlock];
}

#pragma mark - A0KeyboardEnabledView

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.loginView.submitButton.frame fromView:self.loginView.submitButton.superview];
    return rect;
}

- (void)hideKeyboard {
    [self.loginView resignFirstResponder];
}

#pragma mark - Utility methods

- (void)updateUIWithError:(NSError *)error {
    if (!error) {
        self.loginView.identifierValid = YES;
        self.loginView.passwordValid = YES;
        return;
    }
    NSInteger code = error.code;
    self.loginView.identifierValid = code != A0ErrorCodeInvalidCredentials && code != A0ErrorCodeInvalidUsername;
    self.loginView.passwordValid = code != A0ErrorCodeInvalidCredentials && code != A0ErrorCodeInvalidPassword;
}

#pragma mark - A0LoginViewDelegate

- (void)loginView:(A0LoginView *)loginView didChangeUsername:(NSString *)username {
    A0Connection *connection = [self.domainMatcher connectionForEmail:username];
    A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
    A0Strategy *adStrategy = client.application.activeDirectoryStrategy;
    BOOL showSingleSignOn = connection && ![adStrategy.connections containsObject:connection];
    if (showSingleSignOn) {
        A0LogDebug(@"Matched %@ with connection %@", username, connection);
        [loginView showEnterpriseSSOForConnectionName:connection[A0ConnectionDomain]];
    } else {
        [loginView disableEnterpriseSSO];
    }
    self.matchedConnection = connection;
}

- (void)loginView:(A0LoginView *)loginView didSubmitWithCompletionHandler:(A0LoginViewCompletionHandler)completionHandler {
    if (self.matchedConnection || self.defaultConnection) {
        A0Connection *connection = self.matchedConnection ?: self.defaultConnection;
        if ([self.configuration shouldUseWebAuthenticationForConnection:connection]) {
            [self loginUserWithConnection:connection completion:completionHandler];
        } else {
            NSError *error = [self.validator validate];
            if (!error) {
                [self hideKeyboard];
                NSString *username = self.loginView.identifier;
                NSString *password = self.loginView.password;
                __weak A0ActiveDirectoryViewController *weakSelf = self;
                A0APIClientAuthenticationSuccess success = ^(A0UserProfile *profile, A0Token *token){
                    [weakSelf postLoginSuccessfulForConnection:connection];
                    if (weakSelf.onLoginBlock) {
                        weakSelf.onLoginBlock(profile, token);
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(YES);
                    });
                };
                A0APIClientError failure = ^(NSError *error) {
                    [weakSelf postLoginErrorNotificationWithError:error];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completionHandler(NO);
                        NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error logging in");
                        NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [error a0_localizedStringForLoginError];
                        [A0Alert showInController:weakSelf errorAlert:^(A0Alert *alert) {
                            alert.title = title;
                            alert.message = message;
                        }];
                    });
                };
                A0AuthParameters *parameters = self.parameters.copy;
                parameters[A0ParameterConnection] = connection.name;
                A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
                [client loginWithUsername:username password:password parameters:parameters success:success failure:failure];
            } else {
                [self postLoginErrorNotificationWithError:error];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                        alert.title = error.localizedDescription;
                        alert.message = error.localizedFailureReason;
                    }];
                    completionHandler(NO);
                });
            }
            [self updateUIWithError:error];
        }
    } else {
        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
            alert.title = A0LocalizedString(@"There was an error logging in");
            alert.message = A0LocalizedString(@"There was no connection configured for the domain");
        }];
        completionHandler(NO);
    }
}
@end
