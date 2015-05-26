// A0SMSLockViewController.m
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

#import "A0SMSLockViewController.h"
#import "A0Theme.h"
#import "A0SMSSendCodeViewController.h"
#import "A0AuthParameters.h"
#import "A0SMSCodeViewController.h"
#import <libextobjc/EXTScope.h>
#import "A0NavigationView.h"
#import "A0TitleView.h"
#import "A0Lock.h"

#define kCountryCodeKey @"auth0-lock-sms-country-code"
#define kPhoneNumberKey @"auth0-lock-sms-phone"

@interface A0SMSLockViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) A0Lock *lock;

- (IBAction)close:(id)sender;

@end

@implementation A0SMSLockViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)initWithLock:(A0Lock *)lock {
    NSAssert(lock != nil, @"Must have a non-nil Lock instance");
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        _lock = lock;
    }
    return self;
}

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        _closable = NO;
        _authenticationParameters = [A0AuthParameters newDefaultParams];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSAssert(self.navigationController != nil, @"Must be inside a UINavigationController");
    NSAssert(self.auth0APIToken != nil, @"Must provide an API Token for v2 API");

    self.navigationController.navigationBarHidden = YES;

    self.closeButton.enabled = self.closable;
    self.closeButton.hidden = !self.closable;

    A0Theme *theme = [A0Theme sharedInstance];
    UIImage *image = [theme imageForKey:A0ThemeScreenBackgroundImageName];
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self.view insertSubview:imageView atIndex:0];
    }
    self.view.backgroundColor = [theme colorForKey:A0ThemeScreenBackgroundColor];
    self.titleView.iconImage = [theme imageForKey:A0ThemeIconImageName];
    self.closeButton.tintColor = [theme colorForKey:A0ThemeSecondaryButtonTextColor];

    [self displayController:[self buildSMSSendCode]];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tapRecognizer];
}

- (void)close:(id)sender {
    A0LogVerbose(@"Dismissing SMS view controller on user's request.");
    if (self.onUserDismissBlock) {
        self.onUserDismissBlock();
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)hideKeyboard:(UIGestureRecognizer *)recognizer {
    UIViewController<A0KeyboardEnabledView> *controller = self.childViewControllers.firstObject;
    [controller hideKeyboard];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [[A0Theme sharedInstance] statusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [[A0Theme sharedInstance] statusBarHidden];
}

- (A0SMSSendCodeViewController *)buildSMSSendCode {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phoneNumber = [defaults stringForKey:kPhoneNumberKey];
    NSString *countryCode = [defaults stringForKey:kCountryCodeKey];
    A0SMSSendCodeViewController *controller = [[A0SMSSendCodeViewController alloc] init];
    @weakify(self);
    controller.onRegisterBlock = ^(NSString *countryCode, NSString *phoneNumber){
        @strongify(self);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:countryCode forKey:kCountryCodeKey];
        [defaults setObject:phoneNumber forKey:kPhoneNumberKey];
        [defaults synchronize];
        [self displayController:[self buildSMSCodeWithNumber:phoneNumber]];
    };
    controller.auth0APIToken = self.auth0APIToken;
    controller.currentPhoneNumber = phoneNumber;
    controller.currentCountry = countryCode;
    controller.lock = self.lock;
    [self.navigationView removeAll];
    if (phoneNumber) {
        [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"ALREADY HAVE A CODE?") actionBlock:^{
            @strongify(self);
            [self displayController:[self buildSMSCodeWithNumber:phoneNumber]];
        }];
    }
    return controller;
}

- (A0SMSCodeViewController *)buildSMSCodeWithNumber:(NSString *)phoneNumber {
    @weakify(self);
    A0SMSCodeViewController *controller = [[A0SMSCodeViewController alloc] init];
    controller.phoneNumber = phoneNumber;
    controller.parameters = self.authenticationParameters;
    controller.onAuthenticationBlock = self.onAuthenticationBlock;
    controller.lock = self.lock;
    void(^showRegister)() = ^{
        @strongify(self);
        [self displayController:[self buildSMSSendCode]];
    };
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"DIDN'T RECEIVE CODE?") actionBlock:showRegister];
    return controller;
}

@end
