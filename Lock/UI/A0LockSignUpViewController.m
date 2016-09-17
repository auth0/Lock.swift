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
#import "A0KeyboardHandler.h"
#import "NSError+A0LockErrors.h"
#import <Masonry/Masonry.h>

@interface A0LockSignUpViewController () <A0SmallSocialServiceCollectionViewDelegate>

@property (weak, nonatomic) UIButton *dismissButton;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) UIView *loadingView;
@property (weak, nonatomic) A0SmallSocialServiceCollectionView *serviceCollectionView;
@property (weak, nonatomic) A0TitleView *titleView;
@property (weak, nonatomic) UIView *authenticationView;

@property (strong, nonatomic) A0LockConfiguration *configuration;
@property (strong, nonatomic) A0Lock *lock;
@property (strong, nonatomic) A0KeyboardHandler *keyboardHandler;


@end

@implementation A0LockSignUpViewController

- (instancetype)init {
    return [self initWithLock:[A0Lock sharedLock]];
}

- (instancetype)initWithLock:(A0Lock *)lock {
    NSAssert(lock != nil, @"Must have a non-nil Lock instance");
    self = [super init];
    if (self) {
        _lock = lock;
        _loginAfterSignUp = YES;
        _authenticationParameters = [A0AuthParameters newDefaultParams];
        _connections = @[];
        _keyboardHandler = [[A0KeyboardHandler alloc] init];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.keyboardHandler start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.keyboardHandler stop];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    A0TitleView *titleView = [[A0TitleView alloc] init];
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    UIButton *dismissButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectZero];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    UIView *authenticationView = [[UIView alloc] initWithFrame:CGRectZero];
    A0SmallSocialServiceCollectionView *serviceCollectionView = [[A0SmallSocialServiceCollectionView alloc] init];

    [authenticationView addSubview:serviceCollectionView];
    [serviceCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.and.right.equalTo(authenticationView);
        make.height.equalTo(@60);
    }];

    [loadingView addSubview:activityIndicator];
    [activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(loadingView);
    }];

    [containerView addSubview:loadingView];
    [containerView addSubview:authenticationView];
    [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(containerView);
        make.centerY.equalTo(containerView);
        make.height.equalTo(@273);
    }];
    [authenticationView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(containerView);
        make.centerY.equalTo(containerView);
        make.height.equalTo(@330);
    }];

    [self.view addSubview:titleView];
    [self.view addSubview:dismissButton];
    [self.view addSubview:containerView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(20).with.priority(500);
        make.top.equalTo(self.view).offset(50).with.priority(800);
        make.height.equalTo(@110);
    }];
    [dismissButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@40);
        make.width.equalTo(titleView.mas_height);
        make.top.equalTo(self.view).offset(10);
        make.right.equalTo(self.view);
    }];
    [containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.and.right.equalTo(self.view);
        make.top.equalTo(titleView.mas_bottom);
        make.height.greaterThanOrEqualTo(@330);
    }];

    self.titleView = titleView;
    self.serviceCollectionView = serviceCollectionView;
    self.dismissButton = dismissButton;
    self.loadingView = loadingView;
    self.activityIndicator = activityIndicator;
    self.authenticationView = authenticationView;

    A0Theme *theme = [A0Theme sharedInstance];
    self.serviceCollectionView.backgroundColor = [UIColor clearColor];
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

    containerView.backgroundColor = [UIColor clearColor];
    self.titleView.backgroundColor = [UIColor clearColor];
    self.titleView.title = A0LocalizedString(@"Sign Up");

    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    [self.view addGestureRecognizer:tapGesture];
    [self displayController:[[A0LoadingViewController alloc] init]];
    [self loadApplicationInfo];
}

- (A0LockControllerSupportedOrientation)supportedInterfaceOrientations {
    A0LockControllerSupportedOrientation orientations = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        orientations = UIInterfaceOrientationMaskAll;
    }
    return orientations;
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

- (void)displayController:(UIViewController<A0KeyboardEnabledView> *)controller {
    UIViewController *from = self.childViewControllers.firstObject;
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.keyboardHandler handleForView:controller inView:self.view];
    [from willMoveToParentViewController:nil];
    [self addChildViewController:controller];
    [self.authenticationView addSubview:controller.view];
    [controller.view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.and.right.equalTo(self.authenticationView);
        make.top.equalTo(self.serviceCollectionView.mas_bottom);
    }];
    [self animateFromViewController:from toViewController:controller];
}

- (void)animateFromViewController:(UIViewController *)from toViewController:(UIViewController *)to {
    A0LogDebug(@"Starting animation to show %@", NSStringFromClass(to.class));
    to.view.alpha = 0.0f;
    from.view.alpha = 0.0f;
    [UIView animateWithDuration:0.3f animations:^{
        to.view.alpha = 1.0f;
        self.titleView.title = to.title;
    } completion:^(BOOL finished) {
        [from.view removeFromSuperview];
        [from removeFromParentViewController];
        [to didMoveToParentViewController:self];
    }];
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
        controller.lock = self.lock;
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
