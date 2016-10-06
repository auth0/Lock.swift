//  A0DatabaseLoginViewController.m
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
#import "A0PasswordFieldView.h"
#import "A0PasswordValidator.h"
#import "A0UsernameValidator.h"
#import "A0EmailValidator.h"
#import "A0CredentialsValidator.h"
#import "A0LockConfiguration.h"
#import "UIViewController+LockNotification.h"
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "NSObject+A0AuthenticatorProvider.h"
#import "NSError+A0APIError.h"
#import "NSError+A0LockErrors.h"
#import "Constants.h"
#import "A0LoginView.h"
#import "A0Connection+DatabaseValidation.h"
#import <CoreGraphics/CoreGraphics.h>
#import <Masonry/Masonry.h>

@interface A0DatabaseLoginViewController () <A0LoginViewDelegate>

@property (strong, nonatomic) A0Connection *matchedConnection;

@end

@implementation A0DatabaseLoginViewController

- (instancetype)init {
    if (self) {
        self.title = A0LocalizedString(@"Login");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0Theme *theme = [A0Theme sharedInstance];
    A0LoginView *loginView = [[A0LoginView alloc] initWithTheme:theme];
    [self.view addSubview:loginView];
    self.loginView = loginView;

    [self.loginView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];

    self.loginView.identifier = _identifier;
    self.loginView.delegate = self;
    A0UsernameValidationInfo info;
    if (self.defaultConnection) {
        self.parameters[A0ParameterConnection] = self.defaultConnection.name;
        info = self.defaultConnection.usernameValidation;
    } else {
        info.min = 1;
        info.max = 15;
    }

    BOOL requiresUsername = [self.defaultConnection[A0ConnectionRequiresUsername] boolValue];
    NSMutableArray *validators = [@[
                                    [[A0PasswordValidator alloc] initWithField:self.loginView.passwordField.textField],
                                    ] mutableCopy];
    if (self.forceUsername) {
        [validators addObject:[A0UsernameValidator databaseValidatorForField:self.loginView.identifierField.textField withMinimum:info.min andMaximum:info.max]];
    } else if (requiresUsername) {
        [validators addObject:[A0UsernameValidator nonEmtpyValidatorForField:self.loginView.identifierField.textField]];
    } else {
        [validators addObject:[[A0EmailValidator alloc] initWithField:self.loginView.identifierField.textField]];
    }
    self.validator = [[A0CredentialsValidator alloc] initWithValidators:validators];

    if (requiresUsername && !self.forceUsername) {
        self.loginView.identifierType = A0LoginIndentifierTypeUsername | A0LoginIndentifierTypeEmail;
    } else {
        self.loginView.identifierType = self.forceUsername ? A0LoginIndentifierTypeUsername : A0LoginIndentifierTypeEmail;
    }
}

- (NSString *)identifier {
    return self.loginView ? self.loginView.identifier : _identifier;
}

#pragma mark - Enterprise login

- (void)loginUserWithConnection:(A0Connection *)connection completion:(A0LoginViewCompletionHandler)completion {

    NSString *connectionName = connection.name;

    A0APIClientAuthenticationSuccess successBlock = ^(A0UserProfile *profile, A0Token *token){
        [self postLoginSuccessfulForConnection:connection];
        if (self.onLoginBlock) {
            self.onLoginBlock(self, profile, token);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(YES);
        });
    };

    void(^failureBlock)(NSError *error) = ^(NSError *error) {
        [self postLoginErrorNotificationWithError:error];
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
                        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                            alert.title = error.localizedDescription;
                            alert.message = error.localizedFailureReason;
                        }];
                        break;
                    }
                    default: {
                        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
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
    A0AuthParameters *parameters = [self.parameters copy];
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
    self.loginView.identifierValid = code != A0ErrorCodeInvalidCredentials && code != A0ErrorCodeInvalidUsername && code != A0ErrorCodeInvalidEmail;
    self.loginView.passwordValid = code != A0ErrorCodeInvalidCredentials && code != A0ErrorCodeInvalidPassword;
}

#pragma mark - A0LoginViewDelegate

- (void)loginView:(A0LoginView *)loginView didChangeUsername:(NSString * _Nullable)username {
    A0Connection *connection = [self.domainMatcher connectionForEmail:username];
    if (connection) {
        NSString *domain = connection[A0ConnectionDomain];
        [self.loginView showEnterpriseSSOForConnectionName:domain];
        A0LogVerbose(@"Matched %@ with connection %@", username, connection);
    } else {
        [self.loginView disableEnterpriseSSO];
    }
    self.matchedConnection = connection;
}

- (void)loginView:(A0LoginView *)loginView didSubmitWithCompletionHandler:(A0LoginViewCompletionHandler)completionHandler {
    if (self.matchedConnection) {
        if (![self.configuration shouldUseWebAuthenticationForConnection:self.matchedConnection]) {
            if (self.onShowEnterpriseLogin) {
                self.onShowEnterpriseLogin(self.matchedConnection, self.loginView.identifier);
            }
        } else {
            [self loginUserWithConnection:self.matchedConnection completion:completionHandler];
        }
        return;
    }

    NSError *error = [self.validator validate];
    if (!error) {
        [self hideKeyboard];
        NSString *username = [self.loginView.identifier stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *password = self.loginView.password;
        A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
        A0APIClientAuthenticationSuccess success = ^(A0UserProfile *profile, A0Token *token){
            [self postLoginSuccessfulWithUsername:username andParameters:self.parameters];
            if (self.onLoginBlock) {
                self.onLoginBlock(self, profile, token);
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(YES);
            });
        };
        A0APIClientError failure = ^(NSError *error) {
            [self postLoginErrorNotificationWithError:error];
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler(NO);
                if ([error a0_mfaRequired]) {
                    self.onMFARequired(self.defaultConnection.name, username, password);
                } else {
                    NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error logging in");
                    NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [error a0_localizedStringForLoginError];
                    [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                        alert.title = title;
                        alert.message = message;
                    }];
                }
            });
        };
        [client loginWithUsername:username password:password parameters:self.parameters success:success failure:failure];
    } else {
        [self postLoginErrorNotificationWithError:error];
        dispatch_async(dispatch_get_main_queue(), ^{
            completionHandler(NO);
            if (error) {
                [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                    alert.title = error.localizedDescription;
                    alert.message = error.localizedFailureReason;
                }];
            } else {
                [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                    alert.title = A0LocalizedString(@"There was an error logging in");
                    alert.message = [error a0_localizedStringForLoginError];
                }];
            }
        });
    }
    [self updateUIWithError:error];
}

@end
