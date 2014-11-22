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
#import "A0DatabaseLoginCredentialValidator.h"
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
#import "A0PasswordFieldView.h"

#import <CoreGraphics/CoreGraphics.h>
#import <libextobjc/EXTScope.h>

#if __has_include("A0PasswordManager.h")
#import "A0PasswordManager.h"
#endif

@interface A0DatabaseLoginViewController ()

@property (weak, nonatomic) IBOutlet A0PasswordFieldView *passwordField;
@property (weak, nonatomic) IBOutlet A0ProgressButton *accessButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIView *credentialsBoxView;
@property (weak, nonatomic) IBOutlet UIImageView *singleSignOnIcon;
@property (weak, nonatomic) IBOutlet UIView *singleSignOnView;

@property (strong, nonatomic) A0Connection *matchedConnection;

- (IBAction)access:(id)sender;
- (IBAction)goToPasswordField:(id)sender;

@end

@implementation A0DatabaseLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = A0LocalizedString(@"Login");
        self.showSignUp = YES;
        self.showResetPassword = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0Theme *theme = [A0Theme sharedInstance];
    [theme configurePrimaryButton:self.accessButton];
    [theme configureSecondaryButton:self.signUpButton];
    [theme configureSecondaryButton:self.forgotPasswordButton];
    [theme configureTextField:self.userField.textField];
    [theme configureTextField:self.passwordField.textField];

    self.signUpButton.hidden = !self.showSignUp;
    self.forgotPasswordButton.hidden = !self.showResetPassword;
    [self.userField.textField addTarget:self action:@selector(matchDomainInTextField:) forControlEvents:UIControlEventEditingChanged];
    self.singleSignOnIcon.image = [self.singleSignOnIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (self.defaultConnection) {
        [self.parameters setValue:self.defaultConnection.name forKey:@"connection"];
    }
    self.userField.textField.placeholder = self.validator.usesEmail ? A0LocalizedString(@"Email") : A0LocalizedString(@"Username");
    self.userField.textField.text = self.defaultUsername;
    self.passwordField.textField.placeholder = A0LocalizedString(@"Password");
    [self.accessButton setTitle:A0LocalizedString(@"ACCESS") forState:UIControlStateNormal];
    [self.passwordField.passwordManagerButton addTarget:self action:@selector(fillLogin:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)dealloc {
    [self.userField.textField removeTarget:self action:@selector(matchDomainInTextField:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordField.passwordManagerButton removeTarget:self action:@selector(fillLogin:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)fillLogin:(id)sender {
#ifdef AUTH0_1PASSWORD
    @weakify(self);
    [[A0PasswordManager sharedInstance] fillLoginInformationForViewController:self
                                                                       sender:sender
                                                                   completion:^(NSString *username, NSString *password) {
                                                                       @strongify(self);
                                                                       self.userField.textField.text = username;
                                                                       self.passwordField.textField.text = password;
                                                                       [self matchDomainInTextField:self.userField.textField];
                                                                       [self access:sender];
                                                                   }];
#endif
}

- (void)access:(id)sender {
    if (self.matchedConnection) {
        A0Application *application = [[A0APIClient sharedClient] application];
        A0Strategy *strategy = [application enterpriseStrategyWithConnection:self.matchedConnection.name];
        if ([strategy.name isEqualToString:A0StrategyNameActiveDirectory]) {
            if (self.onShowEnterpriseLogin) {
                self.onShowEnterpriseLogin(self.matchedConnection, self.userField.textField.text);
            }
        } else {
            [self loginUserWithConnection:self.matchedConnection];
        }
        return;
    }

    [self.accessButton setInProgress:YES];
    NSError *error;
    [self.validator setUsername:self.userField.textField.text password:self.passwordField.textField.text];
    if ([self.validator validateCredential:&error]) {
        [self hideKeyboard];
        NSString *username = [self.userField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSString *password = self.passwordField.textField.text;
        @weakify(self);
        A0APIClientAuthenticationSuccess success = ^(A0UserProfile *profile, A0Token *token){
            @strongify(self);
            [self.accessButton setInProgress:NO];
            if (self.onLoginBlock) {
                self.onLoginBlock(profile, token);
            }
        };
        A0APIClientError failure = ^(NSError *error) {
            [self.accessButton setInProgress:NO];
            NSString *title = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error logging in");
            NSString *message = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [A0Errors localizedStringForLoginError:error];
            A0ShowAlertErrorView(title, message);
        };
        [[A0APIClient sharedClient] loginWithUsername:username password:password parameters:self.parameters success:success failure:failure];
    } else {
        [self.accessButton setInProgress:NO];
        if (error) {
            A0ShowAlertErrorView(error.localizedDescription, error.localizedFailureReason);
        } else {
            A0ShowAlertErrorView(A0LocalizedString(@"There was an error logging in"), [A0Errors localizedStringForLoginError:error]);
        }
    }
    [self updateUIWithError:error];
}

- (void)goToPasswordField:(id)sender {
    if (self.passwordField.textField.enabled) {
        [self.passwordField.textField becomeFirstResponder];
    } else {
        [self access:sender];
    }
}

#pragma mark - Domain Matching

- (void)matchDomainInTextField:(UITextField *)textField {
    A0Connection *connection = [self.domainMatcher connectionForEmail:textField.text];
    if (connection) {
        NSString *title = [NSString stringWithFormat:A0LocalizedString(@"Login with %@"), connection.values[@"domain"]];
        Auth0LogVerbose(@"Matched %@ with connection %@", textField.text, connection);
        [self.accessButton setTitle:title.uppercaseString forState:UIControlStateNormal];
    } else {
        [self.accessButton setTitle:A0LocalizedString(@"ACCESS") forState:UIControlStateNormal];
    }
    self.matchedConnection = connection;
    self.singleSignOnView.hidden = connection == nil;
    self.passwordField.textField.enabled = connection == nil;
    self.userField.textField.returnKeyType = connection == nil ? UIReturnKeyNext : UIReturnKeyGo;
}

#pragma mark - Enterprise login

- (void)loginUserWithConnection:(A0Connection *)connection {
    @weakify(self);
    [self.accessButton setInProgress:YES];
    A0APIClientAuthenticationSuccess successBlock = ^(A0UserProfile *profile, A0Token *token){
        @strongify(self);
        [self.accessButton setInProgress:NO];
        if (self.onLoginBlock) {
            self.onLoginBlock(profile, token);
        }
    };

    void(^failureBlock)(NSError *error) = ^(NSError *error) {
        @strongify(self);
        [self.accessButton setInProgress:NO];
        if (error.code != A0ErrorCodeFacebookCancelled && error.code != A0ErrorCodeTwitterCancelled && error.code != A0ErrorCodeAuth0Cancelled) {
            switch (error.code) {
                case A0ErrorCodeTwitterAppNotAuthorized:
                case A0ErrorCodeTwitterInvalidAccount:
                case A0ErrorCodeTwitterNotConfigured:
                case A0ErrorCodeAuth0NotAuthorized:
                case A0ErrorCodeAuth0InvalidConfiguration:
                case A0ErrorCodeAuth0NoURLSchemeFound:
                case A0ErrorCodeNotConnectedToInternet:
                    A0ShowAlertErrorView(error.localizedDescription, error.localizedFailureReason);
                    break;
                default:
                    A0ShowAlertErrorView(A0LocalizedString(@"There was an error logging in"), [A0Errors localizedStringForSocialLoginError:error]);
                    break;
            }
        }
    };

    A0Application *application = [A0APIClient sharedClient].application;
    A0Strategy *strategy = [application enterpriseStrategyWithConnection:connection.name];
    A0IdentityProviderAuthenticator *authenticator = [A0IdentityProviderAuthenticator sharedInstance];
    A0AuthParameters *parameters = self.parameters.copy;
    [parameters setValue:connection.name forKey:@"connection"];
    if ([authenticator canAuthenticateStrategy:strategy]) {
        Auth0LogVerbose(@"Authenticating using Safari for strategy %@ and connection %@", strategy.name, connection.name);
        [authenticator authenticateForStrategy:strategy parameters:parameters success:successBlock failure:failureBlock];
    } else {
        Auth0LogVerbose(@"Authenticating using embedded UIWebView for strategy %@", strategy.name);
        A0WebViewController *controller = [[A0WebViewController alloc] initWithApplication:application strategy:strategy parameters:parameters];
        controller.modalPresentationStyle = UIModalPresentationCurrentContext;
        controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        controller.onAuthentication = successBlock;
        controller.onFailure = failureBlock;
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
