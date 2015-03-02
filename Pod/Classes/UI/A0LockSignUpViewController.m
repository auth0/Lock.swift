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
#import "A0SmallSocialAuthenticationCollectionView.h"
#import "A0LoadingViewController.h"
#import "A0IdentityProviderAuthenticator.h"
#import "A0APIClient.h"
#import "A0LockConfiguration.h"
#import <libextobjc/EXTScope.h>
#import "A0Errors.h"
#import "A0SignUpViewController.h"
#import "A0SignUpCredentialValidator.h"
#import "A0UIUtilities.h"

@interface A0LockSignUpViewController () <A0SmallSocialAuthenticationCollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *iconContainerView;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet A0SmallSocialAuthenticationCollectionView *serviceCollectionView;

@property (strong, nonatomic) A0LockConfiguration *configuration;

@end

@implementation A0LockSignUpViewController

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
    self.iconContainerView.backgroundColor = [theme colorForKey:A0ThemeIconBackgroundColor];
    self.iconImageView.image = [theme imageForKey:A0ThemeIconImageName];
    self.dismissButton.tintColor = [theme colorForKey:A0ThemeCloseButtonTintColor];

    [[A0IdentityProviderAuthenticator sharedInstance] setUseWebAsDefault:!self.useWebView];
    [self displayController:[[A0LoadingViewController alloc] init]];
    [self loadApplicationInfo];

}


- (BOOL)shouldAutorotate {
    return NO;
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

#pragma mark - A0SmallSocialAuthenticationCollectionViewDelegate

- (void)socialAuthenticationCollectionView:(A0SmallSocialAuthenticationCollectionView *)collectionView
            didAuthenticateUserWithProfile:(A0UserProfile *)profile
                                     token:(A0Token *)token {
    if (self.onAuthenticationBlock) {
        self.onAuthenticationBlock(profile, token);
    }
}

- (void)socialAuthenticationCollectionView:(A0SmallSocialAuthenticationCollectionView *)collectionView
                          didFailWithError:(NSError *)error {
    A0ShowAlertErrorView(error.localizedDescription, error.localizedFailureReason);
}

- (void)authenticationDidStartForSocialCollectionView:(A0SmallSocialAuthenticationCollectionView *)collectionView {
    [self setInProgress:YES];
}

- (void)authenticationDidEndForSocialCollectionView:(A0SmallSocialAuthenticationCollectionView *)collectionView {
    [self setInProgress:NO];
}

- (void)socialAuthenticationCollectionView:(A0SmallSocialAuthenticationCollectionView *)collectionView
       presentAuthenticationViewController:(UIViewController *)controller {
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
    @weakify(self);
    [[A0APIClient sharedClient] fetchAppInfoWithSuccess:^(A0Application *application) {
        @strongify(self);
        Auth0LogDebug(@"Obtained application info. Starting to build Lock UI for Sign Up...");
        [[A0IdentityProviderAuthenticator sharedInstance] configureForApplication:application];
        A0LockConfiguration *configuration = [[A0LockConfiguration alloc] initWithApplication:application filter:self.connections];
        [self.serviceCollectionView showSocialServicesForConfiguration:configuration];
        A0SignUpViewController *controller = [[A0SignUpViewController alloc] init];
        controller.validator = [[A0SignUpCredentialValidator alloc] initWithUsesEmail:YES];
        controller.loginUser = self.loginAfterSignUp;
        controller.parameters = [self copyAuthenticationParameters];
        controller.onSignUpBlock = self.onAuthenticationBlock;
        [self displayController:controller];
    } failure:^(NSError *error) {
        Auth0LogError(@"Failed to fetch App info %@", error);
        NSString *title = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedDescription : A0LocalizedString(@"Failed to display Sign Up");
        NSString *message = [A0Errors isAuth0Error:error withCode:A0ErrorCodeNotConnectedToInternet] ? error.localizedFailureReason : A0LocalizedString(@"Couldnt get Sign Up screen configuration. Please try again.");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:A0LocalizedString(@"Retry"), nil];
        [alert show];
    }];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    Auth0LogVerbose(@"Retrying fetch Auth0 app info...");
    [self loadApplicationInfo];
}

- (A0AuthParameters *)copyAuthenticationParameters {
    A0AuthParameters *parameters = self.authenticationParameters ?: [A0AuthParameters newDefaultParams];
    return parameters.copy;
}

@end