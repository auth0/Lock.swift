// A0UserAPIClient.m
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

#import "A0UserAPIClient.h"
#import <AFNetworking/AFNetworking.h>
#import "A0AuthParameters.h"
#import "A0JSONResponseSerializer.h"
#import "A0UserProfile.h"
#import "A0APIv1Router.h"
#import "A0Lock.h"
#import "Constants.h"

#define kAuthorizationHeaderName @"Authorization"
#define kAuthorizationHeaderValueFormatString @"Bearer %@"

typedef void (^AFFailureBlock)(NSURLSessionDataTask *, NSError *);

@interface A0UserAPIClient ()
@property (strong, nonatomic) id<A0APIRouter> router;
@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *tenant;
@end

@implementation A0UserAPIClient

- (instancetype)initWithRouter:(id<A0APIRouter>)router {
    NSAssert(router, @"Must supply a non nil router");
    self = [super init];
    if (self) {
        _router = router;
        A0LogInfo(@"Base URL of API Endpoint is %@", router.endpointURL);
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:router.endpointURL];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [A0JSONResponseSerializer serializer];
    }
    return self;
}

- (instancetype)initWithRouter:(id)router accessToken:(NSString *)accessToken {
    self = [self initWithRouter:router];
    if (self) {
        NSAssert(accessToken.length > 0, @"Must supply a valid accessToken");
        NSString *authorizationHeader = [NSString stringWithFormat:kAuthorizationHeaderValueFormatString, accessToken];
        [_manager.requestSerializer setValue:authorizationHeader forHTTPHeaderField:kAuthorizationHeaderName];
    }
    return self;
}

- (instancetype)initWithRouter:(id)router idToken:(NSString *)idToken {
    self = [self initWithRouter:router];
    if (self) {
        NSAssert(idToken.length > 0, @"Must supply a valid idToken");
        NSString *authorizationHeader = [NSString stringWithFormat:kAuthorizationHeaderValueFormatString, idToken];
        [_manager.requestSerializer setValue:authorizationHeader forHTTPHeaderField:kAuthorizationHeaderName];
    }
    return self;
}

#pragma mark - User Profile

- (void)fetchUserProfileSuccess:(A0UserAPIClientUserProfileSuccess)success
                        failure:(A0UserAPIClientError)failure {
    A0LogVerbose(@"Fetching User Profile");
    [self.manager GET:[self.router userInfoPath] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        A0LogDebug(@"Obtained user profile %@", responseObject);
        if (success) {
            A0UserProfile *profile = [[A0UserProfile alloc] initWithDictionary:responseObject];
            success(profile);
        }
    } failure:[A0UserAPIClient sanitizeFailureBlock:failure]];
}

#pragma mark - Utility methods

+ (AFFailureBlock) sanitizeFailureBlock:(A0UserAPIClientError)failureBlock {
    AFFailureBlock sanitized = ^(NSURLSessionDataTask *task, NSError *error) {
        A0LogError(@"Request %@ failed with error %@", task.originalRequest.URL, error);
        if (failureBlock) {
            failureBlock(error);
        }
    };
    return sanitized;
}

@end

#pragma mark - Deprecated

@implementation A0UserAPIClient (Deprecated)

- (instancetype)initWithClientId:(NSString *)clientId tenant:(NSString *)tenant accessToken:(NSString *)accessToken {
    NSAssert(clientId, @"You must supply your Auth0 app's Client Id.");
    NSAssert(tenant, @"You must supply your Auth0 app's Tenant.");
    A0Lock *lock = [A0Lock newLockWithClientId:clientId domain:[NSString stringWithFormat:@"https://%@.auth0.com", tenant]];
    A0APIv1Router *router = [[A0APIv1Router alloc] initWithClientId:lock.clientId domainURL:lock.domainURL configurationURL:lock.configurationURL];
    return [self initWithRouter:router accessToken:accessToken];
}

- (instancetype)initWithClientId:(NSString *)clientId tenant:(NSString *)tenant idToken:(NSString *)idToken {
    NSAssert(clientId, @"You must supply your Auth0 app's Client Id.");
    NSAssert(tenant, @"You must supply your Auth0 app's Tenant.");
    A0Lock *lock = [A0Lock newLockWithClientId:clientId domain:[NSString stringWithFormat:@"https://%@.auth0.com", tenant]];
    A0APIv1Router *router = [[A0APIv1Router alloc] initWithClientId:lock.clientId domainURL:lock.domainURL configurationURL:lock.configurationURL];
    return [self initWithRouter:router idToken:idToken];
}

+ (A0UserAPIClient *)clientWithAccessToken:(NSString *)accessToken {
    A0Lock *lock = [A0Lock new];
    A0APIv1Router *router = [[A0APIv1Router alloc] initWithClientId:lock.clientId domainURL:lock.domainURL configurationURL:lock.configurationURL];
    A0UserAPIClient *client = [[A0UserAPIClient alloc] initWithRouter:router accessToken:accessToken];
    return client;
}

+ (A0UserAPIClient *)clientWithIdToken:(NSString *)idToken {
    A0Lock *lock = [A0Lock new];
    A0APIv1Router *router = [[A0APIv1Router alloc] initWithClientId:lock.clientId domainURL:lock.domainURL configurationURL:lock.configurationURL];
    A0UserAPIClient *client = [[A0UserAPIClient alloc] initWithRouter:router idToken:idToken];
    return client;
}

#pragma mark - Public Key

- (void)registerPublicKey:(NSData *)pubKey
                   device:(NSString *)deviceName
                     user:(NSString *)userId
                  success:(void (^)())success
                  failure:(A0UserAPIClientError)failure {
    NSDictionary *parameters = @{
                                 @"public_key": [[NSString alloc] initWithData:pubKey encoding:NSUTF8StringEncoding],
                                 A0ParameterDevice: deviceName,
                                 };
    A0LogVerbose(@"Registering public key for user %@ and device %@", userId, deviceName);
    [self.manager POST:[self.router userPublicKeyPathForUser:userId] parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        A0LogDebug(@"Registered public key %@", responseObject);
        if (success) {
            success();
        }
    } failure:[A0UserAPIClient sanitizeFailureBlock:failure]];
}

- (void)removePublicKeyOfDevice:(NSString *)deviceName
                           user:(NSString *)userId
                        success:(void (^)())success
                        failure:(A0UserAPIClientError)failure {
    NSDictionary *parameters = @{
                                 A0ParameterDevice: deviceName,
                                 };
    A0LogVerbose(@"Removing public key for user %@ and device %@", userId, deviceName);
    [self.manager DELETE:[self.router userPublicKeyPathForUser:userId] parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        A0LogDebug(@"Removed public key with response %@", responseObject);
        if (success) {
            success();
        }
    } failure:[A0UserAPIClient sanitizeFailureBlock:failure]];
}

@end

