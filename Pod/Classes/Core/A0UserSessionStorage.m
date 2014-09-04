//  A0UserSessionStorage.m
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

#import "A0UserSessionStorage.h"
#import "A0UserProfile.h"
#import "A0Token.h"

#import <UICKeyChainStore/UICKeyChainStore.h>

#define kAccessTokenKey @"auth0-access-token"
#define kIdTokenKey @"auth0-id-token"
#define kTokenTypeKey @"auth0-token-type"
#define kRefreshTokenKey @"auth0-refresh-token"
#define kUserProfileKey @"auth0-user-profile"
#define kUserProfileIdentitiesKey @"auth0-user-profile-identities"

@interface A0UserSessionStorage ()
@property (strong, nonatomic) UICKeyChainStore *store;
@end

@implementation A0UserSessionStorage

- (instancetype)initWithAccessGroup:(NSString *)accessGroup {
    self = [super init];
    if (self) {
        _store = [[UICKeyChainStore alloc] initWithService:@"Auth0" accessGroup:accessGroup];
    }
    return self;
}

- (id)init {
    self = [super init];
    if (self) {
        _store = [[UICKeyChainStore alloc] initWithService:@"Auth0"];
    }
    return self;
}

#pragma mark - A0SessionStorage

- (void)storeToken:(A0Token *)token andUserProfile:(A0UserProfile *)userProfile {
    [self storeToken:token];
    [self storeUserProfile:userProfile];
}

- (void)storeToken:(A0Token *)token {
    NSAssert(token != nil, @"token should not be nil");
    if (token.accessToken) {
        [self.store setString:token.accessToken forKey:kAccessTokenKey];
    }
    [self.store setString:token.idToken forKey:kIdTokenKey];
    [self.store setString:token.tokenType forKey:kTokenTypeKey];
    if (token.refreshToken) {
        [self.store setString:token.refreshToken forKey:kRefreshTokenKey];
    }
    [self.store synchronize];
}

- (void)storeUserProfile:(A0UserProfile *)userProfile {
    NSAssert(userProfile != nil, @"profile should not be nil");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[NSKeyedArchiver archivedDataWithRootObject:userProfile] forKey:kUserProfileKey];
    [userDefaults synchronize];
    if (userProfile.identities) {
        [self.store setData:[NSKeyedArchiver archivedDataWithRootObject:userProfile.identities] forKey:kUserProfileIdentitiesKey];
        [self.store synchronize];
    }
}

- (void)clearAll {
    [self.store removeAllItems];
    [self.store synchronize];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults removeObjectForKey:kUserProfileKey];
    [userDefaults synchronize];
}

- (A0Token *)currentToken {
    NSString *idToken = [self.store stringForKey:kIdTokenKey];
    A0Token *token;
    if (idToken) {
        token = [[A0Token alloc] initWithAccessToken:[self.store stringForKey:kAccessTokenKey]
                                             idToken:idToken
                                           tokenType:[self.store stringForKey:kTokenTypeKey]
                                        refreshToken:[self.store stringForKey:kRefreshTokenKey]];
    }
    return token;
}

- (A0UserProfile *)currentUserProfile {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [userDefaults objectForKey:kUserProfileKey];
    A0UserProfile *profile;
    if (data) {
        profile = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        NSData *identityData = [self.store dataForKey:kUserProfileIdentitiesKey];
        if (identityData) {
            profile.identities = [NSKeyedUnarchiver unarchiveObjectWithData:identityData];
        }
    }
    return profile;
}
@end
