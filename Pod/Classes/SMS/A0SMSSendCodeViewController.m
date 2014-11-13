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

#import <libextobjc/EXTScope.h>

@interface A0SMSSendCodeViewController ()

@property (weak, nonatomic) IBOutlet UIView *credentialBoxView;
@property (weak, nonatomic) IBOutlet A0PhoneFieldView *phoneFieldView;
@property (weak, nonatomic) IBOutlet A0ProgressButton *registerButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@property (copy, nonatomic) NSString *currentCountry;

- (IBAction)registerSMS:(id)sender;

@end

@implementation A0SMSSendCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);

    self.title = A0LocalizedString(@"Send Passcode");
    self.credentialBoxView.layer.borderWidth = 1.0f;
    self.credentialBoxView.layer.borderColor = [[UIColor colorWithWhite:0.600 alpha:1.000] CGColor];
    self.credentialBoxView.layer.cornerRadius = 3.0f;
    A0Theme *theme = [A0Theme sharedInstance];
    [theme configureTextField:self.phoneFieldView.textField];
    [theme configurePrimaryButton:self.registerButton];
    [theme configureLabel:self.messageLabel];
    self.messageLabel.text = A0LocalizedString(@"Please enter your phone number");
    self.phoneFieldView.textField.placeholder = A0LocalizedString(@"Phone Number");
    [self.registerButton setTitle:A0LocalizedString(@"SEND") forState:UIControlStateNormal];

    self.currentCountry = @"US";
    self.phoneFieldView.onCountryCodeTapped = ^(NSString *currentCode){
        @strongify(self);
        A0CountryCodeTableViewController *controller = [[A0CountryCodeTableViewController alloc] init];
        controller.defaultCountry = self.currentCountry;
        controller.onCountrySelect = ^(NSString *country, NSString *dialCode) {
            @strongify(self);
            self.currentCountry = country;
            self.phoneFieldView.countryCode = dialCode;
            Auth0LogDebug(@"Selected country %@ with dial code %@", country, dialCode);
        };
        [self.navigationController pushViewController:controller animated:YES];
    };
}

- (void)registerSMS:(id)sender {
    if (self.phoneFieldView.phoneNumber.length > 0) {
        [self.phoneFieldView setInvalid:NO];
        [self.phoneFieldView.textField resignFirstResponder];
        if (self.onRegisterBlock) {
            self.onRegisterBlock();
        }
    } else {
        [self.phoneFieldView setInvalid:YES];
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
