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

@interface A0TouchIDSignUpViewController ()

@property (weak, nonatomic) IBOutlet A0ProgressButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *credentialBoxView;

- (IBAction)signUp:(id)sender;

@property (strong, nonatomic) A0EmailValidator *validator;

@end

@implementation A0TouchIDSignUpViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0Theme *theme = [A0Theme sharedInstance];
    [theme configurePrimaryButton:self.signUpButton];
    [theme configureSecondaryButton:self.cancelButton];
    [theme configureSecondaryButton:self.loginButton];
    [theme configureTextField:self.emailField.textField];
    [theme configureLabel:self.messageLabel];
    
    self.validator = [[A0EmailValidator alloc] initWithField:self.emailField.textField];
    self.title = A0LocalizedString(@"Register");
    [self.emailField setFieldPlaceholderText:A0LocalizedString(@"Email")];
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
                               if (self.onRegisterBlock) {
                                   self.onRegisterBlock(profile, tokenInfo);
                                   [self.signUpButton setInProgress:NO];
                               }
                           } failure:^(NSError *error){
                               [self.signUpButton setInProgress:NO];
                               NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error signing up");
                               NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : [A0Errors localizedStringForSignUpError:error];
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
