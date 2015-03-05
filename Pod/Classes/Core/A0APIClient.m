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
#import "A0APIv1Router.h"

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

typedef void (^AFFailureBlock)(NSURLSessionDataTask *, NSError *);

@interface A0APIClient ()

@property (strong, nonatomic) AFHTTPSessionManager *manager;
@property (strong, nonatomic) A0Application *application;
@property (strong, nonatomic) A0UserAPIClient *userClient;

@end

@implementation A0APIClient

AUTH0_DYNAMIC_LOGGER_METHODS

- (instancetype)initWithClientId:(NSString *)clientId andTenant:(NSString *)tenant {
    NSAssert(clientId, @"You must supply your Auth0 app's Client Id.");
    NSAssert(tenant, @"You must supply your Auth0 app's Tenant.");
    A0APIv1Router *router = [[A0APIv1Router alloc] init];
    [router configureForTenant:tenant clientId:clientId];
    return [self initWithAPIRouter:router];
}

- (instancetype)initWithAPIRouter:(id<A0APIRouter>)router {
    NSAssert(router, @"You must supply a valid API Router");
    self = [super init];
    if (self) {
        _router = router;
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[router endpointURL]];
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
        A0APIv1Router *router = [[A0APIv1Router alloc] init];
        [router configureWithBundleInfo:info];
        client = [[A0APIClient alloc] initWithAPIRouter:router];
    });
    return client;
}

#pragma mark - Client configuration

- (NSString *)clientId {
    return self.router.clientId;
}

- (NSString *)tenant {
    return self.router.tenant;
}

- (NSURL *)baseURL {
    return self.manager.baseURL;
}

- (void)configureForApplication:(A0Application *)application {
    A0LogDebug(@"Configuring APIClient for application %@", application);
    self.application = application;
}

- (NSURLSessionDataTask *)fetchAppInfoWithSuccess:(A0APIClientFetchAppInfoSuccess)success
                                          failure:(A0APIClientError)failure {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.router.configurationURL];
    @weakify(self);
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        @strongify(self);
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSRange successRange = NSMakeRange(200, 100);
        if (!error && NSLocationInRange(httpResponse.statusCode, successRange)) {
            A0LogDebug(@"Obtained application info JSONP");
            if (success) {
                NSError *parseError;
                A0Application *application = [self parseApplicationFromJSONP:data error:&parseError];
                A0LogDebug(@"Application parsed form JSONP %@", application);
                if (!error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self configureForApplication:application];
                        success(application);
                    });
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        A0LogError(@"Failed to parse JSONP with error %@", error);
                        if (failure) {
                            failure(error);
                        }
                    });
                }
            }
        } else {
            A0LogError(@"Request to %@ failed with error %@", response.URL, error);
            NSError *taskError = error.code == NSURLErrorNotConnectedToInternet ? [A0Errors notConnectedToInternetError] : error;
            if (failure) {
                failure(taskError);
            }
        }
    }];
    A0LogVerbose(@"Fetching app info from URL %@", self.router.configurationURL);
    [task resume];
    return task;
}

#pragma mark - Database Authentication

