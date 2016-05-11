// A0EmailLockViewController.m
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

#import "A0EmailLockViewController.h"
#import "A0Theme.h"
#import "A0EmailSendCodeViewController.h"
#import "A0AuthParameters.h"
#import "A0EmailCodeViewController.h"
#import "A0NavigationView.h"
#import "A0TitleView.h"
#import "A0Lock.h"
#import "A0PasswordlessLockViewModel.h"
#import "A0EmailMagicLinkViewController.h"
#import "Constants.h"
#import "UIConstants.h"
#import <Masonry/Masonry.h>

#define kEmailKey @"com.auth0.lock.passwordless.email"

@interface A0EmailLockViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) A0Lock *lock;
@property (strong, nonatomic) A0PasswordlessLockViewModel *viewModel;

- (IBAction)close:(id)sender;

@end

@implementation A0EmailLockViewController

AUTH0_DYNAMIC_LOGGER_METHODS

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
    
    NSAssert(self.navigationController != nil, @"Must be inside a UINavigationController");
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.view addSubview:dismissButton];
    [dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.right.equalTo(self.view);
        make.height.equalTo(@40);
        make.width.equalTo(@40);
    }];

    self.closeButton = dismissButton;

    A0PasswordlessLockStrategy strategy = [self isMagicLinkAvailable] ? A0PasswordlessLockStrategyEmailMagicLink : A0PasswordlessLockStrategyEmailCode;
    self.viewModel = [[A0PasswordlessLockViewModel alloc] initWithLock:self.lock authenticationParameters:self.authenticationParameters strategy:strategy];
    self.viewModel.onAuthentication = self.onAuthenticationBlock;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults stringForKey:kEmailKey];
    self.viewModel.identifier = email;

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

    [self navigateToRequestCodeScreen];
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

- (void)navigateToRequestCodeScreen {
    A0EmailSendCodeViewController *controller = [[A0EmailSendCodeViewController alloc] initWithViewModel:self.viewModel];
    __weak A0EmailLockViewController *weakSelf = self;
    BOOL magicLinkAvailable = [self isMagicLinkAvailable];
    controller.didRequestVerificationCode = ^(){
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:weakSelf.viewModel.identifier forKey:kEmailKey];
        [defaults synchronize];
        if (magicLinkAvailable) {
            [weakSelf navigateToWaitForMagicLinkScreen];
        } else {
            [weakSelf navigateToInputCodeScreen];
        }
    };
    [self.navigationView removeAll];
    if (self.viewModel.hasIdentifier && !magicLinkAvailable) {
        [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"ALREADY HAVE A CODE?") actionBlock:^{
            [weakSelf navigateToInputCodeScreen];
        }];
    }
    [self displayController:controller];
}

- (void)navigateToInputCodeScreen {
    __weak A0EmailLockViewController *weakSelf = self;
    A0EmailCodeViewController *controller = [[A0EmailCodeViewController alloc] initWithViewModel:self.viewModel];
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"DIDN'T RECEIVE CODE?") actionBlock:^{
        [weakSelf navigateToRequestCodeScreen];
    }];
    [self displayController:controller];
}

- (void)navigateToWaitForMagicLinkScreen {
    A0EmailMagicLinkViewController *controller = [[A0EmailMagicLinkViewController alloc] initWithViewModel:self.viewModel];
    [self.navigationView removeAll];
    __weak A0EmailLockViewController *weakSelf = self;
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"LET ME ENTER A CODE") actionBlock:^{
        [weakSelf navigateToInputCodeScreen];
    }];
    [self displayController:controller];
}

- (BOOL)isMagicLinkAvailable {
    return self.useMagicLink && floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_3;
}
@end
