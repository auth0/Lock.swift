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
#import "A0WebViewController.h"
#import "A0AuthParameters.h"
#import "A0UIUtilities.h"

#import <CoreGraphics/CoreGraphics.h>
#import <libextobjc/EXTScope.h>
#import "UIViewController+LockNotification.h"
#import "A0CredentialsValidator.h"
#import "A0UsernameValidator.h"
#import "A0PasswordValidator.h"
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "NSObject+A0AuthenticatorProvider.h"

@interface A0ActiveDirectoryViewController ()

@property (weak, nonatomic) IBOutlet A0CredentialFieldView *userField;
@property (weak, nonatomic) IBOutlet A0CredentialFieldView *passwordField;
@property (weak, nonatomic) IBOutlet A0ProgressButton *accessButton;
@property (weak, nonatomic) IBOutlet UIView *credentialsBoxView;
@property (weak, nonatomic) IBOutlet UIImageView *singleSignOnIcon;
@property (weak, nonatomic) IBOutlet UIView *singleSignOnView;

@property (strong, nonatomic) A0Connection *matchedConnection;

- (IBAction)access:(id)sender;
- (IBAction)goToPasswordField:(id)sender;

@end

@implementation A0ActiveDirectoryViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = A0LocalizedString(@"Login");
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0Theme *theme = [A0Theme sharedInstance];
    [theme configurePrimaryButton:self.accessButton];
    [theme configureTextField:self.userField.textField];
    [theme configureTextField:self.passwordField.textField];
    
    [self.userField.textField addTarget:self action:@selector(matchDomainInTextField:) forControlEvents:UIControlEventEditingChanged];
    self.singleSignOnIcon.image = [self.singleSignOnIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.userField setFieldPlaceholderText:A0LocalizedString(@"Username")];
    [self.passwordField setFieldPlaceholderText:A0LocalizedString(@"Password")];
    [self.accessButton setTitle:A0LocalizedString(@"ACCESS") forState:UIControlStateNormal];
    self.validator = [[A0CredentialsValidator alloc] initWithValidators:@[
                                                                          [[A0UsernameValidator alloc] initWithField:self.userField.textField],
                                                                          [[A0PasswordValidator alloc] initWithField:self.passwordField.textField],
                                                                          ]];
}

- (void)dealloc {
    [self.userField.textField removeTarget:self action:@selector(matchDomainInTextField:) forControlEvents:UIControlEventEditingChanged];
}

