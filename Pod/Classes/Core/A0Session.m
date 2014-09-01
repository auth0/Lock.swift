//  A0Session.m
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

#import "A0Session.h"
#import "A0Token.h"
#import "A0Errors.h"
#import "A0APIClient.h"

#import <libextobjc/EXTScope.h>

@implementation A0Session

- (instancetype)initWithSessionStorage:(id<A0SessionStorage>)sessionStorage {
    self = [super init];
    if (self) {
        _storage = sessionStorage;
    }
    return self;
}

- (BOOL)isExpired {
    A0Token *token = self.token;
    BOOL expired = YES;
    if (token) {
        expired = [[NSDate date] compare:token.expiresAt] != NSOrderedAscending;
    }
    return expired;
}

- (void)refreshWithSuccess:(void (^)(A0Token *))success failure:(void (^)(NSError *))failure {
    Auth0LogVerbose(@"Refreshing Auth0 session...");
    A0Token *token = self.token;
    if (!token) {
        Auth0LogWarn(@"No session information found in session storage %@", self.storage);
        if (failure) {
            failure([A0Errors noSessionFound]);
        }
        return;
    }

    if (self.isExpired) {
        Auth0LogDebug(@"Session already expired. Requesting new id_token from API...");
        @weakify(self);
        [[A0APIClient sharedClient] delegationWithRefreshToken:token.refreshToken options:nil success:^(A0Token *tokenInfo) {
            @strongify(self);
            A0Token *refreshedToken = [[A0Token alloc] initWithAccessToken:tokenInfo.accessToken idToken:tokenInfo.idToken tokenType:tokenInfo.tokenType refreshToken:token.refreshToken];
            [self.storage storeToken:refreshedToken];
            Auth0LogDebug(@"Session refreshed with token expiring %@", tokenInfo.expiresAt);
        } failure:failure];
    } else {
        Auth0LogDebug(@"Session not expired. No need to call API.");
        if (success) {
            success(token);
        }
    }
}

- (void)clear {
    Auth0LogVerbose(@"Cleaning Auth0 session...");
    [[A0APIClient sharedClient] logout];
    [self.storage clearAll];
}

- (A0Token *)token {
    return self.storage.currentToken;
}

- (A0UserProfile *)profile {
    return self.storage.currentUserProfile;
}

@end
