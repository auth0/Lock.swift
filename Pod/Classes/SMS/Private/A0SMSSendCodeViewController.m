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
#import "A0RequestAccessTokenOperation.h"
#import "A0SendSMSOperation.h"
#import "A0UIUtilities.h"

#import <libextobjc/EXTScope.h>
#import "A0Errors.h"
#import "A0Lock.h"

@interface A0SMSSendCodeViewController ()

@property (weak, nonatomic) IBOutlet A0PhoneFieldView *phoneFieldView;
@property (weak, nonatomic) IBOutlet A0ProgressButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

- (IBAction)registerSMS:(id)sender;

@end

@implementation A0SMSSendCodeViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);

    self.title = A0LocalizedString(@"Send Passcode");
    A0Theme *theme = [A0Theme sharedInstance];
    [theme configureTextField:self.phoneFieldView.textField];
    [theme configurePrimaryButton:self.registerButton];
    [theme configureLabel:self.messageLabel];
    self.messageLabel.text = A0LocalizedString(@"Please enter your phone number");
    [self.phoneFieldView setFieldPlaceholderText:A0LocalizedString(@"Phone Number")];
    [self.registerButton setTitle:A0LocalizedString(@"SEND") forState:UIControlStateNormal];

    self.currentCountry = self.currentCountry ?: [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    self.phoneFieldView.countryCode = [A0CountryCodeTableViewController dialCodeForCountryWithCode:self.currentCountry];
    if (self.currentPhoneNumber) {
        NSString *countryDialCode = [self.phoneFieldView.countryCode stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.phoneFieldView.textField.text = [self.currentPhoneNumber stringByReplacingOccurrencesOfString:countryDialCode
                                                                                                withString:@""];
    }

    self.phoneFieldView.onCountryCodeTapped = ^(NSString *currentCode){
        @strongify(self);
        A0CountryCodeTableViewController *controller = [[A0CountryCodeTableViewController alloc] init];
        controller.defaultCountry = self.currentCountry;
        controller.onCountrySelect = ^(NSString *country, NSString *dialCode) {
            @strongify(self);
            self.currentCountry = country;
            self.phoneFieldView.countryCode = dialCode;
            A0LogDebug(@"Selected country %@ with dial code %@", country, dialCode);
        };
        [self.navigationController pushViewController:controller animated:YES];
    };
}

- (void)registerSMS:(id)sender {
    if (self.phoneFieldView.phoneNumber.length > 0) {
        [self.phoneFieldView setInvalid:NO];
        [self.phoneFieldView.textField resignFirstResponder];
        A0LogDebug(@"Registering phone number %@", self.phoneFieldView.fullPhoneNumber);
        [self.registerButton setInProgress:YES];
        NSString *phoneNumber = self.phoneFieldView.fullPhoneNumber;
        NSString *apiToken;
        if (self.auth0APIToken) {
            apiToken = self.auth0APIToken();
        }
        if (apiToken) {
            @weakify(self);
            void(^onFailure)(NSError *) = ^(NSError *error) {
                @strongify(self);
                A0LogError(@"Failed to send SMS code with error %@", error);
                NSString *title = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"There was an error sending the SMS code");
                NSString *message = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : A0LocalizedString(@"Couldn't send an SMS to your phone. Please try again later.");
                A0ShowAlertErrorView(title, message);
                [self.registerButton setInProgress:NO];
            };
            A0LogDebug(@"About to send SMS code to phone %@", phoneNumber);
            NSURL *baseURL = self.lock.domainURL;
            A0SendSMSOperation *operation = [[A0SendSMSOperation alloc] initWithBaseURL:baseURL jwt:apiToken phoneNumber:phoneNumber];
            [operation setSuccess:^{
                @strongify(self);
                A0LogDebug(@"SMS code sent to phone %@", phoneNumber);
                [self.registerButton setInProgress:NO];
                if (self.onRegisterBlock) {
                    self.onRegisterBlock(self.currentCountry, self.phoneFieldView.fullPhoneNumber);
                }
            } failure:onFailure];
            [operation start];
        } else {
            A0LogError(@"No API Secret was configured to send SMS");
            A0ShowAlertErrorView(A0LocalizedString(@"There was an error sending the SMS code"), A0LocalizedString(@"Auth0's API Secret wasn't found. Please set your app's API Secret before sending SMS."));
        }
    } else {
        A0LogError(@"No phone number provided");
        [self.phoneFieldView setInvalid:YES];
        A0ShowAlertErrorView(A0LocalizedString(@"There was an error sending the SMS code"), A0LocalizedString(@"You must enter a valid phone number"));
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
