//  A0AuthenticationViewController.m
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

#import "A0AuthenticationViewController.h"
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

#import <CoreText/CoreText.h>
#import <libextobjc/EXTScope.h>

@interface A0AuthenticationViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *iconContainerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (strong, nonatomic) UIViewController<A0KeyboardEnabledView> *current;
@property (strong, nonatomic) A0KeyboardHandler *keyboardHandler;
@property (strong, nonatomic) A0Application *application;

- (IBAction)dismiss:(id)sender;

@end

@implementation A0AuthenticationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        _usesEmail = YES;
        _loginAfterSignUp = YES;
        _authenticationParameters = [A0AuthParameters newDefaultParams];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0Theme *theme = [A0Theme sharedInstance];
    self.view.backgroundColor = [theme colorForKey:A0ThemeScreenBackgroundColor defaultColor:self.view.backgroundColor];
    self.titleLabel.font = [theme fontForKey:A0ThemeTitleFont defaultFont:self.titleLabel.font];
    self.titleLabel.textColor = [theme colorForKey:A0ThemeTitleTextColor defaultColor:self.titleLabel.textColor];
    self.iconContainerView.backgroundColor = [theme colorForKey:A0ThemeIconBackgroundColor defaultColor:self.iconContainerView.backgroundColor];
    self.iconImageView.image = [theme imageForKey:A0ThemeIconImageName defaultImage:self.iconImageView.image];

    self.keyboardHandler = [[A0KeyboardHandler alloc] init];
    self.current = [self layoutController:[[A0LoadingViewController alloc] init] inContainer:self.containerView];

    self.dismissButton.hidden = !self.closable;

    [[A0IdentityProviderAuthenticator sharedInstance] setUseWebAsDefault:!self.useWebView];
    
    @weakify(self);
    [[A0APIClient sharedClient] fetchAppInfoWithSuccess:^(A0Application *application) {
        @strongify(self);
        self.application = application;
        [self layoutRootControllerForApplication:application];
    } failure:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.keyboardHandler start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.keyboardHandler stop];
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
    [self.current hideKeyboard];
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
    A0Strategy *strategy = [application databaseStrategy];
    NSDictionary *connection = strategy.connections.firstObject;
    if ([application hasDatabaseConnection] && [application hasSocialOrEnterpriseStrategies]) {
        A0FullLoginViewController *controller = [self newFullLoginViewController:onAuthSuccessBlock];
        controller.application = application;
        controller.showResetPassword = [connection[@"showForgot"] boolValue];
        controller.showSignUp = [connection[@"showSignup"] boolValue];
        controller.parameters = self.authenticationParameters;
        self.current = [self layoutController:controller inContainer:self.containerView];
    } else if ([application hasDatabaseConnection]) {
        A0DatabaseLoginViewController *controller = [self newDatabaseLoginViewController:onAuthSuccessBlock];;
        controller.showResetPassword = [connection[@"showForgot"] boolValue];
        controller.showSignUp = [connection[@"showSignup"] boolValue];
        controller.parameters = self.authenticationParameters;
        self.current = [self layoutController:controller inContainer:self.containerView];
    } else if ([application hasSocialOrEnterpriseStrategies]) {
        A0SocialLoginViewController *controller = [self newSocialLoginViewController:onAuthSuccessBlock];
        controller.application = application;
        self.current = [self layoutController:controller inContainer:self.containerView];
    }
}

- (UIViewController<A0KeyboardEnabledView> *)layoutController:(UIViewController<A0KeyboardEnabledView> *)controller inContainer:(UIView *)containerView {
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self.keyboardHandler handleForView:controller inView:self.view];
    [self.current willMoveToParentViewController:nil];
    [self addChildViewController:controller];
    [self layoutAuthView:controller.view centeredInContainerView:containerView];
    [self animateFromViewController:self.current toViewController:controller];
    return controller;
}

