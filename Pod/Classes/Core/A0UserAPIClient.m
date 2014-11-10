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
#import <libextobjc/EXTScope.h>
#import "A0AuthParameters.h"
#import "A0JSONResponseSerializer.h"
#import "A0UserProfile.h"

#define kAuthorizationHeaderName @"Authorization"
#define kAuthorizationHeaderValueFormatString @"Bearer %@"

#define kClientIdKey @"Auth0ClientId"
#define kTenantKey @"Auth0Tenant"
#define kAppBaseURLFormatString @"https://%@.auth0.com/api/"

#define kUserInfoPath @"/userinfo"
#define kUserPublicKeyPath @"/api/users/%@/publickey"

typedef void (^AFFailureBlock)(AFHTTPRequestOperation *, NSError *);

@interface A0UserAPIClient ()
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *tenant;
@end

@implementation A0UserAPIClient

- (instancetype)initWithClientId:(NSString *)clientId andTenant:(NSString *)tenant {
    self = [super init];
    if (self) {
        NSAssert(clientId, @"You must supply your Auth0 app's Client Id.");
        NSAssert(tenant, @"You must supply your Auth0 app's Tenant.");
        _clientId = [clientId copy];
        _tenant = [tenant copy];
        NSString *URLString = [NSString stringWithFormat:kAppBaseURLFormatString, tenant];
        NSURL *baseURL = [NSURL URLWithString:URLString];
        Auth0LogInfo(@"Base URL of API Endpoint is %@", baseURL);
        _manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [A0JSONResponseSerializer serializer];
    }
    return self;
}

- (instancetype)initWithClientId:(NSString *)clientId tenant:(NSString *)tenant accessToken:(NSString *)accessToken {
    self = [self initWithClientId:clientId andTenant:tenant];
    if (self) {
        NSAssert(accessToken.length > 0, @"Must supply a valid accessToken");
        NSString *authorizationHeader = [NSString stringWithFormat:kAuthorizationHeaderValueFormatString, accessToken];
        [_manager.requestSerializer setValue:authorizationHeader forHTTPHeaderField:kAuthorizationHeaderName];
    }
    return self;
}

- (instancetype)initWithClientId:(NSString *)clientId tenant:(NSString *)tenant idToken:(NSString *)idToken {
    self = [self initWithClientId:clientId andTenant:tenant];
    if (self) {
        NSAssert(idToken.length > 0, @"Must supply a valid idToken");
        NSString *authorizationHeader = [NSString stringWithFormat:kAuthorizationHeaderValueFormatString, idToken];
        [_manager.requestSerializer setValue:authorizationHeader forHTTPHeaderField:kAuthorizationHeaderName];
    }
    return self;
}

+ (A0UserAPIClient *)clientWithAccessToken:(NSString *)accessToken {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *clientId = info[kClientIdKey];
    NSString *tenant = info[kTenantKey];
    A0UserAPIClient *client = [[A0UserAPIClient alloc] initWithClientId:clientId tenant:tenant accessToken:accessToken];
    return client;
}

+ (A0UserAPIClient *)clientWithIdToken:(NSString *)idToken {
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *clientId = info[kClientIdKey];
    NSString *tenant = info[kTenantKey];
    A0UserAPIClient *client = [[A0UserAPIClient alloc] initWithClientId:clientId tenant:tenant idToken:idToken];
    return client;
}

#pragma mark - User Profile

- (void)fetchUserProfileSuccess:(A0UserAPIClientUserProfileSuccess)success
                        failure:(A0UserAPIClientError)failure {
    Auth0LogVerbose(@"Fetching User Profile");
    [self.manager GET:kUserInfoPath parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Auth0LogDebug(@"Obtained user profile %@", responseObject);
        if (success) {
            A0UserProfile *profile = [[A0UserProfile alloc] initWithDictionary:responseObject];
            success(profile);
        }
    } failure:[A0UserAPIClient sanitizeFailureBlock:failure]];
}

#pragma mark - Public Key

- (void)registerPublicKey:(NSData *)pubKey
                   device:(NSString *)deviceName
                     user:(NSString *)userId
                  success:(void (^)())success
                  failure:(A0UserAPIClientError)failure {
    NSString *pubKeyPath = [[NSString stringWithFormat:kUserPublicKeyPath, userId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = @{
                                 @"public_key": [[NSString alloc] initWithData:pubKey encoding:NSUTF8StringEncoding],
                                 A0ParameterDevice: deviceName,
                                 };
    Auth0LogVerbose(@"Registering public key for user %@ and device %@", userId, deviceName);
    [self.manager POST:pubKeyPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Auth0LogDebug(@"Registered public key %@", responseObject);
        if (success) {
            success();
        }
    } failure:[A0UserAPIClient sanitizeFailureBlock:failure]];
}

- (void)removePublicKeyOfDevice:(NSString *)deviceName
                           user:(NSString *)userId
                        success:(void (^)())success
                        failure:(A0UserAPIClientError)failure {
    NSString *pubKeyPath = [[NSString stringWithFormat:kUserPublicKeyPath, userId] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters = @{
                                 A0ParameterDevice: deviceName,
                                 };
    Auth0LogVerbose(@"Removing public key for user %@ and device %@", userId, deviceName);
    [self.manager DELETE:pubKeyPath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Auth0LogDebug(@"Removed public key with response %@", responseObject);
        if (success) {
            success();
        }
    } failure:[A0UserAPIClient sanitizeFailureBlock:failure]];
}

#pragma mark - Utility methods

+ (AFFailureBlock) sanitizeFailureBlock:(A0UserAPIClientError)failureBlock {
    AFFailureBlock sanitized = ^(AFHTTPRequestOperation *operation, NSError *error) {
        Auth0LogError(@"Request %@ %@ failed with error %@", operation.request.HTTPMethod, operation.request.URL, error);
        if (failureBlock) {
            failureBlock(error);
        }
    };
    return sanitized;
}

@end
