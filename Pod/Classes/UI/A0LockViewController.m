//  A0LockViewController.m
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

#import "A0LockViewController.h"
#import "A0KeyboardHandler.h"
#import "A0Application.h"
#import "A0APIClient.h"
#import "A0IdentityProviderAuthenticator.h"
#import "A0LoadingViewController.h"
#import "A0DatabaseLoginViewController.h"
#import "A0SignUpViewController.h"
#import "A0ChangePasswordViewController.h"
#import "A0FullLoginViewController.h"
#import "A0SocialLoginViewController.h"
#import "A0Theme.h"
#import "A0Strategy.h"
#import "A0KeyboardEnabledView.h"
#import "A0AuthParameters.h"
#import "A0Connection.h"
#import "A0EnterpriseLoginViewController.h"
#import "A0SimpleConnectionDomainMatcher.h"
#import "A0AuthenticationUIComponent.h"
#import "A0ActiveDirectoryViewController.h"
#import "A0FullActiveDirectoryViewController.h"

#import <CoreText/CoreText.h>
#import <libextobjc/EXTScope.h>
#import "A0NavigationView.h"
#import "A0Errors.h"
#import "A0LockConfiguration.h"
#import "A0LockNotification.h"
#import "A0TitleView.h"
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "NSObject+A0AuthenticatorProvider.h"
#import "NSError+A0APIError.h"
#import "UIConstants.h"
#import "A0Alert.h"

@interface A0LockViewController ()

@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (strong, nonatomic) A0LockConfiguration *configuration;
@property (strong, nonatomic) A0Lock *lock;
@property (strong, nonatomic) A0LockEventDelegate *eventDelegate;

- (IBAction)dismiss:(id)sender;

@end

@implementation A0LockViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)initWithLock:(A0Lock *)lock {
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
        _usesEmail = YES;
        _loginAfterSignUp = YES;
        _authenticationParameters = [A0AuthParameters newDefaultParams];
        _defaultADUsernameFromEmailPrefix = YES;
        _connections = @[];
        _useWebView = YES;
        _eventDelegate = [[A0LockEventDelegate alloc] initWithLockViewController:self];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0Theme *theme = [A0Theme sharedInstance];
    UIImage *image = [theme imageForKey:A0ThemeScreenBackgroundImageName];
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self.view insertSubview:imageView atIndex:0];
    }
    self.view.backgroundColor = [theme colorForKey:A0ThemeScreenBackgroundColor];
    self.titleView.iconImage = [theme imageForKey:A0ThemeIconImageName];
    self.dismissButton.tintColor = [theme colorForKey:A0ThemeCloseButtonTintColor];

    [self displayController:[[A0LoadingViewController alloc] init]];

    self.dismissButton.hidden = !self.closable;

    [self loadApplicationInfo];
}

