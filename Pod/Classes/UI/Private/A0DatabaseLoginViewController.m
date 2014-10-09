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
#import "A0ConnectionDomainMatcher.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "A0Connection.h"

#import <CoreGraphics/CoreGraphics.h>
#import <libextobjc/EXTScope.h>

static void showAlertErrorView(NSString *title, NSString *message) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:A0LocalizedString(@"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

@interface A0DatabaseLoginViewController ()

@property (weak, nonatomic) IBOutlet A0CredentialFieldView *userField;
@property (weak, nonatomic) IBOutlet A0CredentialFieldView *passwordField;
@property (weak, nonatomic) IBOutlet A0ProgressButton *accessButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIView *credentialsBoxView;
@property (weak, nonatomic) IBOutlet UIImageView *singleSignOnIcon;
@property (weak, nonatomic) IBOutlet UIView *singleSignOnView;

@property (strong, nonatomic) A0ConnectionDomainMatcher *domainMatcher;
@property (strong, nonatomic) A0Connection *matchedConnection;

- (IBAction)access:(id)sender;
- (IBAction)goToPasswordField:(id)sender;
- (IBAction)showSignUp:(id)sender;
- (IBAction)showForgotPassword:(id)sender;

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
    self.credentialsBoxView.layer.borderWidth = 1.0f;
    self.credentialsBoxView.layer.borderColor = [[UIColor colorWithWhite:0.600 alpha:1.000] CGColor];
    self.credentialsBoxView.layer.cornerRadius = 3.0f;

    A0Theme *theme = [A0Theme sharedInstance];
    [theme configurePrimaryButton:self.accessButton];
    [theme configureSecondaryButton:self.signUpButton];
    [theme configureSecondaryButton:self.forgotPasswordButton];
    [theme configureTextField:self.userField.textField];
    [theme configureTextField:self.passwordField.textField];
    self.signUpButton.hidden = !self.showSignUp;
    self.forgotPasswordButton.hidden = !self.showResetPassword;
    A0Application *application = [[A0APIClient sharedClient] application];
    self.domainMatcher = [[A0ConnectionDomainMatcher alloc] initWithStrategies:application.enterpriseStrategies];
    [self.userField.textField addTarget:self action:@selector(matchDomainInTextField:) forControlEvents:UIControlEventEditingChanged];
    self.singleSignOnIcon.image = [self.singleSignOnIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)dealloc {
    [self.userField.textField removeTarget:self action:@selector(matchDomainInTextField:) forControlEvents:UIControlEventEditingChanged];
}

- (void)access:(id)sender {
    if (self.matchedConnection) {
        A0Application *application = [[A0APIClient sharedClient] application];
        A0Strategy *strategy = [application enterpriseStrategyWithConnection:self.matchedConnection.name];
        if ([strategy.name isEqualToString:A0StrategyNameActiveDirectory]) {
            if (self.onShowEnterpriseLogin) {
                self.onShowEnterpriseLogin(self.matchedConnection);
            }
        } else {
            //Perform Safari Authentication
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
            showAlertErrorView(A0LocalizedString(@"There was an error logging in"), [A0Errors localizedStringForLoginError:error]);
        };
        [[A0APIClient sharedClient] loginWithUsername:username password:password parameters:self.parameters success:success failure:failure];
    } else {
        [self.accessButton setInProgress:NO];
        showAlertErrorView(error.localizedDescription, error.localizedFailureReason);
    }
    [self updateUIWithError:error];
}

- (void)goToPasswordField:(id)sender {
    [self.passwordField.textField becomeFirstResponder];
}

- (void)showSignUp:(id)sender {
    if (self.onShowSignUp) {
        self.onShowSignUp();
    }
}

- (void)showForgotPassword:(id)sender {
    if (self.onShowForgotPassword) {
        self.onShowForgotPassword();
    }
}

#pragma mark - Domain Matching

- (void)matchDomainInTextField:(UITextField *)textField {
    A0Connection *connection = [self.domainMatcher connectionForEmail:textField.text];
    if (connection) {
        Auth0LogVerbose(@"Matched %@ with connection %@", textField.text, connection);
        NSString *title = [NSString stringWithFormat:A0LocalizedString(@"Login with %@"), connection.values[@"domain"]];
        [self.accessButton setTitle:title.uppercaseString forState:UIControlStateNormal];
    } else {
        [self.accessButton setTitle:A0LocalizedString(@"ACCESS") forState:UIControlStateNormal];
    }
    self.matchedConnection = connection;
    self.singleSignOnView.hidden = connection == nil;
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
