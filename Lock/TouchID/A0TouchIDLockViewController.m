//  A0TouchIDAuthenticationViewController.m
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

#import "A0TouchIDLockViewController.h"

#import <SimpleKeychain/A0SimpleKeychain+KeyPair.h>
#import <TouchIDAuth/A0TouchIDAuthentication.h>
#import <SimpleKeychain/A0SimpleKeychain.h>
#import "A0TouchIDRegisterViewController.h"
#import "A0APIClient.h"
#import "A0AuthParameters.h"
#import "A0UserProfile.h"
#import "A0Token.h"
#import "A0UserAPIClient.h"
#import "A0Theme.h"
#import "A0TitleView.h"
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"
#import "UIConstants.h"
#import "A0Alert.h"
#import "Constants.h"

NSString * const A0ThemeTouchIDLockButtonImageNormalName = @"A0ThemeTouchIDLockButtonImageNormalName";
NSString * const A0ThemeTouchIDLockButtonImageHighlightedName = @"A0ThemeTouchIDLockButtonImageHighlightedName";
NSString * const A0ThemeTouchIDLockContainerBackgroundColor = @"A0ThemeTouchIDLockContainerBackgroundColor";

@interface A0TouchIDLockViewController ()

@property (weak, nonatomic) IBOutlet A0TitleView *titleView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *touchIDView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) A0TouchIDAuthentication *authentication;
@property (strong, nonatomic) A0UserAPIClient *userClient;
@property (strong, nonatomic) A0Lock *lock;

- (IBAction)checkTouchID:(id)sender;

@end

