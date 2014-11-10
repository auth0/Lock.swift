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
#import "A0IdentityProviderCredentials.h"
#import "A0UserProfile.h"
#import "A0Token.h"
#import "A0AuthParameters.h"
#import "A0Errors.h"
#import "A0Connection.h"

#import <AFNetworking/AFNetworking.h>
#import <libextobjc/EXTScope.h>
#import "A0UserAPIClient.h"

#define kClientIdKey @"Auth0ClientId"
#define kTenantKey @"Auth0Tenant"
#define kAppBaseURLFormatString @"https://%@.auth0.com/api/"
#define kAppInfoEndpointURLFormatString @"https://s3.amazonaws.com/assets.auth0.com/client/%@.js"

#define kLoginPath @"/oauth/ro"
#define kSignUpPath @"/dbconnections/signup"
#define kTokenInfoPath @"/tokeninfo"
#define kChangePasswordPath @"/dbconnections/change_password"
#define kSocialAuthPath @"/oauth/access_token"
#define kDelegationAuthPath @"/delegation"
#define kUnlinkAccountPath @"/unlink"

#define kClientIdParamName @"client_id"
#define kUsernameParamName @"username"
#define kPasswordParamName @"password"
#define kGrantTypeParamName @"grant_type"
#define kTenantParamName @"tenant"
#define kConnectionParamName @"connection"
#define kIdTokenParamName @"id_token"
#define kEmailParamName @"email"
#define kAccessTokenParamName @"access_token"
#define kAccessTokenSecretParamName @"access_token_secret"
#define kSocialUserIdParamName @"user_id"
#define kRefreshTokenParamName @"refresh_token"

typedef void (^AFFailureBlock)(AFHTTPRequestOperation *, NSError *);

@interface A0APIClient ()

@property (strong, nonatomic) NSString *clientId;
@property (strong, nonatomic) NSString *tenant;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) A0Application *application;
@property (strong, nonatomic) A0UserAPIClient *userClient;

@end

@implementation A0APIClient

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

- (void)logout {
    self.userClient = nil;
}

+ (instancetype)sharedClient {
    static A0APIClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
        NSString *clientId = info[kClientIdKey];
        NSString *tenant = info[kTenantKey];
        client = [[A0APIClient alloc] initWithClientId:clientId andTenant:tenant];
    });
    return client;
}

#pragma mark - Client configuration

- (void)configureForApplication:(A0Application *)application {
    Auth0LogDebug(@"Configuring APIClient for application %@", application);
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

#pragma mark - Database Authentication

- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
               parameters:(A0AuthParameters *)parameters
                  success:(A0APIClientAuthenticationSuccess)success
                  failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:@{
                                                                                kUsernameParamName: username,
                                                                                kPasswordParamName: password,
                                                                                kGrantTypeParamName: @"password",
                                                                                kClientIdParamName: self.clientId,
                                                                                }];
    [self addDatabaseConnectionNameToParams:defaultParameters];
    [defaultParameters addValuesFromParameters:parameters];
    Auth0LogVerbose(@"Starting Login with username & password %@", defaultParameters);
    if ([self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
        @weakify(self);
        NSDictionary *payload = [defaultParameters asAPIPayload];
        [self.manager POST:kLoginPath parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
            @strongify(self);
            Auth0LogDebug(@"Obtained JWT & accessToken from Auth0 API");
            [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
        } failure:[A0APIClient sanitizeFailureBlock:failure]];
    }
}

