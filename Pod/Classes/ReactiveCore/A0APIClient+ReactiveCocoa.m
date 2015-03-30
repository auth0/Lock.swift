// A0APIClient+ReactiveCocoa.m
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

#import "A0APIClient+ReactiveCocoa.h"

#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation A0APIClient (ReactiveCocoa)

- (RACSignal *)fetchAppInfo {
    RACReplaySubject *subject = [RACReplaySubject subject];
    [self fetchAppInfoWithSuccess:^(A0Application *application) {
        [subject sendNext:application];
        [subject sendCompleted];
    } failure:^(NSError *error) {
        [subject sendError:error];
    }];
    return subject;
}

- (RACSignal *)loginWithUsername:(NSString *)username
                        password:(NSString *)password
                      parameters:(A0AuthParameters *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self loginWithUsername:username password:password parameters:parameters success:^(A0UserProfile *profile, A0Token *tokenInfo) {
            RACTuple *tuple = RACTuplePack((id)profile, (id)tokenInfo);
            [subscriber sendNext:tuple];
            [subscriber sendCompleted];
        } failure:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] replayLazily];
}

- (RACSignal *)signUpWithUsername:(NSString *)username
                         password:(NSString *)password
                   loginOnSuccess:(BOOL)loginOnSuccess
                       parameters:(A0AuthParameters *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self signUpWithUsername:username
                        password:password
                  loginOnSuccess:loginOnSuccess
                      parameters:parameters
                         success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                             RACTuple *tuple = RACTuplePack((id)profile, (id)tokenInfo);
                             [subscriber sendNext:tuple];
                             [subscriber sendCompleted];
                         }
                         failure:^(NSError *error) {
                             [subscriber sendError:error];
                         }];
        return nil;
    }] replayLazily];
}

- (RACSignal *)changePassword:(NSString *)newPassword
                  forUsername:(NSString *)username
                   parameters:(A0AuthParameters *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self changePassword:newPassword
                 forUsername:username
                  parameters:parameters
                     success:^{
                         [subscriber sendNext:username];
                         [subscriber sendCompleted];
                     }
                     failure:^(NSError *error) {
                         [subscriber sendError:error];
                     }];
        return nil;
    }] replayLazily];
}

- (RACSignal *)loginWithIdToken:(NSString *)idToken
                     deviceName:(NSString *)deviceName
                     parameters:(A0AuthParameters *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self loginWithIdToken:idToken
                    deviceName:deviceName
                    parameters:parameters
                       success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                           RACTuple *tuple = RACTuplePack((id)profile, (id)tokenInfo);
                           [subscriber sendNext:tuple];
                           [subscriber sendCompleted];
                       }
                       failure:^(NSError *error) {
                           [subscriber sendError:error];
                       }];
        return nil;
    }] replayLazily];
}

- (RACSignal *)loginWithPhoneNumber:(NSString *)phoneNumber
                           passcode:(NSString *)passcode
                         parameters:(A0AuthParameters *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self loginWithPhoneNumber:phoneNumber
                          passcode:passcode
                        parameters:parameters
                           success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                               RACTuple *tuple = RACTuplePack((id)profile, (id)tokenInfo);
                               [subscriber sendNext:tuple];
                               [subscriber sendCompleted];
                           }
                           failure:^(NSError *error) {
                               [subscriber sendError:error];
                           }];
        return nil;
    }] replayLazily];
}

- (RACSignal *)authenticateWithSocialConnectionName:(NSString *)connectionName
                                        credentials:(A0IdentityProviderCredentials *)socialCredentials
                                         parameters:(A0AuthParameters *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self authenticateWithSocialConnectionName:connectionName
                                       credentials:socialCredentials
                                        parameters:parameters
                                           success:^(A0UserProfile *profile, A0Token *tokenInfo) {
                                               RACTuple *tuple = RACTuplePack((id)profile, (id)tokenInfo);
                                               [subscriber sendNext:tuple];
                                               [subscriber sendCompleted];
                                           }
                                           failure:^(NSError *error) {
                                               [subscriber sendError:error];
                                           }];
        return nil;
    }] replayLazily];
}

- (RACSignal *)fetchNewIdTokenWithIdToken:(NSString *)idToken
                               parameters:(A0AuthParameters *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self fetchNewIdTokenWithIdToken:idToken parameters:parameters success:^(A0Token *token) {
            [subscriber sendNext:token];
            [subscriber sendCompleted];
        } failure:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] replayLazily];
}

- (RACSignal *)fetchNewIdTokenWithRefreshToken:(NSString *)refreshToken
                                    parameters:(A0AuthParameters *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self fetchNewIdTokenWithRefreshToken:refreshToken
                                   parameters:parameters
                                      success:^(A0Token *token) {
                                          [subscriber sendNext:token];
                                          [subscriber sendCompleted];
                                      }
                                      failure:^(NSError *error) {
                                          [subscriber sendError:error];
                                      }];
        return nil;
    }] replayLazily];
}

- (RACSignal *)fetchDelegationTokenWithParameters:(A0AuthParameters *)parameters {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self fetchDelegationTokenWithParameters:parameters
                                         success:^(NSDictionary *delegationToken) {
                                             [subscriber sendNext:delegationToken];
                                             [subscriber sendCompleted];
                                         }
                                         failure:^(NSError *error) {
                                             [subscriber sendError:error];
                                         }];
        return nil;
    }] replayLazily];
}

- (RACSignal *)fetchUserProfileWithIdToken:(NSString *)idToken {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self fetchUserProfileWithIdToken:idToken
                                  success:^(A0UserProfile *profile) {
            [subscriber sendNext:profile];
            [subscriber sendCompleted];
        } failure:^(NSError *error) {
            [subscriber sendError:error];
        }];
        return nil;
    }] replayLazily];
}

- (RACSignal *)unlinkAccountWithUserId:(NSString *)userId
                           accessToken:(NSString *)accessToken {
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [self unlinkAccountWithUserId:userId
                          accessToken:accessToken
                              success:^{
                                  [subscriber sendNext:userId];
                                  [subscriber sendCompleted];
                              }
                              failure:^(NSError *error) {
                                  [subscriber sendError:error];
                              }];
        return nil;
    }] replayLazily];
}
@end