- (NSURLSessionDataTask *)loginWithUsername:(NSString *)username
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
    A0LogVerbose(@"Starting Login with username & password %@", defaultParameters);
    if (![self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
        return nil;
    }
    @weakify(self);
    NSDictionary *payload = [defaultParameters asAPIPayload];
    return [self.manager POST:[self.router loginPath] parameters:payload success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        A0LogDebug(@"Obtained JWT & accessToken from Auth0 API");
        [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

- (NSURLSessionDataTask *)signUpWithUsername:(NSString *)username
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
    A0LogVerbose(@"Starting Signup with username & password %@", defaultParameters);
    if (![self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
        return nil;
    }
    NSDictionary *payload = [defaultParameters asAPIPayload];
    @weakify(self);
    return [self.manager POST:[self.router signUpPath] parameters:payload success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        A0LogDebug(@"Created user successfully %@", responseObject);
        if (loginOnSuccess) {
            [self loginWithUsername:username password:password parameters:parameters success:success failure:failure];
        } else {
            if (success) {
                success(nil, nil);
            }
        }
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

- (NSURLSessionDataTask *)changePassword:(NSString *)newPassword forUsername:(NSString *)username parameters:(A0AuthParameters *)parameters success:(void(^)())success failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:@{
                                                                                kEmailParamName: username,
                                                                                kPasswordParamName: newPassword,
                                                                                kTenantParamName: self.tenant,
                                                                                kClientIdParamName: self.clientId,
                                                                                }];
    [self addDatabaseConnectionNameToParams:defaultParameters];
    [defaultParameters addValuesFromParameters:parameters];
    A0LogVerbose(@"Chaning password with params %@", defaultParameters);
    if (![self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
        return nil;
    }
    NSDictionary *payload = [defaultParameters asAPIPayload];
    return [self.manager POST:[self.router changePasswordPath] parameters:payload success:^(NSURLSessionDataTask *operation, id responseObject) {
        A0LogDebug(@"Changed password for user %@. Response %@", username, responseObject);
        if (success) {
            success();
        }
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

- (NSURLSessionDataTask *)loginWithIdToken:(NSString *)idToken deviceName:(NSString *)deviceName parameters:(A0AuthParameters *)parameters success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:@{
                                                                                kIdTokenParamName: idToken,
                                                                                kGrantTypeParamName: @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                                kClientIdParamName: self.clientId,
                                                                                }];
    [self addDatabaseConnectionNameToParams:defaultParameters];
    [defaultParameters addValuesFromParameters:parameters];
    defaultParameters.device = deviceName;
    A0LogVerbose(@"Starting Login with JWT %@", defaultParameters);
    if (![self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
        return nil;
    }
    @weakify(self);
    NSDictionary *payload = [defaultParameters asAPIPayload];
    return [self.manager POST:[self.router loginPath] parameters:payload success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        A0LogDebug(@"Obtained JWT & accessToken from Auth0 API");
        [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

#pragma mark - SMS Authentication

- (NSURLSessionDataTask *)loginWithPhoneNumber:(NSString *)phoneNumber
                                      passcode:(NSString *)passcode
                                    parameters:(A0AuthParameters *)parameters
                                       success:(A0APIClientAuthenticationSuccess)success
                                       failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:@{
                                                                                kUsernameParamName: phoneNumber,
                                                                                kPasswordParamName: passcode,
                                                                                kGrantTypeParamName: @"password",
                                                                                kClientIdParamName: self.clientId,
                                                                                kConnectionParamName: @"sms",
                                                                                }];
    A0Strategy *strategy = [self.application strategyByName:A0StrategyNameSMS];
    A0Connection *connection = strategy.connections.firstObject;
    if (!self.application || connection.name) {
        [defaultParameters addValuesFromParameters:parameters];
        A0LogVerbose(@"Starting Login with username & password %@", defaultParameters);
        if ([self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
            @weakify(self);
            NSDictionary *payload = [defaultParameters asAPIPayload];
            return [self.manager POST:[self.router loginPath] parameters:payload success:^(NSURLSessionDataTask *operation, id responseObject) {
                @strongify(self);
                A0LogDebug(@"Obtained JWT & accessToken from Auth0 API");
                [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
            } failure:[A0APIClient sanitizeFailureBlock:failure]];
        }
    } else {
        A0LogError(@"No SMS connection found in Auth0 app.");
        if (failure) {
            failure([A0Errors noConnectionNameFound]);
        }
    }
    return nil;
}

#pragma mark - Social Authentication

- (NSURLSessionDataTask *)authenticateWithSocialConnectionName:(NSString *)connectionName
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
    A0LogVerbose(@"Authenticating with social strategy %@ and payload %@", connectionName, payload);
    @weakify(self);
    return [self.manager POST:[self.router socialLoginPath] parameters:payload success:^(NSURLSessionDataTask *operation, id responseObject) {
        @strongify(self);
        A0LogDebug(@"Authenticated successfuly with social connection %@", connectionName);
        [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
    } failure:[A0APIClient sanitizeFailureBlock:failure]];

}

#pragma mark - Delegation Authentication

- (NSURLSessionDataTask *)fetchNewIdTokenWithIdToken:(NSString *)idToken
                        parameters:(A0AuthParameters *)parameters
                           success:(A0APIClientNewIdTokenSuccess)success
                           failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParamters = [A0AuthParameters newWithDictionary:@{
                                                                               kClientIdParamName: self.clientId,
                                                                               kGrantTypeParamName: @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                               kIdTokenParamName: idToken,
                                                                               }];
    [defaultParamters addValuesFromParameters:parameters];
    return [self fetchDelegationTokenWithParameters:defaultParamters success:^(NSDictionary *tokenInfo) {
        if (success) {
            success([[A0Token alloc] initWithDictionary:tokenInfo]);
        }
    } failure:failure];
}

- (NSURLSessionDataTask *)fetchNewIdTokenWithRefreshToken:(NSString *)refreshToken
                             parameters:(A0AuthParameters *)parameters
                                success:(A0APIClientNewIdTokenSuccess)success
                                failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParamters = [A0AuthParameters newWithDictionary:@{
                                                                               kClientIdParamName: self.clientId,
                                                                               kGrantTypeParamName: @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                               kRefreshTokenParamName: refreshToken,
                                                                               }];
    [defaultParamters addValuesFromParameters:parameters];
    return [self fetchDelegationTokenWithParameters:defaultParamters success:^(NSDictionary *tokenInfo) {
        if (success) {
            success([[A0Token alloc] initWithDictionary:tokenInfo]);
        }
    } failure:failure];
}

- (NSURLSessionDataTask *)fetchDelegationTokenWithParameters:(A0AuthParameters *)parameters
                                   success:(A0APIClientNewDelegationTokenSuccess)success
                                   failure:(A0APIClientError)failure {
    NSAssert(parameters != nil, @"Delegated Authentication parameters must be non-nil!");
    A0AuthParameters *defaultParamters = [A0AuthParameters newWithDictionary:@{
                                                                               kClientIdParamName: self.clientId,
                                                                               kGrantTypeParamName: @"urn:ietf:params:oauth:grant-type:jwt-bearer",
                                                                               }];
    [defaultParamters addValuesFromParameters:parameters];
    NSDictionary *payload = [defaultParamters asAPIPayload];
    A0LogVerbose(@"Calling delegate authentication with params %@", parameters);
    return [self.manager POST:[self.router delegationPath] parameters:payload success:^(NSURLSessionDataTask *operation, id responseObject) {
        A0LogDebug(@"Delegation successful params %@", parameters);
        if (success) {
            success(responseObject);
        }
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

#pragma mark - User Profile

- (NSURLSessionDataTask *)fetchUserProfileWithIdToken:(NSString *)idToken
                            success:(A0APIClientUserProfileSuccess)success
                            failure:(A0APIClientError)failure {
    A0LogVerbose(@"Fetching User Profile from id token %@", idToken);
    return [self.manager POST:[self.router tokenInfoPath]
            parameters:@{
                         kIdTokenParamName: idToken,
                         }
               success:^(NSURLSessionDataTask *operation, id responseObject) {
                   A0LogDebug(@"Obtained user profile %@", responseObject);
                   if (success) {
                       A0UserProfile *profile = [[A0UserProfile alloc] initWithDictionary:responseObject];
                       success(profile);
                   }
               } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

#pragma mark - Account Linking

- (NSURLSessionDataTask *)unlinkAccountWithUserId:(NSString *)userId
                    accessToken:(NSString *)accessToken
                        success:(void (^)())success
                        failure:(A0APIClientError)failure {
    A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{
                                                                         kClientIdParamName: self.clientId,
                                                                         kAccessTokenParamName: accessToken,
                                                                         kSocialUserIdParamName: userId,
                                                                         }];
    A0LogVerbose(@"Unlinking account with id %@", userId);
    return [self.manager POST:[self.router unlinkPath]
            parameters:[parameters asAPIPayload]
               success:^(NSURLSessionDataTask *operation, id responseObject) {
                   if (success) {
                       success();
                   }
                   A0LogDebug(@"Account with id %@ unlinked successfully", userId);
               }
               failure:[A0APIClient sanitizeFailureBlock:failure]];
}

#pragma mark - Internal API calls

- (NSURLSessionDataTask *)fetchUserInfoWithTokenInfo:(NSDictionary *)tokenInfo success:(A0APIClientAuthenticationSuccess)success failure:(A0APIClientError)failure {
    A0Token *token = [[A0Token alloc] initWithDictionary:tokenInfo];
    return [self fetchUserProfileWithIdToken:token.idToken success:^(A0UserProfile *profile) {
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
        A0LogError(@"Parameters for DB auth MUST have a connection name!");
        if (failure) {
            failure([A0Errors noConnectionNameFound]);
        }
    }
    return hasConnectionName;
}

+ (AFFailureBlock) sanitizeFailureBlock:(A0APIClientError)failureBlock {
    AFFailureBlock sanitized = ^(NSURLSessionDataTask *operation, NSError *error) {
        A0LogError(@"Request %@ %@ failed with error %@", operation.originalRequest.HTTPMethod, operation.originalRequest.URL, error);
        NSError *operationError = error.code == NSURLErrorNotConnectedToInternet ? [A0Errors notConnectedToInternetError] : error;
        if (failureBlock) {
            failureBlock(operationError);
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
    if (*error) {
        return nil;
    }
    return [[A0Application alloc] initWithJSONDictionary:auth0AppInfo];
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
