// A0APIClient.m
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

#import "A0APIClient.h"

#import "A0Application.h"
#import "A0Strategy.h"
#import "A0JSONResponseSerializer.h"
#import "A0SocialCredentials.h"
#import "A0UserProfile.h"
#import "A0Token.h"
#import "A0SocialAuthenticator.h"

#import <AFNetworking/AFNetworking.h>
#import <libextobjc/EXTScope.h>

#define kClientIdKey @"AUTH0_CLIENT_ID"
#define kAppBaseURLFormatString @"https://%@.auth0.com/api/"
#define kAppInfoEndpointURLFormatString @"https://s3.amazonaws.com/assets.auth0.com/client/%@.js"

#define kLoginPath @"/oauth/ro"
#define kSignUpPath @"/dbconnections/signup"
#define kUserInfoPath @"/userinfo"
#define kChangePasswordPath @"/dbconnections/change_password"
#define kSocialAuthPath @"/oauth/access_token"

#define kAuthorizationHeaderName @"Authorization"
#define kAuthorizationHeaderValueFormatString @"Bearer %@"

#define kClientIdParamName @"client_id"
#define kUsernameParamName @"username"
#define kPasswordParamName @"password"
#define kGrantTypeParamName @"grant_type"
#define kTenantParamName @"tenant"
#define kRedirectUriParamName @"redirect_uri"
#define kScopeParamName @"scope"
#define kConnectionParamName @"connection"
#define kIdTokenParamName @"id_token"
#define kEmailParamName @"email"
#define kAccessTokenParamName @"access_token"
#define kAccessTokenSecretParamName @"access_token_secret"
#define kSocialUserIdParamName @"user_id"
#define kDeviceNameParamName @"device"

typedef void (^AFFailureBlock)(AFHTTPRequestOperation *, NSError *);

@interface A0APIClient ()

@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) A0Application *application;

@end

@implementation A0APIClient

- (instancetype)initWithClientId:(NSString *)clientId {
    self = [super init];
    if (self) {
        NSAssert(clientId, @"You must supply Auth0 Client Id.");
        _clientId = [clientId copy];
    }
    return self;
}

- (void)configureForApplication:(A0Application *)application {
    Auth0LogDebug(@"Configuring APIClient for application %@", application);
    NSString *URLString = [NSString stringWithFormat:kAppBaseURLFormatString, application.tenant.lowercaseString];
    NSURL *baseURL = [NSURL URLWithString:URLString];
    Auth0LogInfo(@"Base URL of API Endpoint is %@", baseURL);
    self.manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:baseURL];
    self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    self.manager.responseSerializer = [A0JSONResponseSerializer serializer];
    self.application = application;
}

