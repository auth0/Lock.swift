// A0TouchIDRegisterViewController.m
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

#import "A0TouchIDRegisterViewController.h"
#import "A0Theme.h"
#import "A0CredentialFieldView.h"
#import "A0ProgressButton.h"
#import "A0SignUpCredentialValidator.h"
#import "A0KeyboardHandler.h"
#import "A0TouchIDSignUpViewController.h"
#import "A0DatabaseLoginViewController.h"
#import "A0DatabaseLoginCredentialValidator.h"

#import <ObjectiveSugar/ObjectiveSugar.h>
#import <libextobjc/EXTScope.h>
#import "A0ChangePasswordViewController.h"
#import "A0ChangePasswordCredentialValidator.h"
#import "A0AuthParameters.h"

@interface A0TouchIDRegisterViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (strong, nonatomic) A0KeyboardHandler *keyboardHandler;

@end

@implementation A0TouchIDRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keyboardHandler = [[A0KeyboardHandler alloc] init];
    [self addAuthController:[self buildSignUp] margin:0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.keyboardHandler start];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.keyboardHandler stop];
}

- (void)layoutAuthView:(UIView *)authView centeredInContainerView:(UIView *)containerView margin:(NSUInteger)margin {
    containerView.translatesAutoresizingMaskIntoConstraints = NO;
    [containerView addSubview:authView];
    [containerView addConstraint:[NSLayoutConstraint constraintWithItem:containerView
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:authView
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0f
                                                               constant:0.0f]];
    NSDictionary *views = NSDictionaryOfVariableBindings(authView);
    [containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[authView]-(margin)-|" options:0 metrics:@{@"margin": @(margin)} views:views]];
}

#pragma mark - Child UIViewController

- (void)addAuthController:(UIViewController<A0KeyboardEnabledView> *)controller margin:(NSUInteger)margin {
    UIViewController *from = self.childViewControllers.firstObject;
    [from willMoveToParentViewController:nil];
    [controller willMoveToParentViewController:self];
    [self addChildViewController:controller];
    [from.view removeFromSuperview];
    [self.containerView addSubview:controller.view];
    controller.view.translatesAutoresizingMaskIntoConstraints = NO;
    [self layoutAuthView:controller.view centeredInContainerView:self.containerView margin:margin];
    [self.keyboardHandler handleForView:controller inView:self.view];
    [controller didMoveToParentViewController:self];
    [from removeFromParentViewController];
    self.titleLabel.text = controller.title;
}

- (UIViewController<A0KeyboardEnabledView> *)buildSignUp {
    @weakify(self);
    A0TouchIDSignUpViewController *signUpController = [[A0TouchIDSignUpViewController alloc] init];
    signUpController.onCancelBlock = self.onCancelBlock;
    signUpController.onRegisterBlock = self.onRegisterBlock;
    signUpController.authenticationParameters = self.authenticationParameters;
    signUpController.onLoginBlock = ^{
        @strongify(self);
        [self addAuthController:[self buildLogin] margin:20];
    };
    return signUpController;
}

- (UIViewController<A0KeyboardEnabledView> *)buildLogin {
    @weakify(self);
    A0DatabaseLoginViewController *controller = [[A0DatabaseLoginViewController alloc] init];
    controller.showSignUp = YES;
    controller.showResetPassword = YES;
    controller.validator = [[A0DatabaseLoginCredentialValidator alloc] initWithUsesEmail:YES];
    controller.parameters = self.authenticationParameters;
    controller.onShowSignUp = ^{
        @strongify(self);
        [self addAuthController:[self buildSignUp] margin:0];
    };
    controller.onShowForgotPassword = ^{
        @strongify(self);
        [self addAuthController:[self buildChangePassword] margin:20];
    };
    controller.onLoginBlock = self.onRegisterBlock;
    return controller;
}

- (UIViewController<A0KeyboardEnabledView> *)buildChangePassword {
    @weakify(self);
    A0ChangePasswordViewController *controller = [[A0ChangePasswordViewController alloc] init];
    controller.parameters = self.authenticationParameters;
    controller.onCancelBlock = ^{
        @strongify(self);
        [self addAuthController:[self buildLogin] margin:20];
    };
    controller.onChangePasswordBlock = ^{
        @strongify(self);
        [self addAuthController:[self buildLogin] margin:20];
    };
    controller.validator = [[A0ChangePasswordCredentialValidator alloc] init];
    return controller;
}
@end
