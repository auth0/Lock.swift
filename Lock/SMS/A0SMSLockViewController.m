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
#import "A0NavigationView.h"
#import "A0TitleView.h"
#import "A0Lock.h"
#import "A0PasswordlessLockViewModel.h"
#import "A0SMSMagicLinkViewController.h"
#import "Constants.h"
#import "UIConstants.h"
#import <Masonry/Masonry.h>

#define kPhoneNumberKey @"com.auth0.lock.passwordless.sms"

@interface A0SMSLockViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (strong, nonatomic) A0Lock *lock;
@property (strong, nonatomic) A0PasswordlessLockViewModel *model;

- (IBAction)close:(id)sender;

@end

@implementation A0SMSLockViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)init {
    return [self initWithLock:[A0Lock sharedLock]];
}

- (instancetype)initWithLock:(A0Lock *)lock {
    NSAssert(lock != nil, @"Must have a non-nil Lock instance");
    self = [super init];
    if (self) {
        _lock = lock;
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

    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:dismissButton];
    [dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.right.equalTo(self.view);
        make.height.equalTo(@40);
        make.width.equalTo(@40);
    }];

    self.closeButton = dismissButton;

    NSAssert(self.navigationController != nil, @"Must be inside a UINavigationController");

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
    [self.closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton setImage:[theme imageForKey:A0ThemeCloseButtonImageName] forState:UIControlStateNormal];

    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tapRecognizer];
    A0PasswordlessLockStrategy strategy = [self isMagicLinkAvailable] ? A0PasswordlessLockStrategySMSMagicLink : A0PasswordlessLockStrategySMSCode;
    self.model = [[A0PasswordlessLockViewModel alloc] initWithLock:self.lock authenticationParameters:[self.authenticationParameters copy] strategy:strategy];
    self.model.onAuthentication = self.onAuthenticationBlock;

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phoneNumber = [defaults stringForKey:kPhoneNumberKey];
    self.model.identifier = phoneNumber;

    [self nagivateToSendCodeScreen];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
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

- (A0LockControllerSupportedOrientation)supportedInterfaceOrientations {
    A0LockControllerSupportedOrientation orientations = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        orientations = UIInterfaceOrientationMaskAll;
    }
    return orientations;
}

- (void)nagivateToSendCodeScreen {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *phoneNumber = [defaults stringForKey:kPhoneNumberKey];
    A0SMSSendCodeViewController *controller = [[A0SMSSendCodeViewController alloc] initWithViewModel:self.model];
    __weak A0SMSLockViewController *weakSelf = self;
    controller.onRegisterBlock = ^(NSString *countryCode, NSString *phoneNumber){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:phoneNumber forKey:kPhoneNumberKey];
        [defaults synchronize];
        if ([weakSelf isMagicLinkAvailable]) {
            [weakSelf navigateToWaitForMagicLinkScreen];
        } else {
            [weakSelf navigateToInputCodeScreen];
        }
    };
    [self.navigationView removeAll];
    if (phoneNumber) {
        [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"ALREADY HAVE A CODE?") actionBlock:^{
            [weakSelf navigateToInputCodeScreen];
        }];
    }
    [self displayController:controller];
}

- (void)navigateToInputCodeScreen {
    __weak A0SMSLockViewController *weakSelf = self;
    A0SMSCodeViewController *controller = [[A0SMSCodeViewController alloc] initWithViewModel:self.model];
    void(^showRegister)() = ^{
        [weakSelf nagivateToSendCodeScreen];
    };
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"DIDN'T RECEIVE CODE?") actionBlock:showRegister];
    [self displayController:controller];
}

- (void)navigateToWaitForMagicLinkScreen {
    A0SMSMagicLinkViewController *controller = [[A0SMSMagicLinkViewController alloc] initWithViewModel:self.model];
    [self.navigationView removeAll];
    __weak A0SMSLockViewController *weakSelf = self;
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"LET ME ENTER A CODE") actionBlock:^{
        [weakSelf navigateToInputCodeScreen];
    }];
    [self displayController:controller];
}

- (BOOL)isMagicLinkAvailable {
    return self.useMagicLink && floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_3;
}

@end