- (void)signUpWithUsername:(NSString *)username
                  password:(NSString *)password
            loginOnSuccess:(BOOL)loginOnSuccess
                parameters:(A0AuthParameters *)parameters
                   success:(A0APIClientAuthenticationSuccess)success
                   failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:@{
                                                                                kEmailParamName: username,
                                                                                kPasswordParamName: password,
                                                                                kTenantParamName: self.tenant,
                                                                                kClientIdParamName: self.clientId,
                                                                                }];
    [self addDatabaseConnectionNameToParams:defaultParameters];
    [defaultParameters addValuesFromParameters:parameters];
    Auth0LogVerbose(@"Starting Signup with username & password %@", defaultParameters);
    if ([self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
        NSDictionary *payload = [defaultParameters asAPIPayload];
        @weakify(self);
        [self.manager POST:kSignUpPath parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
            @strongify(self);
            Auth0LogDebug(@"Created user successfully %@", responseObject);
            if (loginOnSuccess) {
                [self loginWithUsername:username password:password parameters:parameters success:success failure:failure];
            } else {
                if (success) {
                    success(nil, nil);
                }
            }
        } failure:[A0APIClient sanitizeFailureBlock:failure]];
    }
}

- (void)changePassword:(NSString *)newPassword forUsername:(NSString *)username parameters:(A0AuthParameters *)parameters success:(void(^)())success failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:@{
                                                                                kEmailParamName: username,
                                                                                kPasswordParamName: newPassword,
                                                                                kTenantParamName: self.tenant,
                                                                                kClientIdParamName: self.clientId,
                                                                                }];
    [self addDatabaseConnectionNameToParams:defaultParameters];
    [defaultParameters addValuesFromParameters:parameters];
    Auth0LogVerbose(@"Chaning password with params %@", defaultParameters);
    if ([self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
        NSDictionary *payload = [defaultParameters asAPIPayload];
        [self.manager POST:kChangePasswordPath parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
            Auth0LogDebug(@"Changed password for user %@. Response %@", username, responseObject);
            if (success) {
                success();
            }
        } failure:[A0APIClient sanitizeFailureBlock:failure]];
    }
}

- (void)loginWithIdToken:(NSString *)idToken deviceName:(NSString *)deviceName parameters:(A0AuthParameters *)parameters success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:@{
                                                                                kIdTokenParamName: idToken,
                                                                                kGrantTypeParamName: @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                                kClientIdParamName: self.clientId,
                                                                                }];
    [self addDatabaseConnectionNameToParams:defaultParameters];
    [defaultParameters addValuesFromParameters:parameters];
    defaultParameters.device = deviceName;
    Auth0LogVerbose(@"Starting Login with JWT %@", defaultParameters);
    if ([self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
        @weakify(self);
        NSDictionary *payload = [defaultParameters asAPIPayload];
        [self.manager POST:kLoginPath parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
            @strongify(self);
            Auth0LogDebug(@"Obtained JWT & accessToken from Auth0 API");
            [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
        } failure:[A0APIClient sanitizeFailureBlock:failure]];
    }
}

#pragma mark - Social Authentication

- (void)authenticateWithSocialConnectionName:(NSString *)connectionName
                                 credentials:(A0IdentityProviderCredentials *)credentials
                                  parameters:(A0AuthParameters *)parameters
                                     success:(A0APIClientAuthenticationSuccess)success
                                     failure:(A0APIClientError)failure {
    NSDictionary *params = @{
                             kClientIdParamName: self.clientId,
                             kConnectionParamName: connectionName,
                             };
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:params];
    if (credentials.extraInfo[A0StrategySocialTokenSecretParameter]) {
        [defaultParameters setValue:credentials.extraInfo[A0StrategySocialTokenSecretParameter] forKey:kAccessTokenSecretParamName];
    }
    if (credentials.extraInfo[A0StrategySocialUserIdParameter]) {
        [defaultParameters setValue:credentials.extraInfo[A0StrategySocialUserIdParameter] forKey:kSocialUserIdParamName];
    }
    [defaultParameters addValuesFromParameters:parameters];
    if (defaultParameters.accessToken) {
        [defaultParameters setValue:defaultParameters.accessToken forKey:A0ParameterMainAccessToken];
    }
    defaultParameters.accessToken = credentials.accessToken;

    NSDictionary *payload = [defaultParameters asAPIPayload];
    Auth0LogVerbose(@"Authenticating with social strategy %@ and payload %@", connectionName, payload);
    @weakify(self);
    [self.manager POST:kSocialAuthPath parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        @strongify(self);
        Auth0LogDebug(@"Authenticated successfuly with social connection %@", connectionName);
        [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
    } failure:[A0APIClient sanitizeFailureBlock:failure]];

}

