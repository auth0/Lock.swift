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
#import "A0KeyboardHandler.h"
#import "A0TouchIDSignUpViewController.h"
#import "A0DatabaseLoginViewController.h"

#import "A0ChangePasswordViewController.h"
#import "A0AuthParameters.h"
#import "A0NavigationView.h"
#import "A0TitleView.h"
#import "Constants.h"

@interface A0TouchIDRegisterViewController ()
@end

@implementation A0TouchIDRegisterViewController

- (instancetype)init {
    return [self initWithNibName:NSStringFromClass(A0TouchIDRegisterViewController.class) bundle:[NSBundle bundleForClass:A0TouchIDRegisterViewController.class]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self displayController:[self buildSignUp]];
    A0Theme *theme = [A0Theme sharedInstance];
    UIImage *image = [theme imageForKey:A0ThemeScreenBackgroundImageName];
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self.view insertSubview:imageView atIndex:0];
    }
    self.view.backgroundColor = [theme colorForKey:A0ThemeScreenBackgroundColor];
    self.titleView.iconImage = [theme imageForKey:A0ThemeIconImageName];
}

- (UIViewController<A0KeyboardEnabledView> *)buildSignUp {
    __weak A0TouchIDRegisterViewController *weakSelf = self;
    A0TouchIDSignUpViewController *signUpController = [[A0TouchIDSignUpViewController alloc] init];
    signUpController.onRegisterBlock = self.onRegisterBlock;
    signUpController.parameters = self.parameters;
    signUpController.lock = self.lock;
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"CANCEL") actionBlock:self.onCancelBlock];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"ALREADY HAVE AN ACCOUNT?") actionBlock:^{
        A0DatabaseLoginViewController *controller = [weakSelf buildLogin];
        controller.defaultUsername = signUpController.emailField.textField.text;
        [weakSelf displayController:controller];
    }];
    return signUpController;
}

- (A0DatabaseLoginViewController *)buildLogin {
    __weak A0TouchIDRegisterViewController *weakSelf = self;
    A0DatabaseLoginViewController *controller = [[A0DatabaseLoginViewController alloc] init];
    controller.parameters = self.parameters;
    controller.onLoginBlock = self.onRegisterBlock;
    controller.lock = self.lock;
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"CANCEL") actionBlock:^{
        [weakSelf displayController:[weakSelf buildSignUp]];
    }];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"RESET PASSWORD") actionBlock:^{
        A0ChangePasswordViewController *resetController = [weakSelf buildChangePassword];
        resetController.defaultEmail = controller.userField.textField.text;
        [weakSelf displayController:resetController];
    }];
    return controller;
}

- (A0ChangePasswordViewController *)buildChangePassword {
    __weak A0TouchIDRegisterViewController *weakSelf = self;
    A0ChangePasswordViewController *controller = [[A0ChangePasswordViewController alloc] init];
    controller.parameters = self.parameters;
    controller.lock = self.lock;
    controller.onChangePasswordBlock = ^{
        [weakSelf displayController:[weakSelf buildLogin]];
    };
    [self.navigationView removeAll];
    [self.navigationView addButtonWithLocalizedTitle:A0LocalizedString(@"CANCEL") actionBlock:^{
        A0DatabaseLoginViewController *loginController = [weakSelf buildLogin];
        loginController.defaultUsername = controller.userField.textField.text;
        [weakSelf displayController:loginController];
    }];
    return controller;
}
@end
