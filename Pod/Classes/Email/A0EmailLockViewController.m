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
#import "A0EmailLockViewModel.h"
#import "A0EmailMagicLinkViewController.h"
#import <libextobjc/EXTScope.h>

#define kEmailKey @"auth0-lock-email-email"

@interface A0EmailLockViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) A0Lock *lock;
@property (strong, nonatomic) A0EmailLockViewModel *viewModel;

- (IBAction)close:(id)sender;

@end

@implementation A0EmailLockViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)initWithLock:(A0Lock *)lock {
    NSAssert(lock != nil, @"Must have a non-nil Lock instance");
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];
    if (self) {
        _lock = lock;
    }
    return self;
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

    if (self.useMagicLink) {
        self.viewModel = [[A0EmailLockViewModel alloc] initForMagicLinkWithLock:self.lock authenticationParameters:self.authenticationParameters];
    } else {
        self.viewModel = [[A0EmailLockViewModel alloc] initWithLock:self.lock authenticationParameters:self.authenticationParameters];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults stringForKey:kEmailKey];
    self.viewModel.email = email;

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

- (void)navigateToRequestCodeScreen {
    A0EmailSendCodeViewController *controller = [[A0EmailSendCodeViewController alloc] initWithViewModel:self.viewModel];
    @weakify(self);
    controller.didRequestVerificationCode = ^(){
        @strongify(self);
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.viewModel.email forKey:kEmailKey];
        [defaults synchronize];
        if (self.useMagicLink) {
            [self navigateToWaitForMagicLinkScreen];
        } else {
            [self navigateToInputCodeScreen];
        }
    };
    [self.navigationView removeAll];
    if (self.viewModel.hasEmail && !self.useMagicLink) {
        [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"ALREADY HAVE A CODE?") actionBlock:^{
            @strongify(self);
            [self navigateToInputCodeScreen];
        }];
    }
    [self displayController:controller];
}

- (void)navigateToInputCodeScreen {
    @weakify(self);
    A0EmailCodeViewController *controller = [[A0EmailCodeViewController alloc] initWithViewModel:self.viewModel];
    controller.onAuthenticationBlock = self.onAuthenticationBlock;
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"DIDN'T RECEIVE CODE?") actionBlock:^{
        @strongify(self);
        [self navigateToRequestCodeScreen];
    }];
    [self displayController:controller];
}

- (void)navigateToWaitForMagicLinkScreen {
    A0EmailMagicLinkViewController *controller = [[A0EmailMagicLinkViewController alloc] initWithViewModel:self.viewModel];
    [self.navigationView removeAll];
    [self displayController:controller];
}

@end
