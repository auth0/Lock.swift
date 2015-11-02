// A0PasswordlessLockViewModel.m
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

#import "A0PasswordlessLockViewModel.h"
#import "A0APIClient.h"
#import "A0EmailValidator.h"
#import "A0PhoneNumberValidator.h"
#import "A0LockNotification.h"
#import "NSDictionary+A0QueryParameters.h"


typedef void(^RequestCode)(NSString *identifier, A0PasswordlessLockViewModelRequestBlock _Nonnull callback);
typedef void(^AuthenticateWithCode)(NSString *identifier, NSString *code, A0PasswordlessLockViewModelAuthenticationBlock _Nonnull callback);

@interface A0PasswordlessLockViewModel ()
@property (copy, nonatomic) RequestCode requestCode;
@property (copy, nonatomic) AuthenticateWithCode authenticateWithCode;
@property (strong, nonatomic) id<A0FieldValidator> validator;
@property (strong, nonatomic) id linkObserver;
@end

@implementation A0PasswordlessLockViewModel

- (instancetype)initWithRequestCode:(_Nonnull RequestCode)requestCode authenticateWithCode:(_Nonnull AuthenticateWithCode)authenticateWithCode strategy:(A0PasswordlessLockStrategy)strategy {
    self = [super init];
    if (self) {
        self.requestCode = requestCode;
        self.authenticateWithCode = authenticateWithCode;
        self.validator = [self validatorForStrategy:strategy];
        self.onMagicLink = ^(NSError *error, BOOL completed) {};
        NSString *suffix = [self magicLinkSuffixOfStrategy:strategy];
        __weak A0PasswordlessLockViewModel *weakSelf = self;
        self.linkObserver = [[NSNotificationCenter defaultCenter] addObserverForName:A0LockNotificationUniversalLinkReceived object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            NSURL *link = note.userInfo[A0LockNotificationUniversalLinkParameterKey];
            NSDictionary *params = [NSDictionary fromQueryString:link.query];
            NSString *code = params[@"code"];
            if ([link.path hasSuffix:suffix] && code) {
                weakSelf.onMagicLink(nil, NO);
                [weakSelf authenticateWithVerificationCode:code callback:^(NSError * _Nullable error) {
                    weakSelf.onMagicLink(error, YES);
                }];
            }
        }];
    }
    return self;
}

- (instancetype)initWithLock:(A0Lock *)lock authenticationParameters:(A0AuthParameters *)parameters strategy:(A0PasswordlessLockStrategy)strategy {
    return [self initWithRequestCode:[self requestCodeForStrategy:strategy withLock:lock parameters:parameters]
                authenticateWithCode:[self authenticateWithCodeForStrategy:strategy withLock:lock parameters:parameters]
                            strategy:strategy];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self.linkObserver];
    self.linkObserver = nil;
}

- (void)requestVerificationCodeWithCallback:(A0PasswordlessLockViewModelRequestBlock)callback {
    self.requestCode([self normalizedIdentifier], callback);
}

- (void)authenticateWithVerificationCode:(NSString *)verificationCode
                                callback:(A0PasswordlessLockViewModelAuthenticationBlock)callback {
    self.authenticateWithCode([self normalizedIdentifier], verificationCode, callback);
}

- (BOOL)hasIdentifier {
    return self.identifierError == nil;
}

- (NSError *)identifierError {
    return [self.validator validate];
}

#pragma mark - internal methods

