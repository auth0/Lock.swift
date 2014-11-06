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
#import "A0SignUpCredentialValidator.h"
#import "A0APIClient.h"
#import "A0Errors.h"

#import <libextobjc/EXTScope.h>
#import <ObjectiveSugar/ObjectiveSugar.h>

static void showAlertErrorView(NSString *title, NSString *message) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:A0LocalizedString(@"OK")
                                          otherButtonTitles:nil];
    [alert show];
}

@interface A0TouchIDSignUpViewController ()

@property (weak, nonatomic) IBOutlet A0ProgressButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *credentialBoxView;

- (IBAction)signUp:(id)sender;

@property (strong, nonatomic) A0SignUpCredentialValidator *validator;

@end

@implementation A0TouchIDSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.credentialBoxView.layer.borderWidth = 1.0f;
    self.credentialBoxView.layer.borderColor = [[UIColor colorWithWhite:0.600 alpha:1.000] CGColor];
    self.credentialBoxView.layer.cornerRadius = 3.0f;

    A0Theme *theme = [A0Theme sharedInstance];
    [theme configurePrimaryButton:self.signUpButton];
    [theme configureSecondaryButton:self.cancelButton];
    [theme configureSecondaryButton:self.loginButton];
    [theme configureTextField:self.emailField.textField];
    [theme configureLabel:self.messageLabel];
    self.validator = [[A0SignUpCredentialValidator alloc] initWithUsesEmail:YES];
    self.title = A0LocalizedString(@"Register");
}

- (void)signUp:(id)sender {
    NSError *error;
    [self.signUpButton setInProgress:YES];
    [self hideKeyboard];
    NSString *username = [self.emailField.textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *password = [self randomStringWithLength:14];
    [self.validator setUsername:self.emailField.textField.text password:password];
    if ([self.validator validateCredential:&error]) {
        @weakify(self);
        Auth0LogDebug(@"Registering user with email %@ for TouchID", username);
        A0APIClient *client = [A0APIClient sharedClient];
        [client signUpWithUsername:username
                          password:password
                    loginOnSuccess:YES
                        parameters:self.authenticationParameters
                           success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                               @strongify(self);
                               if (self.onRegisterBlock) {
                                   self.onRegisterBlock(profile, tokenInfo);
                                   [self.signUpButton setInProgress:NO];
                               }
                           } failure:^(NSError *error){
                               @strongify(self);
                               [self.signUpButton setInProgress:NO];
                               showAlertErrorView(A0LocalizedString(@"There was an error signing up"), [A0Errors localizedStringForSignUpError:error]);
                           }];
    } else {
        [self.signUpButton setInProgress:NO];
        showAlertErrorView(error.localizedDescription, error.localizedFailureReason);
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
    [@(len) times:^{
        [randomString appendFormat: @"%C", [letters characterAtIndex:arc4random_uniform((u_int32_t)[letters length])]];
    }];

    return randomString;
}

@end