#pragma mark - Delegation Authentication

- (void)fetchNewIdTokenWithIdToken:(NSString *)idToken
                        parameters:(A0AuthParameters *)parameters
                           success:(A0APIClientNewIdTokenSuccess)success
                           failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParamters = [A0AuthParameters newWithDictionary:@{
                                                                               kClientIdParamName: self.clientId,
                                                                               kGrantTypeParamName: @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                               kIdTokenParamName: idToken,
                                                                               }];
    [defaultParamters addValuesFromParameters:parameters];
    [self fetchDelegationTokenWithParameters:defaultParamters success:^(NSDictionary *tokenInfo) {
        if (success) {
            success([[A0Token alloc] initWithDictionary:tokenInfo]);
        }
    } failure:failure];
}

- (void)fetchNewIdTokenWithRefreshToken:(NSString *)refreshToken
                             parameters:(A0AuthParameters *)parameters
                                success:(A0APIClientNewIdTokenSuccess)success
                                failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParamters = [A0AuthParameters newWithDictionary:@{
                                                                               kClientIdParamName: self.clientId,
                                                                               kGrantTypeParamName: @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                               kRefreshTokenParamName: refreshToken,
                                                                               }];
    [defaultParamters addValuesFromParameters:parameters];
    [self fetchDelegationTokenWithParameters:defaultParamters success:^(NSDictionary *tokenInfo) {
        if (success) {
            success([[A0Token alloc] initWithDictionary:tokenInfo]);
        }
    } failure:failure];
}

