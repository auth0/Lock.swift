// A0LockSignUpViewController.m
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

#import "A0LockSignUpViewController.h"
#import "A0Application.h"
#import "A0AuthParameters.h"
#import "A0Theme.h"
#import "A0SmallSocialServiceCollectionView.h"
#import "A0LoadingViewController.h"
#import "A0IdentityProviderAuthenticator.h"
#import "A0APIClient.h"
#import "A0LockConfiguration.h"
#import "A0Errors.h"
#import "A0SignUpViewController.h"
#import "A0Alert.h"
#import "A0TitleView.h"
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "NSObject+A0AuthenticatorProvider.h"
#import "NSError+A0APIError.h"
#import "UIConstants.h"
#import "A0Alert.h"
#import "Constants.h"

@interface A0LockSignUpViewController () <A0SmallSocialServiceCollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet A0SmallSocialServiceCollectionView *serviceCollectionView;

@property (strong, nonatomic) A0LockConfiguration *configuration;
@property (strong, nonatomic) A0Lock *lock;

@end

@implementation A0LockSignUpViewController

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
        _loginAfterSignUp = YES;
        _authenticationParameters = [A0AuthParameters newDefaultParams];
        _connections = @[];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    A0Theme *theme = [A0Theme sharedInstance];
    self.serviceCollectionView.authenticationDelegate = self;
    self.serviceCollectionView.parameters = [self copyAuthenticationParameters];
    self.activityIndicator.color = [theme colorForKey:A0ThemeTitleTextColor];
    UIImage *image = [theme imageForKey:A0ThemeScreenBackgroundImageName];
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self.view insertSubview:imageView atIndex:0];
    }
    self.view.backgroundColor = [theme colorForKey:A0ThemeScreenBackgroundColor];
    self.view.backgroundColor = [theme colorForKey:A0ThemeScreenBackgroundColor];
    self.titleView.iconImage = [theme imageForKey:A0ThemeIconImageName];
    self.dismissButton.tintColor = [theme colorForKey:A0ThemeCloseButtonTintColor];

    [self displayController:[[A0LoadingViewController alloc] init]];
    [self loadApplicationInfo];
}

- (A0LockControllerSupportedOrientation)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (IBAction)dismiss:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    if (self.onUserDismissBlock) {
        self.onUserDismissBlock();
    }
}

- (IBAction)hideKeyboard:(id)sender {
    UIViewController *controller = self.childViewControllers.firstObject;
    if ([controller conformsToProtocol:@protocol(A0KeyboardEnabledView)]) {
        id<A0KeyboardEnabledView> current = (id<A0KeyboardEnabledView>)controller;
        [current hideKeyboard];
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [[A0Theme sharedInstance] statusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [[A0Theme sharedInstance] statusBarHidden];
}

#pragma mark - A0SmallSocialServiceCollectionViewDelegate

- (void)socialServiceCollectionView:(A0SmallSocialServiceCollectionView *)collectionView
     didAuthenticateUserWithProfile:(A0UserProfile *)profile
                              token:(A0Token *)token {
    if (self.onAuthenticationBlock) {
        self.onAuthenticationBlock(profile, token);
    }
}

- (void)socialServiceCollectionView:(A0SmallSocialServiceCollectionView *)collectionView
                   didFailWithError:(NSError *)error {
    [A0Alert showInController:self errorAlert:^(A0Alert *alert) {
        alert.title = error.localizedDescription;
        alert.message = error.localizedFailureReason;
    }];
}

- (void)authenticationDidStartForSocialCollectionView:(A0SmallSocialServiceCollectionView *)collectionView {
    [self setInProgress:YES];
}

- (void)authenticationDidEndForSocialCollectionView:(A0SmallSocialServiceCollectionView *)collectionView {
    [self setInProgress:NO];
}

- (void)socialServiceCollectionView:(A0SmallSocialServiceCollectionView *)collectionView
              presentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Utility methods

- (void)setInProgress:(BOOL)inProgress {
    if (inProgress) {
        self.loadingView.alpha = 0.0f;
        self.loadingView.hidden = NO;
        [self.view bringSubviewToFront:self.loadingView];
        [UIView animateWithDuration:0.5f animations:^{
            self.loadingView.alpha = 1.0f;
        }];
    } else {
        [UIView animateWithDuration:0.5f animations:^{
            self.loadingView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.loadingView.hidden = YES;
            [self.view sendSubviewToBack:self.loadingView];
        }];
    }
}

- (void)loadApplicationInfo {
    A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
    [client fetchAppInfoWithSuccess:^(A0Application *application) {
        A0LogDebug(@"Obtained application info. Starting to build Lock UI for Sign Up...");
        A0LockConfiguration *configuration = [[A0LockConfiguration alloc] initWithApplication:application filter:self.connections];
        configuration.defaultDatabaseConnectionName = self.defaultDatabaseConnectionName;
        self.serviceCollectionView.lock = self.lock;
        [self.serviceCollectionView showSocialServicesForConfiguration:configuration];
        A0SignUpViewController *controller = [[A0SignUpViewController alloc] init];
        controller.loginUser = self.loginAfterSignUp;
        controller.parameters = [self copyAuthenticationParameters];
        controller.onSignUpBlock = self.onAuthenticationBlock;
        controller.customMessage = A0LocalizedString(@"Or please enter your email and password");
        controller.defaultConnection = configuration.defaultDatabaseConnection;
        [self displayController:controller];
    } failure:^(NSError *error) {
        A0LogError(@"Failed to fetch App info %@", error);
        NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"Failed to display Sign Up");
        NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : A0LocalizedString(@"Couldnt get Sign Up screen configuration. Please try again.");
        [A0Alert showInController:self alert:^(A0Alert *alert) {
            alert.title = title;
            alert.message = message;
            [alert addButtonWithTitle:A0LocalizedString(@"Retry") callback:^{
                A0LogVerbose(@"Retrying fetch Auth0 app info...");
                [self loadApplicationInfo];
            }];
        }];
    }];
}

- (A0AuthParameters *)copyAuthenticationParameters {
    A0AuthParameters *parameters = self.authenticationParameters ?: [A0AuthParameters newDefaultParams];
    return parameters.copy;
}

@end
