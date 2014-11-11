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
#import "A0DatabaseLoginCredentialValidator.h"
#import "A0SignUpCredentialValidator.h"
#import "A0ChangePasswordCredentialValidator.h"
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

@interface A0LockViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *iconContainerView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (strong, nonatomic) A0Application *application;

- (IBAction)dismiss:(id)sender;

@end

@implementation A0LockViewController

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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0Theme *theme = [A0Theme sharedInstance];
    self.view.backgroundColor = [theme colorForKey:A0ThemeScreenBackgroundColor defaultColor:self.view.backgroundColor];
    self.iconContainerView.backgroundColor = [theme colorForKey:A0ThemeIconBackgroundColor defaultColor:self.iconContainerView.backgroundColor];
    self.iconImageView.image = [theme imageForKey:A0ThemeIconImageName defaultImage:self.iconImageView.image];

    [self displayController:[[A0LoadingViewController alloc] init]];

    self.dismissButton.hidden = !self.closable;

    [[A0IdentityProviderAuthenticator sharedInstance] setUseWebAsDefault:!self.useWebView];
    
    @weakify(self);
    [[A0APIClient sharedClient] fetchAppInfoWithSuccess:^(A0Application *application) {
        @strongify(self);
        self.application = application;
        [[A0IdentityProviderAuthenticator sharedInstance] configureForApplication:application];
        [self layoutRootControllerForApplication:application];
    } failure:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dismiss:(id)sender {
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

#pragma mark - Container methods

- (void)layoutRootControllerForApplication:(A0Application *)application {
    @weakify(self);
    void(^onAuthSuccessBlock)(A0UserProfile *, A0Token *) =  ^(A0UserProfile *profile, A0Token *token) {
        @strongify(self);
        if (self.onAuthenticationBlock) {
            self.onAuthenticationBlock(profile, token);
        }
    };
    UIViewController<A0AuthenticationUIComponent> *rootController;
    BOOL hasSocial = application.socialStrategies.count > 0;
    BOOL hasAD = application.activeDirectoryStrategy != nil;
    BOOL hasEnterprise = application.enterpriseStrategies.count > 0;
    BOOL hasDB = application.databaseStrategy != nil;

    A0Strategy *database = application.databaseStrategy;
    A0Strategy *ad = application.activeDirectoryStrategy;
    A0Connection *connection = database.connections.firstObject;
    [self.navigationView removeAll];
    if ((hasDB && hasSocial) || (hasSocial && hasEnterprise && !hasAD)) {
        A0FullLoginViewController *controller = [self newFullLoginViewController:onAuthSuccessBlock];
        controller.application = application;
        controller.showResetPassword = [connection.values[@"showForgot"] boolValue];
        controller.showSignUp = [connection.values[@"showSignup"] boolValue];
        controller.domainMatcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:self.application.enterpriseStrategies];
        controller.validator = [[A0DatabaseLoginCredentialValidator alloc] initWithUsesEmail:self.usesEmail];
        rootController = controller;
    }
    if ((hasDB & !hasSocial) || (hasEnterprise && !hasDB && !hasSocial && !hasAD)) {
        A0DatabaseLoginViewController *controller = [self newDatabaseLoginViewController:onAuthSuccessBlock];;
        controller.showResetPassword = [connection.values[@"showForgot"] boolValue];
        controller.showSignUp = [connection.values[@"showSignup"] boolValue];
        controller.domainMatcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:self.application.enterpriseStrategies];
        controller.validator = [[A0DatabaseLoginCredentialValidator alloc] initWithUsesEmail:self.usesEmail];
        rootController = controller;
    }
    if (hasSocial && !hasAD && !hasDB && !hasEnterprise) {
        A0SocialLoginViewController *controller = [self newSocialLoginViewController:onAuthSuccessBlock];
        controller.application = application;
        rootController = controller;
    }
    if (hasSocial && hasAD && !hasDB) {
        A0FullActiveDirectoryViewController *controller = [self newFullADLoginViewController:onAuthSuccessBlock];
        controller.application = application;
        controller.defaultConnection = ad.connections.firstObject;
        controller.domainMatcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:self.application.enterpriseStrategies];
        controller.validator = [[A0DatabaseLoginCredentialValidator alloc] initWithUsesEmail:NO];
        rootController = controller;
    }
    if (hasAD && !hasDB && !hasSocial) {
        A0ActiveDirectoryViewController *controller = [self newADLoginViewController:onAuthSuccessBlock];;
        controller.defaultConnection = ad.connections.firstObject;
        controller.domainMatcher = [[A0SimpleConnectionDomainMatcher alloc] initWithStrategies:self.application.enterpriseStrategies];
        controller.validator = [[A0DatabaseLoginCredentialValidator alloc] initWithUsesEmail:NO];
        rootController = controller;
    }
    rootController.parameters = [self copyAuthenticationParameters];
    [self displayController:rootController];
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
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"SIGN UP") actionBlock:^{
        @strongify(self);
        A0SignUpViewController *controller = [self newSignUpViewControllerWithSuccess:success];
        [self displayController:controller];
    }];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"RESET PASSWORD") actionBlock:^{
        @strongify(self);
        A0ChangePasswordViewController *controller = [self newChangePasswordViewController];
        [self displayController:controller];
    }];
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
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"SIGN UP") actionBlock:^{
        @strongify(self);
        A0SignUpViewController *controller = [self newSignUpViewControllerWithSuccess:success];
        [self displayController:controller];
    }];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"RESET PASSWORD") actionBlock:^{
        @strongify(self);
        A0ChangePasswordViewController *controller = [self newChangePasswordViewController];
        [self displayController:controller];
    }];
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
        [self layoutRootControllerForApplication:self.application];
    }];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"RESET PASSWORD") actionBlock:^{
        @strongify(self);
        A0ChangePasswordViewController *controller = [self newChangePasswordViewController];
        [self displayController:controller];
    }];
    return controller;
}

- (A0SignUpViewController *)newSignUpViewControllerWithSuccess:(void(^)(A0UserProfile *, A0Token *))success {
    A0SignUpViewController *controller = [[A0SignUpViewController alloc] init];
    controller.validator = [[A0SignUpCredentialValidator alloc] initWithUsesEmail:self.usesEmail];
    controller.loginUser = self.loginAfterSignUp;
    controller.parameters = [self copyAuthenticationParameters];
    @weakify(self);
    if (self.signUpDisclaimerView) {
        [controller addDisclaimerSubview:self.signUpDisclaimerView];
    }
    controller.onSignUpBlock = success;
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"CANCEL") actionBlock:^{
        @strongify(self);
        [self layoutRootControllerForApplication:self.application];
    }];
    return controller;
}

- (A0ChangePasswordViewController *)newChangePasswordViewController {
    A0ChangePasswordViewController *controller = [[A0ChangePasswordViewController alloc] init];
    controller.validator = [[A0ChangePasswordCredentialValidator alloc] initWithUsesEmail:self.usesEmail];
    controller.parameters = [self copyAuthenticationParameters];
    @weakify(self);
    void(^block)() = ^{
        @strongify(self);
        [self layoutRootControllerForApplication:self.application];
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