- (A0LockControllerSupportedOrientation)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)dismiss:(id)sender {
    [self.eventDelegate dismissLock];
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

#pragma mark - App info fetch

- (void)loadApplicationInfo {
    @weakify(self);
    A0APIClient *client = [self a0_apiClientFromProvider:self.lock];
    [client fetchAppInfoWithSuccess:^(A0Application *application) {
        @strongify(self);
        A0LogDebug(@"Obtained application info. Starting to build Lock UI...");
        self.configuration = [[A0LockConfiguration alloc] initWithApplication:application filter:self.connections];
        self.configuration.defaultDatabaseConnectionName = self.defaultDatabaseConnectionName;
        [self layoutRootController];
    } failure:^(NSError *error) {
        A0LogError(@"Failed to fetch App info %@", error);
        NSString *title = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"Failed to display login");
        NSString *message = [error a0_auth0ErrorWithCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : A0LocalizedString(@"Couldnt get login screen configuration. Please try again.");
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

#pragma mark - Container methods

- (void)layoutRootController {
    @weakify(self);
    void(^onAuthSuccessBlock)(A0UserProfile *, A0Token *) =  ^(A0UserProfile *profile, A0Token *token) {
        @strongify(self);
        [self.eventDelegate userAuthenticatedWithToken:token profile:profile];
    };
    UIViewController<A0AuthenticationUIComponent> *rootController;
    BOOL hasSocial = self.configuration.socialStrategies.count > 0;
    BOOL hasAD = self.configuration.activeDirectoryStrategy != nil;
    BOOL hasEnterprise = self.configuration.enterpriseStrategies.count > 0;
    BOOL hasDB = self.configuration.defaultDatabaseConnection != nil;

    A0Connection *database = self.configuration.defaultDatabaseConnection;
    A0Connection *ad = self.configuration.defaultActiveDirectoryConnection;
    A0Application *application = self.configuration.application;
    [self.navigationView removeAll];
    A0ContainerLayoutVertical layout = A0ContainerLayoutVerticalCenter;
    if ((hasDB && hasSocial) || (hasSocial && hasEnterprise && !hasAD)) {
        A0FullLoginViewController *controller = [self newFullLoginViewController:onAuthSuccessBlock];
        controller.config = self.configuration;
        controller.domainMatcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:self.configuration.enterpriseStrategies];
        controller.forceUsername = !self.usesEmail;
        controller.defaultConnection = database;
        rootController = controller;
    }
    if ((hasDB & !hasSocial) || (hasEnterprise && !hasDB && !hasSocial && !hasAD)) {
        A0DatabaseLoginViewController *controller = [self newDatabaseLoginViewController:onAuthSuccessBlock];;
        controller.domainMatcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:self.configuration.enterpriseStrategies];
        controller.forceUsername = !self.usesEmail;
        controller.defaultConnection = database ?: ad;
        rootController = controller;
    }
    if (hasSocial && !hasAD && !hasDB && !hasEnterprise) {
        A0SocialLoginViewController *controller = [self newSocialLoginViewController:onAuthSuccessBlock];
        controller.configuration = self.configuration;
        rootController = controller;
        layout = A0ContainerLayoutVerticalFill;
    }
    if (hasSocial && hasAD && !hasDB) {
        A0FullActiveDirectoryViewController *controller = [self newFullADLoginViewController:onAuthSuccessBlock];
        controller.configuration = self.configuration;
        controller.defaultConnection = ad;
        controller.domainMatcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:self.configuration.enterpriseStrategies];
        rootController = controller;
    }
    if (hasAD && !hasDB && !hasSocial) {
        A0ActiveDirectoryViewController *controller = [self newADLoginViewController:onAuthSuccessBlock];;
        controller.defaultConnection = ad;
        controller.domainMatcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:self.configuration.enterpriseStrategies];
        rootController = controller;
    }
    if (rootController) {
        rootController.parameters = [self copyAuthenticationParameters];
        rootController.lock = self.lock;
        [self displayController:rootController layout:layout];
    } else {
        NSString *title = A0LocalizedString(@"Failed to display login");
        NSString *message = A0LocalizedString(@"You have no enabled connections for your application. Please check your configuration and try again");
        [A0Alert showInController:self alert:^(A0Alert *alert) {
            alert.title = title;
            alert.message = message;
            [alert addButtonWithTitle:A0LocalizedString(@"Retry") callback:^{
                A0LogVerbose(@"Retrying fetch Auth0 app info...");
                [self loadApplicationInfo];
            }];
        }];
        A0LogError(@"Application has no enabled connections. Application Strategies: %@. Connections to filter %@.", application.strategies, self.connections);
    }
}

- (A0SocialLoginViewController *)newSocialLoginViewController:(void(^)(A0UserProfile *, A0Token *))success {
    A0SocialLoginViewController *controller = [[A0SocialLoginViewController alloc] init];
    controller.onLoginBlock = success;
    [self.navigationView removeAll];
    return controller;
}

- (A0FullLoginViewController *)newFullLoginViewController:(void(^)(A0UserProfile *, A0Token *))success {
    @weakify(self);
    A0FullLoginViewController *controller = [[A0FullLoginViewController alloc] init];
    controller.onLoginBlock = success;
    controller.parameters = [self copyAuthenticationParameters];
    controller.onShowEnterpriseLogin = ^(A0Connection *connection, NSString *email) {
        @strongify(self);
        A0EnterpriseLoginViewController *controller = [self newEnterpriseLoginViewController:success forConnection:connection withEmail:email];
        [self displayController:controller];
    };
    [self.navigationView removeAll];
    BOOL showResetPassword = ![self.configuration shouldDisableResetPassword:self.disableResetPassword];
    BOOL showSignUp = ![self.configuration shouldDisableSignUp:self.disableSignUp];
    if (showSignUp) {

        if (self.onUserSignupBlock) {
            [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"SIGN UP") actionBlock:self.onUserSignupBlock];
        } else {
            [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"SIGN UP") actionBlock:^{
                @strongify(self);
                A0SignUpViewController *controller = [self newSignUpViewControllerWithSuccess:success];
                [self displayController:controller];
            }];
        }
    }
    if (showResetPassword) {
        [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"RESET PASSWORD") actionBlock:^{
            @strongify(self);
            A0ChangePasswordViewController *controller = [self newChangePasswordViewController];
            [self displayController:controller];
        }];
    }
    return controller;
}

- (A0FullActiveDirectoryViewController *)newFullADLoginViewController:(void(^)(A0UserProfile *, A0Token *))success {
    A0FullActiveDirectoryViewController *controller = [[A0FullActiveDirectoryViewController alloc] init];
    controller.onLoginBlock = success;
    controller.parameters = [self copyAuthenticationParameters];
    [self.navigationView removeAll];
    return controller;
}