- (void)fetchAppInfoWithSuccess:(A0APIClientFetchAppInfoSuccess)success
                                      failure:(A0APIClientError)failure {
    NSURL *connectionURL = [NSURL URLWithString:[NSString stringWithFormat:kAppInfoEndpointURLFormatString, self.clientId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:connectionURL];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    Auth0LogVerbose(@"Fetching app info from URL %@", connectionURL);
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            Auth0LogDebug(@"Obtained application info JSONP");
            NSError *error;
            A0Application *application = [self parseApplicationFromJSONP:responseObject error:&error];
            Auth0LogDebug(@"Application parsed form JSONP %@", application);
            if (!error) {
                [self configureForApplication:application];
                [[A0SocialAuthenticator sharedInstance] configureForApplication:application];
                success(application);
            } else {
                Auth0LogError(@"Failed to parse JSONP with error %@", error);
                if (failure) {
                    failure(error);
                }
            }
        }
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
    [operation start];
}

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                  success:(A0APIClientAuthenticationSuccess)success
                  failure:(A0APIClientError)failure {
    NSDictionary *params = [self buildBasicParamsWithDictionary:@{
                                                                 kUsernameParamName: username,
                                                                 kPasswordParamName: password,
                                                                 kGrantTypeParamName: @"password",
                                                                 kScopeParamName: [self defaultScope],
                                                                 }];
    Auth0LogVerbose(@"Starting Login with username & password %@", params);
    @weakify(self);
    [self.manager POST:kLoginPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        Auth0LogDebug(@"Obtained JWT & accessToken from Auth0 API");
        [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

- (void)signUpWithUsername:(NSString *)username password:(NSString *)password success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure {
    NSDictionary *params = [self buildBasicParamsWithDictionary:@{
                                                                 kEmailParamName: username,
                                                                 kPasswordParamName: password,
                                                                 kTenantParamName: self.application.tenant,
                                                                 kRedirectUriParamName: self.application.callbackURL.absoluteString,
                                                                 }];
    Auth0LogVerbose(@"Starting Signup with username & password %@", params);
    @weakify(self);
    [self.manager POST:kSignUpPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        Auth0LogDebug(@"Created user successfully %@", responseObject);
        [self loginWithUsername:username password:password success:success failure:failure];
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

- (void)changePassword:(NSString *)newPassword forUsername:(NSString *)username success:(void(^)())success failure:(A0APIClientError)failure {
    NSDictionary *params = [self buildBasicParamsWithDictionary:@{
                                                                  kEmailParamName: username,
                                                                  kPasswordParamName: newPassword,
                                                                  kTenantParamName: self.application.tenant,
                                                                  }];
    Auth0LogVerbose(@"Chaning password with params %@", params);
    [self.manager POST:kChangePasswordPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Auth0LogDebug(@"Changed password for user %@. Response %@", username, responseObject);
        if (success) {
            success();
        }
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

- (void)authenticateWithSocialStrategy:(A0Strategy *)strategy
                     socialCredentials:(A0SocialCredentials *)socialCredentials
                               success:(A0APIClientAuthenticationSuccess)success
                               failure:(A0APIClientError)failure {
    NSDictionary *params = [self buildBasicParamsWithDictionary:@{
                                                                  kScopeParamName: [self defaultScope],
                                                                  }
                                                       strategy:strategy
                                                    credentials:socialCredentials];
    Auth0LogVerbose(@"Authenticating with social strategy %@", params);
    @weakify(self);
    [self.manager POST:kSocialAuthPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        Auth0LogDebug(@"Authenticated successfuly with social strategy %@", strategy);
        [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
    } failure:[A0APIClient sanitizeFailureBlock:failure]];

}

- (void)logout {
    [[A0SocialAuthenticator sharedInstance] clearSessions];
}

+ (instancetype)sharedClient {
    static A0APIClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *clientId = info[kClientIdKey];
        client = [[A0APIClient alloc] initWithClientId:clientId];
    });
    return client;
}

#pragma mark - Internal API calls

- (void)fetchUserInfoWithTokenInfo:(NSDictionary *)tokenInfo success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure {
    NSString *token = tokenInfo[@"access_token"];
    NSURL *connectionURL = [NSURL URLWithString:kUserInfoPath relativeToURL:self.manager.baseURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:connectionURL];
    NSString *authorizationHeader = [NSString stringWithFormat:kAuthorizationHeaderValueFormatString, token];
    [request setValue:authorizationHeader forHTTPHeaderField:kAuthorizationHeaderName];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    Auth0LogVerbose(@"Fetching User Profile from token info %@", tokenInfo);
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Auth0LogDebug(@"Obtained user profile %@", responseObject);
        if (success) {
            A0UserProfile *profile = [[A0UserProfile alloc] initWithDictionary:responseObject];
            A0Token *token = [[A0Token alloc] initWithDictionary:tokenInfo];
            success(profile, token);
        }
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
    [operation start];
}

#pragma mark - Utility methods
+ (AFFailureBlock) sanitizeFailureBlock:(A0APIClientError)failureBlock {
    AFFailureBlock sanitized = ^(AFHTTPRequestOperation *operation, NSError *error) {
        Auth0LogError(@"Request %@ %@ failed with error %@", operation.request.HTTPMethod, operation.request.URL, error);
        if (failureBlock) {
            failureBlock(error);
        }
    };
    return sanitized;
}
- (NSDictionary *)buildBasicParamsWithDictionary:(NSDictionary *)dictionary {
    return [self buildBasicParamsWithDictionary:dictionary strategy:self.application.databaseStrategy credentials:nil];
}

- (NSDictionary *)buildBasicParamsWithDictionary:(NSDictionary *)dictionary
                                        strategy:(A0Strategy *)strategy
                                     credentials:(A0SocialCredentials *)credentials {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
    params[kClientIdParamName] = self.clientId;
    params[kConnectionParamName] = strategy.connection[@"name"];
    if (credentials) {
        params[kAccessTokenParamName] = credentials.accessToken;
    }
    if (credentials.extraInfo[A0StrategySocialTokenSecretParameter]) {
        params[kAccessTokenSecretParamName] = credentials.extraInfo[A0StrategySocialTokenSecretParameter];
    }
    if (credentials.extraInfo[A0StrategySocialUserIdParameter]) {
        params[kSocialUserIdParamName] = credentials.extraInfo[A0StrategySocialUserIdParameter];
    }
    if (self.offlineAccess) {
        params[kDeviceNameParamName] = [[UIDevice currentDevice] name];
    }
    return params;
}

- (A0Application *)parseApplicationFromJSONP:(NSData *)jsonpData error:(NSError **)error {
    NSMutableString *json = [[NSMutableString alloc] initWithData:jsonpData encoding:NSUTF8StringEncoding];
    NSRange range = [json rangeOfString:@"Auth0.setClient("];
    if (range.location != NSNotFound) {
        [json deleteCharactersInRange:range];
    }
    range = [json rangeOfString:@");"];
    if (range.location != NSNotFound) {
        [json deleteCharactersInRange:range];
    }
    NSDictionary *auth0AppInfo = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:error];
    A0Application *application = [[A0Application alloc] initWithJSONDictionary:auth0AppInfo];
    return application;
}

- (NSString *)defaultScope {
    NSString *scope = @"openid";
    if (self.offlineAccess) {
        scope = [scope stringByAppendingString:@" offline_access"];
    }
    return scope;
}
@end