@implementation A0TouchIDLockViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)initWithLock:(A0Lock *)lock {
    NSAssert(lock != nil, @"Must have a non-nil Lock instance");
    self = [self initWithNibName:NSStringFromClass(self.class) bundle:[NSBundle bundleForClass:self.class]];;
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
        _authenticationParameters = [A0AuthParameters newDefaultParams];
        _authenticationParameters[A0ParameterConnection] = @"Username-Password-Authentication";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSAssert(self.navigationController != nil, @"Must be inside a UINavigationController");
    self.navigationController.navigationBarHidden = YES;
    A0Theme *theme = [A0Theme sharedInstance];
    UIImage *image = [theme imageForKey:A0ThemeScreenBackgroundImageName];
    if (image) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        [self.view insertSubview:imageView atIndex:0];
    }
    self.view.backgroundColor = [theme colorForKey:A0ThemeScreenBackgroundColor];
    self.closeButton.enabled = self.closable;
    self.closeButton.hidden = !self.closable;
    self.closeButton.tintColor = [theme colorForKey:A0ThemeSecondaryButtonTextColor];
    UIImage *normalImage = [theme imageForKey:A0ThemeTouchIDLockButtonImageNormalName defaultImage:[self.touchIDButton imageForState:UIControlStateNormal]];
    [self.touchIDButton setImage:normalImage forState:UIControlStateNormal];
    UIImage *highlightedImage = [theme imageForKey:A0ThemeTouchIDLockButtonImageHighlightedName defaultImage:[self.touchIDButton imageForState:UIControlStateHighlighted]];
    [self.touchIDButton setImage:highlightedImage forState:UIControlStateHighlighted];
    self.touchIDView.backgroundColor = [theme colorForKey:A0ThemeTouchIDLockContainerBackgroundColor defaultColor:self.touchIDView.backgroundColor];
    self.messageLabel.font = [theme fontForKey:A0ThemeDescriptionFont];
    self.messageLabel.textColor = [theme colorForKey:A0ThemeDescriptionTextColor];
    self.activityIndicator.color = [theme colorForKey:A0ThemeTitleTextColor];

    self.titleView.title = A0LocalizedString(@"Login with TouchID");
    self.titleView.iconImage = [theme imageForKey:A0ThemeIconImageName];

    if (self.defaultDatabaseConnectionName) {
        self.authenticationParameters[A0ParameterConnection] = self.defaultDatabaseConnectionName;
    }

    __weak A0TouchIDLockViewController *weakSelf = self;
    self.authentication = [[A0TouchIDAuthentication alloc] init];
    self.authentication.onError = ^(NSError *error) {
        A0LogError(@"Failed to perform TouchID authentication with error %@", error);
        NSString *message;
        switch (error.code) {
            case A0TouchIDAuthenticationErrorTouchIDFailed:
            case A0TouchIDAuthenticationErrorTouchIDNotAvailable:
                message = error.localizedDescription;
                break;
            default:
                message = A0LocalizedString(@"Couldn't authenticate with TouchID. Please try again later!.");
                break;
        }
        [A0Alert showInController:weakSelf alert:^(A0Alert *alert) {
            alert.title = A0LocalizedString(@"There was an error logging in");
            alert.message = message;
            alert.cancelTitle = A0LocalizedString(@"OK");
        }];
        weakSelf.touchIDView.hidden = NO;
        weakSelf.loadingView.hidden = YES;
    };

    NSString *userId = [[A0SimpleKeychain keychainWithService:@"TouchID"] stringForKey:@"auth0-userid"];
    if (!userId) {
        [self.authentication reset];
        A0LogDebug(@"Cleaning up key pairs of unknown user");
    }

    A0SimpleKeychain *keychain = [A0SimpleKeychain keychainWithService:@"TouchID"];
    self.authentication.registerPublicKey = ^(NSData *pubKey, A0RegisterCompletionBlock completionBlock, A0ErrorBlock errorBlock) {
        A0TouchIDRegisterViewController *controller = [[A0TouchIDRegisterViewController alloc] init];
        controller.onCancelBlock = ^ {
            [weakSelf.authentication reset];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            weakSelf.touchIDView.hidden = NO;
            weakSelf.loadingView.hidden = YES;
        };
        controller.onRegisterBlock = ^(A0UserProfile *profile, A0Token *token) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
            A0LogDebug(@"User %@ registered. Uploading public key...", profile.userId);
            [keychain setString:profile.userId forKey:@"auth0-userid"];
            NSString *deviceName = [weakSelf deviceName];
            weakSelf.userClient = [weakSelf.lock newUserAPIClientWithIdToken:token.idToken];
            [weakSelf.userClient removePublicKeyOfDevice:deviceName user:profile.userId success:^{
                [weakSelf.userClient registerPublicKey:pubKey device:deviceName user:profile.userId success:completionBlock failure:errorBlock];
            } failure:^(NSError *error) {
                A0LogWarn(@"Failed to remove public key. Please check that the user has only one Public key registered.");
                [weakSelf.userClient registerPublicKey:pubKey device:deviceName user:profile.userId success:completionBlock failure:errorBlock];
            }];
        };
        controller.parameters = weakSelf.authenticationParameters;
        controller.lock = weakSelf.lock;
        [weakSelf.navigationController pushViewController:controller animated:YES];
    };
    self.authentication.jwtPayload = ^{
        NSString *userId = [keychain stringForKey:@"auth0-userid"];
        return @{
                 @"iss": userId,
                 };
    };

    self.authentication.authenticate = ^(NSString *jwt, A0ErrorBlock errorBlock) {
        A0LogVerbose(@"Authenticating with signed JWT %@", jwt);
        A0APIClient *client = [weakSelf a0_apiClientFromProvider:weakSelf.lock];
        [client loginWithIdToken:jwt
                      deviceName:[weakSelf deviceName]
                      parameters:weakSelf.authenticationParameters
                         success:weakSelf.onAuthenticationBlock
                         failure:errorBlock];
    };
}

- (void)close:(id)sender {
    A0LogVerbose(@"Dismissing TouchID view controller on user's request.");
    if (self.onUserDismissBlock) {
        self.onUserDismissBlock();
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (A0LockControllerSupportedOrientation)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)checkTouchID:(id)sender {
    self.touchIDView.hidden = YES;
    self.loadingView.hidden = NO;
    [self.authentication start];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [[A0Theme sharedInstance] statusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [[A0Theme sharedInstance] statusBarHidden];
}

#pragma mark - Utility methods

- (NSString *)deviceName {
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSCharacterSet *setToFilter = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    deviceName = [[deviceName componentsSeparatedByCharactersInSet:setToFilter] componentsJoinedByString:@""];
    return deviceName;
}

@end