- (void)access:(id)sender {
    if (self.matchedConnection || self.defaultConnection) {
        A0Connection *connection = self.matchedConnection ?: self.defaultConnection;
        A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
        A0Application *application = [client application];
        A0Strategy *strategy = [application enterpriseStrategyWithConnection:connection.name];
        if (!strategy.useResourceOwnerEndpoint) {
            [self loginUserWithConnection:connection];
        } else {
            [self.accessButton setInProgress:YES];
            NSError *error = [self.validator validate];
            if (!error) {
                [self hideKeyboard];
                NSString *username = [self.userField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                NSString *password = self.passwordField.textField.text;
                @weakify(self);
                A0APIClientAuthenticationSuccess success = ^(A0UserProfile *profile, A0Token *token){
                    @strongify(self);
                    [self postLoginSuccessfulForConnection:connection];
                    [self.accessButton setInProgress:NO];
                    if (self.onLoginBlock) {
                        self.onLoginBlock(profile, token);
                    }
                };
                A0APIClientError failure = ^(NSError *error) {
                    @strongify(self);
                    [self postLoginErrorNotificationWithError:error];
                    [self.accessButton setInProgress:NO];
                    NSString *title = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error logging in");
                    NSString *message = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [A0Errors localizedStringForLoginError:error];
                    A0ShowAlertErrorView(title, message);
                };
                A0AuthParameters *parameters = self.parameters.copy;
                parameters[A0ParameterConnection] = connection.name;
                A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
                [client loginWithUsername:username password:password parameters:parameters success:success failure:failure];
            } else {
                [self postLoginErrorNotificationWithError:error];
                [self.accessButton setInProgress:NO];
                A0ShowAlertErrorView(error.localizedDescription, error.localizedFailureReason);
            }
            [self updateUIWithError:error];
        }
    } else {
        A0ShowAlertErrorView(A0LocalizedString(@"There was an error logging in"), A0LocalizedString(@"There was no connection configured for the domain"));
    }
}

- (void)goToPasswordField:(id)sender {
    [self.passwordField.textField becomeFirstResponder];
}

#pragma mark - Domain Matching

- (void)matchDomainInTextField:(UITextField *)textField {
    A0Connection *connection = [self.domainMatcher connectionForEmail:textField.text];
    A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
    A0Strategy *adStrategy = client.application.activeDirectoryStrategy;
    BOOL showSingleSignOn = connection && ![adStrategy.connections containsObject:connection];
    if (showSingleSignOn) {
        NSString *title = [NSString stringWithFormat:A0LocalizedString(@"Login with %@"), connection[A0ConnectionDomain]];
        [self.accessButton setTitle:title.uppercaseString forState:UIControlStateNormal];
    } else {
        [self.accessButton setTitle:A0LocalizedString(@"ACCESS") forState:UIControlStateNormal];
    }
    A0LogVerbose(@"Matched %@ with connection %@", textField.text, connection);
    self.matchedConnection = connection;
    self.singleSignOnView.hidden = !showSingleSignOn;
}

#pragma mark - Enterprise login

- (void)loginUserWithConnection:(A0Connection *)connection {
    @weakify(self);
    [self.accessButton setInProgress:YES];
    A0APIClientAuthenticationSuccess successBlock = ^(A0UserProfile *profile, A0Token *token){
        @strongify(self);
        [self postLoginSuccessfulForConnection:connection];
        [self.accessButton setInProgress:NO];
        if (self.onLoginBlock) {
            self.onLoginBlock(profile, token);
        }
    };

    void(^failureBlock)(NSError *error) = ^(NSError *error) {
        @strongify(self);
        [self postLoginErrorNotificationWithError:error];
        [self.accessButton setInProgress:NO];
        if ([A0Errors isCancelledSocialAuthentication:error]) {
            switch (error.code) {
                case A0ErrorCodeTwitterAppNotAuthorized:
                case A0ErrorCodeTwitterInvalidAccount:
                case A0ErrorCodeTwitterNotConfigured:
                case A0ErrorCodeAuth0NotAuthorized:
                case A0ErrorCodeAuth0InvalidConfiguration:
                case A0ErrorCodeAuth0NoURLSchemeFound:
                case A0ErrorCodeNotConnectedToInternet:
                case A0ErrorCodeGooglePlusFailed:
                    A0ShowAlertErrorView(error.localizedDescription, error.localizedFailureReason);
                    break;
                default:
                    A0ShowAlertErrorView(A0LocalizedString(@"There was an error logging in"), [A0Errors localizedStringForSocialLoginError:error]);
                    break;
            }
        }
    };

    A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
    A0Application *application = [client application];
    A0Strategy *strategy = [application enterpriseStrategyWithConnection:connection.name];
    A0IdentityProviderAuthenticator *authenticator = [self a0_identityAuthenticatorFromProvider:self.lock];
    A0AuthParameters *parameters = self.parameters.copy;
    parameters[A0ParameterConnection] = connection.name;
    if ([authenticator canAuthenticateStrategy:strategy]) {
        A0LogVerbose(@"Authenticating using Safari for strategy %@ and connection %@", strategy.name, connection.name);
        [authenticator authenticateForStrategy:strategy parameters:parameters success:successBlock failure:failureBlock];
    } else {
        A0LogVerbose(@"Authenticating using embedded UIWebView for strategy %@", strategy.name);
        A0WebViewController *controller = [[A0WebViewController alloc] initWithApplication:application strategy:strategy parameters:parameters];
        controller.modalPresentationStyle = UIModalPresentationCurrentContext;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        controller.onAuthentication = successBlock;
        controller.onFailure = failureBlock;
        controller.lock = self.lock;
        [self presentViewController:controller animated:YES completion:nil];
    }
}

#pragma mark - A0KeyboardEnabledView

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.accessButton.frame fromView:self.accessButton.superview];
    return rect;
}

- (void)hideKeyboard {
    [self.userField.textField resignFirstResponder];
    [self.passwordField.textField resignFirstResponder];
}

#pragma mark - Utility methods

- (void)updateUIWithError:(NSError *)error {
    self.userField.invalid = NO;
    self.passwordField.invalid = NO;
    if (error) {
        switch (error.code) {
            case A0ErrorCodeInvalidCredentials:
                self.userField.invalid = YES;
                self.passwordField.invalid = YES;
                break;
            case A0ErrorCodeInvalidPassword:
                self.passwordField.invalid = YES;
                break;
            case A0ErrorCodeInvalidUsername:
                self.userField.invalid = YES;
                break;
        }
    }
}

@end
