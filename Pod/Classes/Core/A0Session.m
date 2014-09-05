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
#import "A0UserSessionDataSource.h"

#import <libextobjc/EXTScope.h>

@implementation A0Session

- (instancetype)initWithSessionDataSource:(id<A0SessionDataSource>)sessionDataSource {
    self = [super init];
    if (self) {
        _dataSource = sessionDataSource;
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

- (void)refreshWithSuccess:(A0RefreshBlock)success failure:(A0RefreshFailureBlock)failure {
    Auth0LogVerbose(@"Refreshing Auth0 session...");
    A0Token *token = self.token;
    if (!token) {
        Auth0LogWarn(@"No session information found in session data source %@", self.dataSource);
        if (failure) {
            [self clear];
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
            [self.dataSource storeToken:refreshedToken];
            Auth0LogDebug(@"Session refreshed with token expiring %@", tokenInfo.expiresAt);
            if (success) {
                success(self.profile, refreshedToken);
            }
        } failure:[self sanitizeFailureBlock:failure]];
    } else {
        Auth0LogDebug(@"Session not expired. No need to call API.");
        if (success) {
            success(self.profile, token);
        }
    }
}

- (void)renewWithSuccess:(A0RefreshBlock)success failure:(A0RefreshFailureBlock)failure {
    Auth0LogVerbose(@"Forcing refresh Auth0 session...");
    A0Token *token = self.token;
    if (!token) {
        Auth0LogWarn(@"No session information found in session data source %@", self.dataSource);
        if (failure) {
            [self clear];
            failure([A0Errors noSessionFound]);
        }
        return;
    }

    @weakify(self);
    A0APIClientDelegationSuccess successBlock = ^(A0Token *tokenInfo) {
        @strongify(self);
        A0Token *refreshedToken = [[A0Token alloc] initWithAccessToken:tokenInfo.accessToken idToken:tokenInfo.idToken tokenType:tokenInfo.tokenType refreshToken:token.refreshToken];
        [self.dataSource storeToken:refreshedToken];
        Auth0LogDebug(@"Session refreshed with token expiring %@", tokenInfo.expiresAt);
        if (success) {
            success(self.profile, refreshedToken);
        }
    };

    if (self.isExpired) {
        Auth0LogDebug(@"Session already expired. Requesting new id_token from API using refresh_token...");
        [[A0APIClient sharedClient] delegationWithRefreshToken:token.refreshToken
                                                       options:nil
                                                       success:successBlock
                                                       failure:[self sanitizeFailureBlock:failure]];
    } else {
        Auth0LogDebug(@"Session not expired. Requesting new id_token from API using id_token...");
        [[A0APIClient sharedClient] delegationWithIdToken:token.idToken
                                                  options:nil
                                                  success:successBlock
                                                  failure:[self sanitizeFailureBlock:failure]];
    }
}

- (void)renewUserProfileWithSuccess:(A0RefreshBlock)success failure:(A0RefreshFailureBlock)failure {
    Auth0LogVerbose(@"Renew user profile");
    [[A0APIClient sharedClient] fetchUserProfileWithIdToken:self.token.idToken success:^(A0UserProfile *profile) {
        if (success) {
            success(profile, self.token);
        }
    } failure:[self sanitizeFailureBlock:failure]];
}

- (void)clear {
    Auth0LogVerbose(@"Cleaning Auth0 session...");
    [[A0APIClient sharedClient] logout];
    [self.dataSource clearAll];
}

- (A0Token *)token {
    return self.dataSource.currentToken;
}

- (A0UserProfile *)profile {
    return self.dataSource.currentUserProfile;
}

+ (instancetype)newDefaultSession {
    A0UserSessionDataSource *dataSource = [[A0UserSessionDataSource alloc] init];
    return [[A0Session alloc] initWithSessionDataSource:dataSource];

}

- (A0APIClientError) sanitizeFailureBlock:(A0RefreshFailureBlock)failureBlock {
    @weakify(self);
    A0APIClientError sanitized = ^(NSError *error) {
        @strongify(self);
        Auth0LogError(@"Refresh failed with error %@", error);
        [self clear];
        if (failureBlock) {
            failureBlock(error);
        }
    };
    return sanitized;
}

@end