- (RequestCode)requestCodeForStrategy:(A0PasswordlessLockStrategy)strategy withLock:(A0Lock *)lock parameters:(A0AuthParameters *)parameters {
    A0APIClient *client = [lock apiClient];
    switch (strategy) {
        case A0PasswordlessLockStrategyEmailCode:
            return ^(NSString *identifier, A0PasswordlessLockViewModelRequestBlock callback) {
                [client startPasswordlessWithEmail:identifier
                                           success:^{
                                               callback(nil);
                                           } failure:^(NSError * _Nonnull error) {
                                               callback(error);
                                           }];
            };
        case A0PasswordlessLockStrategyEmailMagicLink:
            return ^(NSString *identifier, A0PasswordlessLockViewModelRequestBlock callback) {
                [client startPasswordlessWithMagicLinkInEmail:identifier
                                                   parameters:[parameters copy]
                                                      success:^{
                                                          callback(nil);
                                                      } failure:^(NSError * _Nonnull error) {
                                                          callback(error);
                                                      }];
            };
        case A0PasswordlessLockStrategySMSCode:
            return ^(NSString *identifier, A0PasswordlessLockViewModelRequestBlock callback) {
                [client startPasswordlessWithPhoneNumber:identifier
                                           success:^{
                                               callback(nil);
                                           } failure:^(NSError * _Nonnull error) {
                                               callback(error);
                                           }];
            };
        case A0PasswordlessLockStrategySMSMagicLink:
            return ^(NSString *identifier, A0PasswordlessLockViewModelRequestBlock callback) {
                [client startPasswordlessWithMagicLinkInSMS:identifier
                                                 parameters:[parameters copy]
                                                    success:^{
                                                        callback(nil);
                                                    } failure:^(NSError * _Nonnull error) {
                                                        callback(error);
                                                    }];
            };
    }
}

- (AuthenticateWithCode)authenticateWithCodeForStrategy:(A0PasswordlessLockStrategy)strategy withLock:(A0Lock *)lock parameters:(A0AuthParameters *)parameters {
    A0APIClient *client = [lock apiClient];
    switch (strategy) {
        case A0PasswordlessLockStrategyEmailCode:
        case A0PasswordlessLockStrategyEmailMagicLink:
            return ^(NSString *identifier, NSString *code, A0PasswordlessLockViewModelAuthenticationBlock  _Nonnull callback) {
                [client loginWithEmail:identifier passcode:code parameters:[parameters copy] success:^(A0UserProfile * _Nonnull profile, A0Token * _Nonnull tokenInfo) {
                    self.onAuthentication(profile, tokenInfo);
                    callback(nil);
                } failure:^(NSError * _Nonnull error) {
                    callback(error);
                }];
            };
        case A0PasswordlessLockStrategySMSCode:
        case A0PasswordlessLockStrategySMSMagicLink:
            return ^(NSString *identifier, NSString *code, A0PasswordlessLockViewModelAuthenticationBlock  _Nonnull callback) {
                [client loginWithPhoneNumber:identifier passcode:code parameters:[parameters copy] success:^(A0UserProfile * _Nonnull profile, A0Token * _Nonnull tokenInfo) {
                    callback(nil);
                    self.onAuthentication(profile, tokenInfo);
                } failure:^(NSError * _Nonnull error) {
                    callback(error);
                }];
            };
    }
}

- (NSString *)magicLinkSuffixOfStrategy:(A0PasswordlessLockStrategy)strategy {
    switch (strategy) {
        case A0PasswordlessLockStrategyEmailCode:
        case A0PasswordlessLockStrategyEmailMagicLink:
            return @"/email";
        case A0PasswordlessLockStrategySMSCode:
        case A0PasswordlessLockStrategySMSMagicLink:
            return @"/sms";
    }
}

- (id<A0FieldValidator>)validatorForStrategy:(A0PasswordlessLockStrategy)strategy {
    __weak A0PasswordlessLockViewModel *weakSelf = self;
    switch (strategy) {
        case A0PasswordlessLockStrategyEmailCode:
        case A0PasswordlessLockStrategyEmailMagicLink:
            return [[A0EmailValidator alloc] initWithSource:^NSString * _Nullable {
                return weakSelf.identifier;
            }];
        case A0PasswordlessLockStrategySMSCode:
        case A0PasswordlessLockStrategySMSMagicLink:
            return [[A0PhoneNumberValidator alloc] initWithSource:^NSString * _Nullable {
                return weakSelf.identifier;
            }];
    }
}

- (NSString *)normalizedIdentifier {
    NSString *normalizedIdentifier = [[self.identifier componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
    return normalizedIdentifier;
}
@end
