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
#import "A0KeyUploader.h"
#import <Masonry/Masonry.h>

@interface A0TouchIDLockViewController ()

@property (weak, nonatomic) IBOutlet A0TitleView *titleView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIView *touchIDView;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *touchIDButton;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) A0TouchIDAuthentication *authentication;
@property (strong, nonatomic) A0KeyUploader *uploader;
@property (strong, nonatomic) A0Lock *lock;
@property (readonly, nonatomic) A0SimpleKeychain *keychain;

- (IBAction)checkTouchID:(id)sender;

@end

@implementation A0TouchIDLockViewController

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)init {
    return [self initWithLock:[A0Lock sharedLock]];
}

- (instancetype)initWithLock:(A0Lock *)lock {
    NSAssert(lock != nil, @"Must have a non-nil Lock instance");
    self = [super init];
    if (self) {
        _lock = lock;
        _authenticationParameters = [A0AuthParameters newDefaultParams];
        _cleanOnError = NO;
        _cleanOnStart = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    A0TitleView *titleView = [[A0TitleView alloc] init];
    UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    UIView *loadingView = [[UIView alloc] initWithFrame:CGRectZero];
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    UIView *touchIDView = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    UIButton *touchIDButton = [UIButton buttonWithType:UIButtonTypeCustom];

    [loadingView addSubview:activityIndicator];
    [activityIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(loadingView);
    }];

    [touchIDView addSubview:touchIDButton];
    [touchIDView addSubview:messageLabel];
    [touchIDButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(touchIDView);
        make.centerY.equalTo(touchIDView).offset(20);
        make.height.and.width.equalTo(@155);
    }];
    [messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(touchIDView);
        make.bottom.equalTo(touchIDView.mas_bottom).offset(-3);
    }];

    [self.view addSubview:titleView];
    [self.view addSubview:closeButton];
    [self.view addSubview:loadingView];
    [self.view addSubview:touchIDView];
    [titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(55);
        make.height.equalTo(@110);
    }];
    [closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.right.equalTo(self.view);
        make.height.and.width.equalTo(@40);
    }];
    [touchIDView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(50);
        make.right.equalTo(self.view).offset(-50);
        make.top.equalTo(titleView.mas_bottom).offset(40);
        make.bottom.equalTo(self.view).offset(-60);
    }];
    [loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.and.width.equalTo(@300);
        make.center.equalTo(touchIDView);
    }];

    self.titleView = titleView;
    self.closeButton = closeButton;
    self.loadingView = loadingView;
    self.activityIndicator = activityIndicator;
    self.touchIDView = touchIDView;
    self.touchIDButton = touchIDButton;
    self.messageLabel = messageLabel;

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
    [self.closeButton setImage:[theme imageForKey:A0ThemeCloseButtonImageName] forState:UIControlStateNormal];
    self.closeButton.tintColor = [theme colorForKey:A0ThemeSecondaryButtonTextColor];
    [self.closeButton addTarget:self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    UIImage *normalImage = [theme imageForKey:A0ThemeTouchIDLockButtonImageNormalName];
    [self.touchIDButton setImage:normalImage forState:UIControlStateNormal];
    UIImage *highlightedImage = [theme imageForKey:A0ThemeTouchIDLockButtonImageHighlightedName];
    [self.touchIDButton setImage:highlightedImage forState:UIControlStateHighlighted];
    [self.touchIDButton addTarget:self action:@selector(checkTouchID:) forControlEvents:UIControlEventTouchUpInside];
    self.touchIDView.backgroundColor = [theme colorForKey:A0ThemeTouchIDLockContainerBackgroundColor defaultColor:self.touchIDView.backgroundColor];
    self.messageLabel.font = [theme fontForKey:A0ThemeDescriptionFont];
    self.messageLabel.textColor = [theme colorForKey:A0ThemeDescriptionTextColor];
    self.messageLabel.text = A0LocalizedString(@"Tap above to sign in or create an account");
    self.activityIndicator.color = [theme colorForKey:A0ThemeTitleTextColor];
    self.loadingView.hidden = YES;
    self.activityIndicator.hidesWhenStopped = YES;

    self.titleView.title = A0LocalizedString(@"Login with TouchID");
    self.titleView.iconImage = [theme imageForKey:A0ThemeIconImageName];

    if (!self.authenticationParameters) {
        self.authenticationParameters = [A0AuthParameters newDefaultParams];
    }
    self.authenticationParameters[A0ParameterConnection] = [self databaseConnectionName];

    A0SimpleKeychain *keychain = self.keychain;
    __weak A0TouchIDLockViewController *weakSelf = self;

    self.authentication = [[A0TouchIDAuthentication alloc] init];
    self.authentication.onError = ^(NSError *error) {
        if (weakSelf.cleanOnError) {
            [weakSelf cleanKeys];
        }
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

    NSString *userId = [keychain stringForKey:@"auth0-userid"];
    if (!userId) {
        A0LogDebug(@"Cleaning up key pairs of unknown user");
        [self.authentication reset];
    }

    self.authentication.registerPublicKey = ^(NSData *pubKey, A0RegisterCompletionBlock completionBlock, A0ErrorBlock errorBlock) {
        A0TouchIDRegisterViewController *controller = [[A0TouchIDRegisterViewController alloc] init];
        controller.onCancelBlock = ^ {
            [weakSelf.authentication reset];
            [weakSelf.navigationController popViewControllerAnimated:YES];
            weakSelf.touchIDView.hidden = NO;
            weakSelf.loadingView.hidden = YES;
        };
        controller.onRegisterBlock = ^(A0KeyUploader *uploader, NSString *identifier) {
            [weakSelf.navigationController popViewControllerAnimated:YES];
            A0LogDebug(@"User %@ registered. Uploading public key...", identifier);
            [uploader uploadKey:pubKey forUser:identifier callback:^(NSError * _Nullable error, NSString * _Nullable keyIdentifier) {
                if (error) {
                    [weakSelf.authentication reset];
                    errorBlock(error);
                    return;
                }
                [keychain setString:identifier forKey:@"auth0-userid"];
                [keychain setString:keyIdentifier forKey:@"auth0-key-id"];
                completionBlock();
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
    A0LockControllerSupportedOrientation orientations = UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        orientations = UIInterfaceOrientationMaskAll;
    }
    return orientations;
}

- (void)checkTouchID:(id)sender {
    self.touchIDView.hidden = YES;
    self.loadingView.hidden = NO;
    [self.activityIndicator startAnimating];
    if (self.cleanOnStart) {
        [self cleanKeys];
    }
    [self.authentication start];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return [[A0Theme sharedInstance] statusBarStyle];
}

- (BOOL)prefersStatusBarHidden {
    return [[A0Theme sharedInstance] statusBarHidden];
}

- (NSString *)databaseConnectionName {
    return self.defaultDatabaseConnectionName ? self.defaultDatabaseConnectionName : @"Username-Password-Authentication";
}

- (A0SimpleKeychain *)keychain {
    return [A0SimpleKeychain keychainWithService:@"TouchID"];
}

#pragma mark - Utility methods

- (void)cleanKeys {
    A0LogWarn(@"Cleaning stored public keys");
    [self.authentication reset];
    [self.keychain deleteEntryForKey:@"auth0-userid"];
    [self.keychain deleteEntryForKey:@"auth0-key-id"];
}

- (NSString *)deviceName {
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSCharacterSet *setToFilter = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    deviceName = [[deviceName componentsSeparatedByCharactersInSet:setToFilter] componentsJoinedByString:@""];
    return deviceName;
}

@end
