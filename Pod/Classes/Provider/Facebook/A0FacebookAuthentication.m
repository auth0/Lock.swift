// A0FacebookAuthentication.m
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

#import "A0FacebookAuthentication.h"
#import "A0Errors.h"
#import "A0Strategy.h"

#import <Facebook-iOS-SDK/FacebookSDK/Facebook.h>

@interface A0FacebookAuthentication ()
@property (strong, nonatomic) NSArray *permissions;
@end

@implementation A0FacebookAuthentication

- (instancetype)initWithPermissions:(NSArray *)permissions {
    self = [super init];
    if (self) {
        if (permissions) {
            NSMutableSet *perms = [[NSMutableSet alloc] initWithArray:permissions];
            [perms addObject:@"public_profile"];
            self.permissions = [perms allObjects];
        } else {
            self.permissions = @[@"public_profile"];
        }
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationActiveNotification:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationActiveNotification:(NSNotification *)notification {
    [FBAppCall handleDidBecomeActive];
}

+ (A0FacebookAuthentication *)newAuthenticationWithPermissions:(NSArray *)permissions {
    return [[A0FacebookAuthentication alloc] initWithPermissions:permissions];
}

+ (A0FacebookAuthentication *)newAuthenticationWithDefaultPermissions {
    return [self newAuthenticationWithPermissions:nil];
}

#pragma mark - A0SocialProviderAuth

- (NSString *)identifier {
    return A0FacebookAuthenticationName;
}

- (void)clearSessions {
    [[FBSession activeSession] closeAndClearTokenInformation];
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    Auth0LogVerbose(@"Received url %@ from source application %@", url, sourceApplication);
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)authenticateWithSuccess:(void(^)(A0IdentityProviderCredentials *socialCredentials))success failure:(void(^)(NSError *))failure {
    Auth0LogVerbose(@"Starting Facebook authentication...");
    FBSession *active = [FBSession activeSession];
    if (active.state == FBSessionStateOpen || active.state == FBSessionStateOpenTokenExtended) {
        Auth0LogDebug(@"Found FB Active Session");
        if (success) {
            success([[A0IdentityProviderCredentials alloc] initWithAccessToken:active.accessTokenData.accessToken]);
        }
    } else {
        [FBSession openActiveSessionWithReadPermissions:self.permissions allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                if (failure) {
                    Auth0LogError(@"Failed to open FB Session with error %@", error);
                    NSError *errorParam = [FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled ? [A0Errors facebookCancelled] : error;
                    failure(errorParam);
                }
            } else {
                switch (status) {
                    case FBSessionStateOpen:
                        Auth0LogDebug(@"Successfully opened FB Session");
                        if (success) {
                            success([[A0IdentityProviderCredentials alloc] initWithAccessToken:session.accessTokenData.accessToken]);
                        }
                        break;
                    case FBSessionStateClosedLoginFailed:
                        Auth0LogError(@"User cancelled FB Login");
                        if (failure) {
                            failure([A0Errors facebookCancelled]);
                        }
                    default:
                        break;
                }
            }
        }];
    }
}

@end
