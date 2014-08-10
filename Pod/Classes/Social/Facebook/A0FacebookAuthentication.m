//
//  A0FacebookAuthentication.m
//  Pods
//
//  Created by Hernan Zalazar on 7/28/14.
//
//

#import "A0FacebookAuthentication.h"
#import "A0Errors.h"
#import <Facebook-iOS-SDK/FacebookSDK/Facebook.h>

static NSString * const A0FacebookAuthenticationName = @"facebook";

@implementation A0FacebookAuthentication

- (instancetype)init {
    self = [super init];
    if (self) {
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

+ (A0FacebookAuthentication *)newAuthentication {
    return [[A0FacebookAuthentication alloc] init];
}

#pragma mark - A0SocialProviderAuth

- (NSString *)identifier {
    return A0FacebookAuthenticationName;
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)authenticateWithSuccess:(void(^)(A0SocialCredentials *socialCredentials))success failure:(void(^)(NSError *))failure {
    FBSession *active = [FBSession activeSession];
    if (active.state == FBSessionStateOpen || active.state == FBSessionStateOpenTokenExtended) {
        if (success) {
            success([[A0SocialCredentials alloc] initWithAccessToken:active.accessTokenData.accessToken]);
        }
    } else {
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
            if (error) {
                if (failure) {
                    NSError *errorParam = [FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled ? [A0Errors facebookCancelled] : error;
                    failure(errorParam);
                }
            } else {
                switch (status) {
                    case FBSessionStateOpen:
                        if (success) {
                            success([[A0SocialCredentials alloc] initWithAccessToken:session.accessTokenData.accessToken]);
                            [session closeAndClearTokenInformation];
                        }
                        break;
                    case FBSessionStateClosedLoginFailed:
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
