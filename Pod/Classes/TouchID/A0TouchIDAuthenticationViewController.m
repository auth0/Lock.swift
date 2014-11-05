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

#import "A0TouchIDAuthenticationViewController.h"

#import <SimpleKeychain/A0SimpleKeychain+KeyPair.h>
#import <TouchIDAuth/A0TouchIDAuthentication.h>
#import <libextobjc/EXTScope.h>
#import <SimpleKeychain/A0SimpleKeychain.h>
#import "A0TouchIDRegisterViewController.h"
#import "A0APIClient.h"
#import "A0AuthParameters.h"
#import "A0UserProfile.h"
#import "A0Token.h"

@interface A0TouchIDAuthenticationViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeButton;

@property (strong, nonatomic) A0TouchIDAuthentication *authentication;

@end

@implementation A0TouchIDAuthenticationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        _authenticationParameters = [A0AuthParameters newDefaultParams];
        [_authenticationParameters setValue:@"Username-Password-Authentication" forKey:@"connection"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    @weakify(self);

    self.navigationController.navigationBarHidden = YES;
    self.closeButton.enabled = self.closable;
    self.closeButton.hidden = !self.closable;

    self.authentication = [[A0TouchIDAuthentication alloc] init];
    self.authentication.onError = ^(NSError *error) {
        Auth0LogError(@"Failed to perform TouchID authentication with error %@", error);
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:A0LocalizedString(@"There was an error logging in")
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:A0LocalizedString(@"OK")
                                              otherButtonTitles:nil];
        [alert show];
    };

    NSString *userId = [[A0SimpleKeychain keychainWithService:@"TouchID"] stringForKey:@"auth0-userid"];
    if (!userId) {
        [self.authentication reset];
        Auth0LogDebug(@"Cleaning up key pairs of unknown user");
    }

    A0SimpleKeychain *keychain = [A0SimpleKeychain keychainWithService:@"TouchID"];
    self.authentication.registerPublicKey = ^(NSData *pubKey, A0RegisterCompletionBlock completionBlock, A0ErrorBlock errorBlock) {
        @strongify(self);
        A0TouchIDRegisterViewController *controller = [[A0TouchIDRegisterViewController alloc] init];
        controller.onCancelBlock = ^ {
            @strongify(self);
            [self.authentication reset];
        };
        controller.onRegisterBlock = ^(NSString *email, NSString *password) {
            @strongify(self);
            Auth0LogDebug(@"Registering user with email %@ for TouchID", email);
            A0APIClient *client = [A0APIClient sharedClient];
            [client signUpWithUsername:email
                              password:password
                        loginOnSuccess:YES
                            parameters:self.authenticationParameters
                               success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                                   @strongify(self);
                                   Auth0LogDebug(@"User %@ registered. Uploading public key...", profile.userId);
                                   [keychain setString:profile.userId forKey:@"auth0-userid"];
                                   NSString *deviceName = [self deviceName];
                                   [client registerPublicKey:pubKey
                                                      device:deviceName
                                                     forUser:profile.userId
                                                     idToken:tokenInfo.idToken
                                                     success:completionBlock
                                                     failure:errorBlock];
                               } failure:errorBlock];
        };
        controller.authenticationParameters = self.authenticationParameters;
        [self.navigationController pushViewController:controller animated:YES];
    };
    self.authentication.jwtPayload = ^{
        NSString *userId = [keychain stringForKey:@"auth0-userid"];
        return @{
                 @"iss": userId,
                 };
    };

    self.authentication.authenticate = ^(NSString *jwt, A0ErrorBlock errorBlock) {
        @strongify(self);
        Auth0LogVerbose(@"Authenticating with signed JWT %@", jwt);
        A0APIClient *client = [A0APIClient sharedClient];
        [client loginWithIdToken:jwt
                      deviceName:[self deviceName]
                      parameters:self.authenticationParameters
                         success:self.onAuthenticationBlock
                         failure:errorBlock];
    };
}

- (void)close:(id)sender {
    Auth0LogVerbose(@"Dismissing TouchID view controller on user's request.");
    if (self.onUserDismissBlock) {
        self.onUserDismissBlock();
    }
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)checkTouchID:(id)sender {
    [self.authentication start];
}

#pragma mark - Utility methods

- (NSString *)deviceName {
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSCharacterSet *setToFilter = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    deviceName = [[deviceName componentsSeparatedByCharactersInSet:setToFilter] componentsJoinedByString:@""];
    return deviceName;
}

@end
