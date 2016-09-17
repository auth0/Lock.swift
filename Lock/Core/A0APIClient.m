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
#import "A0UserAPIClient.h"
#import "A0APIv1Router.h"
#import "A0Lock.h"
#import "Constants.h"
#import "A0Telemetry.h"

#define kClientIdParamName @"client_id"
#define kUsernameParamName @"username"
#define kPasswordParamName @"password"
#define kGrantTypeParamName @"grant_type"
#define kApiTypeParamName @"api_type"
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

- (instancetype)initWithAPIRouter:(id<A0APIRouter>)router {
    NSAssert(router, @"You must supply a valid API Router");
    self = [super init];
    if (self) {
        _router = router;
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[router endpointURL]];
        _manager.requestSerializer = [AFJSONRequestSerializer serializer];
        _manager.responseSerializer = [A0JSONResponseSerializer serializer];
        if ([A0Telemetry telemetryEnabled]) {
            A0Telemetry *telemetry = [[A0Telemetry alloc] init];
            [_manager.requestSerializer setValue:telemetry.base64Value forHTTPHeaderField:A0ClientInfoHeaderName];
        }
    }
    return self;
}

- (void)logout {
    self.userClient = nil;
}

- (void)setTelemetryInfo:(NSString *)telemetryInfo {
    [self willChangeValueForKey:NSStringFromSelector(@selector(telemetryInfo))];
    _telemetryInfo = telemetryInfo;
    [self didChangeValueForKey:NSStringFromSelector(@selector(telemetryInfo))];
    [_manager.requestSerializer setValue:telemetryInfo forHTTPHeaderField:A0ClientInfoHeaderName];
}