- (void)fetchDelegationTokenWithParameters:(A0AuthParameters *)parameters
                                   success:(A0APIClientNewDelegationTokenSuccess)success
                                   failure:(A0APIClientError)failure {
    NSAssert(parameters != nil, @"Delegated Authentication parameters must be non-nil!");
    A0AuthParameters *defaultParamters = [A0AuthParameters newWithDictionary:@{
                                                                               kClientIdParamName: self.clientId,
                                                                               kGrantTypeParamName: @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                               }];
    [defaultParamters addValuesFromParameters:parameters];
    NSDictionary *payload = [defaultParamters asAPIPayload];
    Auth0LogVerbose(@"Calling delegate authentication with params %@", parameters);
    [self.manager POST:kDelegationAuthPath parameters:payload success:^(AFHTTPRequestOperation *operation, id responseObject) {
        Auth0LogDebug(@"Delegation successful params %@", parameters);
        if (success) {
            success(responseObject);
        }
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

#pragma mark - User Profile

- (void)fetchUserProfileWithIdToken:(NSString *)idToken
                            success:(A0APIClientUserProfileSuccess)success
                            failure:(A0APIClientError)failure {
    Auth0LogVerbose(@"Fetching User Profile from id token %@", idToken);
    [self.manager POST:kTokenInfoPath parameters:@{
                                                  kIdTokenParamName: idToken,
                                                  }
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   Auth0LogDebug(@"Obtained user profile %@", responseObject);
                   if (success) {
                       A0UserProfile *profile = [[A0UserProfile alloc] initWithDictionary:responseObject];
                       success(profile);
                   }
               } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

#pragma mark - Account Linking

- (void)unlinkAccountWithUserId:(NSString *)userId
                    accessToken:(NSString *)accessToken
                        success:(void (^)())success
                        failure:(A0APIClientError)failure {
    A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{
                                                                         kClientIdParamName: self.clientId,
                                                                         kAccessTokenParamName: accessToken,
                                                                         kSocialUserIdParamName: userId,
                                                                         }];
    Auth0LogVerbose(@"Unlinking account with id %@", userId);
    [self.manager POST:kUnlinkAccountPath
            parameters:[parameters asAPIPayload]
               success:^(AFHTTPRequestOperation *operation, id responseObject) {
                   if (success) {
                       success();
                   }
                   Auth0LogDebug(@"Account with id %@ unlinked successfully", userId);
               }
               failure:[A0APIClient sanitizeFailureBlock:failure]];
}

#pragma mark - Internal API calls

- (void)fetchUserInfoWithTokenInfo:(NSDictionary *)tokenInfo success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure {
    A0Token *token = [[A0Token alloc] initWithDictionary:tokenInfo];
    [self fetchUserProfileWithIdToken:token.idToken success:^(A0UserProfile *profile) {
        if (success) {
            success(profile, token);
        }
    } failure:failure];
}

#pragma mark - Utility methods

- (void)addDatabaseConnectionNameToParams:(A0AuthParameters *)parameters {
    A0Connection *connection = self.application.databaseStrategy.connections.firstObject;
    if (connection.name) {
        [parameters setValue:connection.name forKey:kConnectionParamName];
    }
}

- (BOOL)checkForDatabaseConnectionIn:(A0AuthParameters *)parameters failure:(A0APIClientError)failure {
    BOOL hasConnectionName = [parameters valueForKey:kConnectionParamName] != nil;
    if (!hasConnectionName) {
        Auth0LogError(@"Parameters for DB auth MUST have a connection name!");
        if (failure) {
            failure([A0Errors noConnectionNameFound]);
        }
    }
    return hasConnectionName;
}

+ (AFFailureBlock) sanitizeFailureBlock:(A0APIClientError)failureBlock {
    AFFailureBlock sanitized = ^(AFHTTPRequestOperation *operation, NSError *error) {
        Auth0LogError(@"Request %@ %@ failed with error %@", operation.request.HTTPMethod, operation.request.URL, error);
        if (failureBlock) {
            failureBlock(error);
        }
    };
    return sanitized;
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

@end

@implementation A0APIClient (Deprecated)

- (void)delegationWithRefreshToken:(NSString *)refreshToken
                        parameters:(A0AuthParameters *)parameters
                           success:(A0APIClientDelegationSuccess)success
                           failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParamters = [A0AuthParameters newWithDictionary:@{
                                                                               kClientIdParamName: self.clientId,
                                                                               kGrantTypeParamName: @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                               kRefreshTokenParamName: refreshToken,
                                                                               }];
    [defaultParamters addValuesFromParameters:parameters];
    [self fetchDelegationTokenWithParameters:defaultParamters success:^(NSDictionary *tokenInfo) {
        if (success) {
            success([[A0Token alloc] initWithDictionary:tokenInfo]);
        }
    } failure:failure];
}

- (void)delegationWithIdToken:(NSString *)idToken parameters:(A0AuthParameters *)parameters success:(A0APIClientDelegationSuccess)success failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParamters = [A0AuthParameters newWithDictionary:@{
                                                                               kClientIdParamName: self.clientId,
                                                                               kGrantTypeParamName: @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                               kIdTokenParamName: idToken,
                                                                               }];
    [defaultParamters addValuesFromParameters:parameters];
    [self fetchDelegationTokenWithParameters:defaultParamters success:^(NSDictionary *tokenInfo) {
        if (success) {
            success([[A0Token alloc] initWithDictionary:tokenInfo]);
        }
    } failure:failure];
}

- (void)fetchUserProfileWithAccessToken:(NSString *)accessToken
                                success:(A0APIClientUserProfileSuccess)success
                                failure:(A0APIClientError)failure {
    A0UserAPIClient *client = [A0UserAPIClient clientWithAccessToken:accessToken];
    [client fetchUserProfileSuccess:success failure:failure];
    self.userClient = client;
}

@end
