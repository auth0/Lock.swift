// A0SMSSendCodeViewController.m
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

#import "A0SMSSendCodeViewController.h"
#import "A0PhoneFieldView.h"
#import "A0Theme.h"
#import "A0ProgressButton.h"
#import "A0CountryCodeTableViewController.h"
#import "A0APIClient.h"
#import "A0Alert.h"

#import "A0Errors.h"
#import "A0Lock.h"
#import "NSError+A0APIError.h"
#import "A0PasswordlessLockViewModel.h"
#import "Constants.h"

@interface A0SMSSendCodeViewController ()

@property (weak, nonatomic) IBOutlet A0PhoneFieldView *phoneFieldView;
@property (weak, nonatomic) IBOutlet A0ProgressButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (strong, nonatomic) A0PasswordlessLockViewModel *model;

- (IBAction)registerSMS:(id)sender;

@end

@implementation A0SMSSendCodeViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)initWithViewModel:(A0PasswordlessLockViewModel *)viewModel {
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        _model = viewModel;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = A0LocalizedString(@"Send Passcode");
    A0Theme *theme = [A0Theme sharedInstance];
    [theme configureTextField:self.phoneFieldView.textField];
    [theme configurePrimaryButton:self.registerButton];
    [theme configureLabel:self.messageLabel];
    self.messageLabel.text = A0LocalizedString(@"Enter your phone to sign in or create an account");
    [self.phoneFieldView setFieldPlaceholderText:A0LocalizedString(@"Phone Number")];
    [self.registerButton setTitle:A0LocalizedString(@"SEND") forState:UIControlStateNormal];

    NSArray *parts = [self.model.identifier componentsSeparatedByString:@" "];
    NSString *code = parts.count > 2 ? [[parts[0] stringByAppendingString:@" "] stringByAppendingString:parts[1]] : parts.firstObject;
    self.phoneFieldView.countryCode = code ?: [A0CountryCodeTableViewController dialCodeForCountryWithCode:[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode]];
    if (parts.lastObject) {
        self.phoneFieldView.textField.text = parts.lastObject;
    }

    __weak A0SMSSendCodeViewController *weakSelf = self;
    self.phoneFieldView.onCountryCodeTapped = ^(NSString *currentCode){
        A0CountryCodeTableViewController *controller = [[A0CountryCodeTableViewController alloc] init];
        controller.onCountrySelect = ^(NSString *country, NSString *dialCode) {
            weakSelf.phoneFieldView.countryCode = dialCode;
            A0LogDebug(@"Selected country %@ with dial code %@", country, dialCode);
        };
        [weakSelf.navigationController pushViewController:controller animated:YES];
    };
}

- (void)registerSMS:(id)sender {
    self.model.identifier = self.phoneFieldView.fullPhoneNumber;
    NSError *error = self.model.identifierError;
    if (!error) {
        [self.phoneFieldView setInvalid:NO];
        [self.phoneFieldView.textField resignFirstResponder];
        A0LogDebug(@"Registering phone number %@", self.phoneFieldView.fullPhoneNumber);
        [self.registerButton setInProgress:YES];
        NSString *phoneNumber = self.phoneFieldView.fullPhoneNumber;
        void(^onFailure)(NSError *) = ^(NSError *error) {
            A0LogError(@"Failed to send SMS code with error %@", error);
            NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error sending the SMS code");
            NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : A0LocalizedString(@"Couldn't send an SMS to your phone. Please try again later.");
            [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
                alert.title = title;
                alert.message = message;
            }];
            [self.registerButton setInProgress:NO];
        };
        A0LogDebug(@"About to send SMS code to phone %@", phoneNumber);
        [self.model requestVerificationCodeWithCallback:^(NSError * _Nullable error) {
            if (error) {
                onFailure(error);
                return;
            }
            A0LogDebug(@"SMS code sent to phone %@", phoneNumber);
            [self.registerButton setInProgress:NO];
            if (self.onRegisterBlock) {
                self.onRegisterBlock(self.phoneFieldView.countryCode, self.phoneFieldView.fullPhoneNumber);
            }
        }];
    } else {
        A0LogError(@"No phone number provided");
        [self.phoneFieldView setInvalid:YES];
        [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
            alert.title = error.localizedDescription;
            alert.message = error.localizedFailureReason;
        }];
    }
}

#pragma mark - A0KeyboardEnabledView

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    CGRect rect = [view convertRect:self.registerButton.frame fromView:self.registerButton.superview];
    return rect;
}

- (void)hideKeyboard {
    [self.phoneFieldView.textField resignFirstResponder];
}
@end