- (void)layoutAuthView:(UIView *)authView centeredInContainerView:(UIView *)containerView {
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:authView];
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                              attribute:NSLayoutAttributeCenterX
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:authView
                                                              attribute:NSLayoutAttributeCenterX
                                                             multiplier:1.0f
                                                               constant:0.0f]];
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:authView
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0f
                                                               constant:0.0f]];
    NSDictionary *views = NSDictionaryOfVariableBindings(authView);
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[authView]|" options:0 metrics:nil views:views]];
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[authView]|" options:0 metrics:nil views:views]];
}

- (void)animateFromViewController:(UIViewController *)from toViewController:(UIViewController *)to {
    to.view.alpha = 0.0f;
    from.view.alpha = 0.0f;
    [UIView animateWithDuration:0.3f animations:^{
        to.view.alpha = 1.0f;
        self.titleLabel.text = to.title;
    } completion:^(BOOL finished) {
        [from.view removeFromSuperview];
        [from removeFromParentViewController];
        [to didMoveToParentViewController:self];
    }];
}

- (A0SocialLoginViewController *)newSocialLoginViewController:(void(^)(A0UserProfile *, A0Token *))success {
    A0SocialLoginViewController *controller = [[A0SocialLoginViewController alloc] init];
    controller.onLoginBlock = success;
    return controller;
}

- (A0FullLoginViewController *)newFullLoginViewController:(void(^)(A0UserProfile *, A0Token *))success {
    @weakify(self);
    A0FullLoginViewController *controller = [[A0FullLoginViewController alloc] init];
    controller.onLoginBlock = success;
    controller.onShowSignUp = ^ {
        @strongify(self);
        A0SignUpViewController *controller = [self newSignUpViewControllerWithSuccess:success];
        self.current = [self layoutController:controller inContainer:self.containerView];
    };
    controller.onShowForgotPassword = ^ {
        @strongify(self);
        A0ChangePasswordViewController *controller = [self newChangePasswordViewController];
        self.current = [self layoutController:controller inContainer:self.containerView];
    };
    controller.validator = [[A0DatabaseLoginCredentialValidator alloc] initWithUsesEmail:self.usesEmail];
    return controller;
}

- (A0DatabaseLoginViewController *)newDatabaseLoginViewController:(void(^)(A0UserProfile *, A0Token *))success {
    @weakify(self);
    A0DatabaseLoginViewController *controller = [[A0DatabaseLoginViewController alloc] init];
    controller.onLoginBlock = success;
    controller.onShowSignUp = ^ {
        @strongify(self);
        A0SignUpViewController *controller = [self newSignUpViewControllerWithSuccess:success];
        self.current = [self layoutController:controller inContainer:self.containerView];
    };
    controller.onShowForgotPassword = ^ {
        @strongify(self);
        A0ChangePasswordViewController *controller = [self newChangePasswordViewController];
        self.current = [self layoutController:controller inContainer:self.containerView];
    };
    controller.validator = [[A0DatabaseLoginCredentialValidator alloc] initWithUsesEmail:self.usesEmail];
    return controller;
}

- (A0SignUpViewController *)newSignUpViewControllerWithSuccess:(void(^)(A0UserProfile *, A0Token *))success {
    A0SignUpViewController *controller = [[A0SignUpViewController alloc] init];
    controller.validator = [[A0SignUpCredentialValidator alloc] initWithUsesEmail:self.usesEmail];
    controller.loginUser = self.loginAfterSignUp;
    controller.parameters = self.authenticationParameters;
    @weakify(self);
    if (self.signUpDisclaimerView) {
        [controller addDisclaimerSubview:self.signUpDisclaimerView];
    }
    controller.onCancelBlock = ^{
        @strongify(self);
        [self layoutRootControllerForApplication:self.application];
    };
    controller.onSignUpBlock = success;
    return controller;
}

- (A0ChangePasswordViewController *)newChangePasswordViewController {
    A0ChangePasswordViewController *controller = [[A0ChangePasswordViewController alloc] init];
    controller.validator = [[A0ChangePasswordCredentialValidator alloc] initWithUsesEmail:self.usesEmail];
    controller.parameters = self.authenticationParameters;
    @weakify(self);
    void(^block)() = ^{
        @strongify(self);
        [self layoutRootControllerForApplication:self.application];
    };
    controller.onCancelBlock = block;
    controller.onChangePasswordBlock = block;
    return controller;
}

@end