+ (instancetype)sharedClient {
    static A0APIClient *client;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        client = [[A0Lock new] apiClient];
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
    NSURLRequest *request = [NSURLRequest requestWithURL:self.router.configurationURL];
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSRange successRange = NSMakeRange(200, 100);
        if (!error && NSLocationInRange(httpResponse.statusCode, successRange)) {
            A0LogDebug(@"Obtained application info JSONP");
            if (success) {
                NSError *parseError;
                A0Application *application = [self parseApplicationFromJSONP:data error:&parseError];
                A0LogDebug(@"Application parsed form JSONP %@", application);
                if (!parseError) {
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
            if (!taskError) {
                taskError = [A0Errors configurationLoadFailed];
            }
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
    NSDictionary *payload = [defaultParameters asAPIPayload];
    return [self.manager POST:[self.router loginPath] parameters:payload progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        A0LogDebug(@"Obtained JWT & accessToken from Auth0 API");
        [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

- (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email
                                 username:(NSString *)username
                                 password:(NSString *)password
                           loginOnSuccess:(BOOL)loginOnSuccess
                               parameters:(A0AuthParameters *)parameters
                                  success:(A0APIClientSignUpSuccess)success
                                  failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:@{
                                                                                kEmailParamName: email,
                                                                                kPasswordParamName: password,
                                                                                kClientIdParamName: self.clientId,
                                                                                }];
    [self addDatabaseConnectionNameToParams:defaultParameters];
    if (username) {
        defaultParameters[kUsernameParamName] = username;
    }
    [defaultParameters addValuesFromParameters:parameters];
    A0LogVerbose(@"Starting Signup with username & password %@", defaultParameters);
    if (![self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
        return nil;
    }
    NSDictionary *payload = [defaultParameters asAPIPayload];
    return [self.manager POST:[self.router signUpPath] parameters:payload progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        A0LogDebug(@"Created user successfully %@", responseObject);
        if (loginOnSuccess) {
            NSString *loginUsername = username ?: email;
            [self loginWithUsername:loginUsername password:password parameters:parameters success:success failure:failure];
        } else {
            if (success) {
                success(nil, nil);
            }
        }
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

- (NSURLSessionDataTask *)signUpWithUsername:(NSString *)username
                                    password:(NSString *)password
                              loginOnSuccess:(BOOL)loginOnSuccess
                                  parameters:(A0AuthParameters *)parameters
                                     success:(A0APIClientSignUpSuccess)success
                                     failure:(A0APIClientError)failure {
    return [self signUpWithEmail:username username:username password:password loginOnSuccess:loginOnSuccess parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)signUpWithEmail:(NSString *)email
                                 password:(NSString *)password
                           loginOnSuccess:(BOOL)loginOnSuccess
                               parameters:(A0AuthParameters *)parameters
                                  success:(A0APIClientSignUpSuccess)success
                                  failure:(A0APIClientError)failure {
    return [self signUpWithEmail:email username:nil password:password loginOnSuccess:loginOnSuccess parameters:parameters success:success failure:failure];
}

- (NSURLSessionDataTask *)requestChangePasswordForUsername:(NSString *)username
                                                parameters:(A0AuthParameters *)parameters
                                                   success:(void (^)())success failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:@{
                                                                                kEmailParamName: username,
                                                                                kClientIdParamName: self.clientId,
                                                                                }];
    [self addDatabaseConnectionNameToParams:defaultParameters];
    [defaultParameters addValuesFromParameters:parameters];
    A0LogVerbose(@"Requesting change password with params %@", defaultParameters);
    if (![self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
        return nil;
    }
    NSDictionary *payload = [defaultParameters asAPIPayload];
    return [self.manager POST:[self.router changePasswordPath] parameters:payload progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        A0LogDebug(@"Changed password for user %@ requested. Response %@", username, responseObject);
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
    NSDictionary *payload = [defaultParameters asAPIPayload];
    return [self.manager POST:[self.router loginPath] parameters:payload progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
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

    [defaultParameters addValuesFromParameters:parameters];
    A0LogVerbose(@"Starting Login with phone & passcode %@", defaultParameters);
    NSDictionary *payload = [defaultParameters asAPIPayload];
    return [self.manager POST:[self.router loginPath] parameters:payload progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        A0LogDebug(@"Obtained JWT & accessToken from Auth0 API");
        [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

#pragma mark - Email Authentication

- (NSURLSessionDataTask *)loginWithEmail:(NSString *)email
                                passcode:(NSString *)passcode
                              parameters:(A0AuthParameters *)parameters
                                 success:(A0APIClientAuthenticationSuccess)success
                                 failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:@{
                                                                                kUsernameParamName: email,
                                                                                kPasswordParamName: passcode,
                                                                                kGrantTypeParamName: @"password",
                                                                                kClientIdParamName: self.clientId,
                                                                                kConnectionParamName: @"email",
                                                                                }];
    [defaultParameters addValuesFromParameters:parameters];
    A0LogVerbose(@"Starting Login with email & passcode %@", defaultParameters);
    NSDictionary *payload = [defaultParameters asAPIPayload];
    return [self.manager POST:[self.router loginPath] parameters:payload progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        A0LogDebug(@"Obtained JWT & accessToken from Auth0 API");
        [self fetchUserInfoWithTokenInfo:responseObject success:success failure:failure];
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

#pragma mark - Social Authentication

- (NSURLSessionDataTask *)authenticateWithSocialConnectionName:(NSString *)connectionName
                                                   credentials:(A0IdentityProviderCredentials *)credentials
                                                    parameters:(A0AuthParameters *)parameters
                                                       success:(A0APIClientAuthenticationSuccess)success
                                                       failure:(A0APIClientError)failure {
    NSDictionary *params = @{
                             kClientIdParamName: self.clientId,
                             };
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:params];
    if (credentials.extraInfo[A0StrategySocialTokenSecretParameter]) {
        defaultParameters[kAccessTokenSecretParamName] = credentials.extraInfo[A0StrategySocialTokenSecretParameter];
    }
    if (credentials.extraInfo[A0StrategySocialUserIdParameter]) {
        defaultParameters[kSocialUserIdParamName] = credentials.extraInfo[A0StrategySocialUserIdParameter];
    }
    [defaultParameters addValuesFromParameters:parameters];
    if (defaultParameters.accessToken) {
        defaultParameters[A0ParameterMainAccessToken] = defaultParameters.accessToken;
    }
    defaultParameters.accessToken = credentials.accessToken;
    defaultParameters[kConnectionParamName] = connectionName;

    NSDictionary *payload = [defaultParameters asAPIPayload];
    A0LogVerbose(@"Authenticating with social strategy %@ and payload %@", connectionName, payload);
    return [self.manager POST:[self.router socialLoginPath] parameters:payload progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
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
                                                                               kApiTypeParamName: @"app",
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
                                                                               kApiTypeParamName: @"app",
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
    return [self.manager POST:[self.router delegationPath] parameters:payload progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
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
                     progress:nil
                      success:^(NSURLSessionDataTask *operation, id responseObject) {
                          A0LogDebug(@"Obtained user profile %@", responseObject);
                          if (success) {
                              A0UserProfile *profile = [[A0UserProfile alloc] initWithDictionary:responseObject];
                              success(profile);
                          }
                      }
                      failure:[A0APIClient sanitizeFailureBlock:failure]];
}

#pragma mark - Account Linking

- (NSURLSessionDataTask *)unlinkAccountWithUserId:(NSString *)userId
                    accessToken:(NSString *)accessToken
                        success:(void (^)())success
                        failure:(A0APIClientError)failure {
    A0AuthParameters *parameters = [A0AuthParameters newWithDictionary:@{
                                                                         @"clientID": self.clientId,
                                                                         kAccessTokenParamName: accessToken,
                                                                         kSocialUserIdParamName: userId,
                                                                         }];
    A0LogVerbose(@"Unlinking account with id %@", userId);
    return [self.manager POST:[self.router unlinkPath]
                   parameters:[parameters asAPIPayload]
                     progress:nil
                      success:^(NSURLSessionDataTask *operation, id responseObject) {
                          if (success) {
                              success();
                          }
                          A0LogDebug(@"Account with id %@ unlinked successfully", userId);
                      }
                      failure:^(NSURLSessionDataTask *task, NSError *error) {
                          if ([(NSHTTPURLResponse *)task.response statusCode] == 200) {
                              //unlink returns text/plain and that's why it will fail
                              if (success) {
                                  success();
                              }
                              A0LogDebug(@"Account with id %@ unlinked successfully", userId);
                          } else {
                              AFFailureBlock block = [A0APIClient sanitizeFailureBlock:failure];
                              block(task, error);
                          }
                      }];
}

#pragma mark - Passwordless Authentication

- (NSURLSessionDataTask *)startPasswordlessWithPhoneNumber:(NSString *)phoneNumber
                                                   success:(void(^)())success
                                                   failure:(A0APIClientError)failure {
    return [self.manager POST:[self.router startPasswordless]
                   parameters:@{
                                kClientIdParamName: self.clientId,
                                @"phone_number": phoneNumber,
                                kConnectionParamName: @"sms",
                                }
                     progress:nil
                      success:^(NSURLSessionDataTask *task, id responseObject) {
                          if (success) {
                              success();
                          }
                          A0LogDebug(@"SMS send with OTP to number %@", phoneNumber);
                      } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

- (NSURLSessionDataTask *)startPasswordlessWithEmail:(NSString *)email success:(void (^)())success failure:(A0APIClientError)failure {
    return [self.manager POST:[self.router startPasswordless]
                   parameters:@{
                                kClientIdParamName: self.clientId,
                                kEmailParamName: email,
                                kConnectionParamName: @"email",
                                @"send": @"code"
                                }
                     progress:nil
                      success:^(NSURLSessionDataTask *task, id responseObject) {
                          if (success) {
                              success();
                          }
                      }
                      failure:[A0APIClient sanitizeFailureBlock:failure]];
}

- (NSURLSessionDataTask *)startPasswordlessWithMagicLinkInEmail:(NSString *)email
                                                     parameters:(A0AuthParameters *)parameters
                                                        success:(void(^)())success
                                                        failure:(A0APIClientError)failure {
    NSDictionary *params = @{
                             kClientIdParamName: self.clientId,
                             kEmailParamName: email,
                             kConnectionParamName: @"email",
                             @"send": @"link_ios",
                             };
    if (parameters) {
        NSMutableDictionary *dict = [params mutableCopy];
        dict[@"authParams"] = [parameters asAPIPayload];
        params = [NSDictionary dictionaryWithDictionary:dict];
    }
    return [self.manager POST:[self.router startPasswordless]
                   parameters:params
                     progress:nil
                      success:^(NSURLSessionDataTask *task, id responseObject) {
                          if (success) {
                              success();
                          }
                      }
                      failure:[A0APIClient sanitizeFailureBlock:failure]];

}

- (NSURLSessionDataTask *)startPasswordlessWithMagicLinkInSMS:(NSString *)phoneNumber
                                                     parameters:(A0AuthParameters *)parameters
                                                        success:(void(^)())success
                                                        failure:(A0APIClientError)failure {
    NSDictionary *params = @{
                             kClientIdParamName: self.clientId,
                             @"phone_number": phoneNumber,
                             kConnectionParamName: @"sms",
                             @"send": @"link_ios",
                             };
    if (parameters) {
        NSMutableDictionary *dict = [params mutableCopy];
        dict[@"authParams"] = [parameters asAPIPayload];
        params = [NSDictionary dictionaryWithDictionary:dict];
    }
    return [self.manager POST:[self.router startPasswordless]
                   parameters:params
                     progress:nil
                      success:^(NSURLSessionDataTask *task, id responseObject) {
                          if (success) {
                              success();
                          }
                      }
                      failure:[A0APIClient sanitizeFailureBlock:failure]];

}

#pragma mark - Token Request

- (NSURLSessionDataTask *)requestTokenWithParameters:(NSDictionary *)parameters
                                            callback:(void(^)(NSError * _Nullable error, A0Token * _Nullable token))callback {
    NSMutableDictionary *request = [@{
                                      kClientIdParamName: self.clientId,
                                      kGrantTypeParamName: @"authorization_code",
                                      } mutableCopy];
    [request addEntriesFromDictionary:parameters];
    A0LogDebug(@"Performing authorization code exchange with parameters %@", request);
    return [self.manager POST:@"oauth/token"
                   parameters:request
                     progress:nil
                      success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                          A0Token *token = [[A0Token alloc] initWithDictionary:responseObject];
                          A0LogDebug(@"Received token information %@", responseObject);
                          callback(nil, token);
                      }
                      failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                          A0LogError(@"Failed to exchange authorization code with error %@", error);
                          callback(error, nil);
                      }];
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
        parameters[kConnectionParamName] = connection.name;
    }
}

- (BOOL)checkForDatabaseConnectionIn:(A0AuthParameters *)parameters failure:(A0APIClientError)failure {
    BOOL hasConnectionName = parameters[kConnectionParamName] != nil;
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

- (instancetype)initWithClientId:(NSString *)clientId andTenant:(NSString *)tenant {
    NSAssert(clientId, @"You must supply your Auth0 app's Client Id.");
    NSAssert(tenant, @"You must supply your Auth0 app's Tenant.");
    A0Lock *lock = [A0Lock newLockWithClientId:clientId domain:[NSString stringWithFormat:@"https://%@.auth0.com", tenant]];
    A0APIv1Router *router = [[A0APIv1Router alloc] initWithClientId:lock.clientId domainURL:lock.domainURL configurationURL:lock.configurationURL];
    return [self initWithAPIRouter:router];
}

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

- (NSURLSessionDataTask *)changePassword:(NSString *)newPassword forUsername:(NSString *)username parameters:(A0AuthParameters *)parameters success:(void(^)())success failure:(A0APIClientError)failure {
    A0AuthParameters *defaultParameters = [A0AuthParameters newWithDictionary:@{
                                                                                kEmailParamName: username,
                                                                                kPasswordParamName: newPassword,
                                                                                kClientIdParamName: self.clientId,
                                                                                }];
    [self addDatabaseConnectionNameToParams:defaultParameters];
    [defaultParameters addValuesFromParameters:parameters];
    A0LogVerbose(@"Chaning password with params %@", defaultParameters);
    if (![self checkForDatabaseConnectionIn:defaultParameters failure:failure]) {
        return nil;
    }
    NSDictionary *payload = [defaultParameters asAPIPayload];
    return [self.manager POST:[self.router changePasswordPath] parameters:payload progress:nil success:^(NSURLSessionDataTask *operation, id responseObject) {
        A0LogDebug(@"Changed password for user %@. Response %@", username, responseObject);
        if (success) {
            success();
        }
    } failure:[A0APIClient sanitizeFailureBlock:failure]];
}

@end