- (A0DatabaseLoginViewController *)newDatabaseLoginViewController:(void(^)(A0UserProfile *, A0Token *))success {
    @weakify(self);
    A0DatabaseLoginViewController *controller = [[A0DatabaseLoginViewController alloc] init];
    controller.onLoginBlock = success;
    controller.parameters = [self copyAuthenticationParameters];
    controller.onShowEnterpriseLogin = ^(A0Connection *connection, NSString *email) {
        @strongify(self);
        A0EnterpriseLoginViewController *controller = [self newEnterpriseLoginViewController:success forConnection:connection withEmail:email];
        [self displayController:controller];
    };
    [self.navigationView removeAll];
    BOOL showResetPassword = ![self.configuration shouldDisableResetPassword:self.disableResetPassword];
    BOOL showSignUp = ![self.configuration shouldDisableSignUp:self.disableSignUp];
    if (showSignUp) {
        [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"SIGN UP")
                                             actionBlock:[self signUpActionBlockWithSuccess:success]];
    }
    if (showResetPassword) {
        [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"RESET PASSWORD") actionBlock:^{
            @strongify(self);
            A0ChangePasswordViewController *controller = [self newChangePasswordViewController];
            [self displayController:controller];
        }];
    }
    return controller;
}

- (A0ActiveDirectoryViewController *)newADLoginViewController:(void(^)(A0UserProfile *, A0Token *))success {
    A0ActiveDirectoryViewController *controller = [[A0ActiveDirectoryViewController alloc] init];
    controller.onLoginBlock = success;
    controller.parameters = [self copyAuthenticationParameters];
    [self.navigationView removeAll];
    return controller;
}

- (A0EnterpriseLoginViewController *)newEnterpriseLoginViewController:(void(^)(A0UserProfile *, A0Token *))success
                                                        forConnection:(A0Connection *)connection
                                                            withEmail:(NSString *)email {
    @weakify(self);
    A0EnterpriseLoginViewController *controller;
    if (self.defaultADUsernameFromEmailPrefix) {
        controller = [[A0EnterpriseLoginViewController alloc] initWithEmail:email];
    } else {
        controller = [[A0EnterpriseLoginViewController alloc] init];
    }
    controller.onLoginBlock = success;
    controller.connection = connection;
    controller.parameters = [self copyAuthenticationParameters];
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"CANCEL") actionBlock:^{
        @strongify(self);
        [self layoutRootController];
    }];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"RESET PASSWORD") actionBlock:^{
        @strongify(self);
        A0ChangePasswordViewController *controller = [self newChangePasswordViewController];
        [self displayController:controller];
    }];
    return controller;
}

- (void(^)())signUpActionBlockWithSuccess:(void(^)(A0UserProfile *, A0Token *))success {
    @weakify(self);
    if (self.navigationController && self.customSignUp) {
        A0LogDebug(@"Using a custom SignUp UIViewController");
        return ^{
            @strongify(self);
            UIViewController *controller = self.customSignUp(self.lock, self.eventDelegate);
            [self.navigationController pushViewController:controller animated:YES];
        };
    }
    return ^{
        @strongify(self);
        A0SignUpViewController *controller = [self newSignUpViewControllerWithSuccess:success];
        [self displayController:controller];
    };
}

- (A0SignUpViewController *)newSignUpViewControllerWithSuccess:(void(^)(A0UserProfile *, A0Token *))success {
    A0SignUpViewController *controller = [[A0SignUpViewController alloc] init];
    controller.forceUsername = !self.usesEmail;
    controller.loginUser = self.loginAfterSignUp;
    controller.parameters = [self copyAuthenticationParameters];
    controller.defaultConnection = self.configuration.defaultDatabaseConnection;
    controller.onSignUpBlock = success;
    controller.lock = self.lock;
    [controller addDisclaimerSubview:self.signUpDisclaimerView];
    [self.navigationView removeAll];
    @weakify(self);
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"CANCEL") actionBlock:^{
        @strongify(self);
        [self layoutRootController];
    }];
    return controller;
}

- (A0ChangePasswordViewController *)newChangePasswordViewController {
    A0ChangePasswordViewController *controller = [[A0ChangePasswordViewController alloc] init];
    controller.forceUsername = !self.usesEmail;
    controller.parameters = [self copyAuthenticationParameters];
    controller.defaultConnection = self.configuration.defaultDatabaseConnection;
    controller.lock = self.lock;
    @weakify(self);
    void(^block)() = ^{
        @strongify(self);
        [self layoutRootController];
    };
    controller.onChangePasswordBlock = block;
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"CANCEL") actionBlock:block];
    return controller;
}

#pragma mark - Utility methods 

- (A0AuthParameters *)copyAuthenticationParameters {
    A0AuthParameters *parameters = self.authenticationParameters ?: [A0AuthParameters newDefaultParams];
    return parameters.copy;
}

@end
