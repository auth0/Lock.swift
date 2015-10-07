// A0EmailLockViewModel.m
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

#import "A0EmailLockViewModel.h"
#import "A0APIClient.h"

typedef void(^RequestCode)(NSString *email, A0EmailLockViewModelRequestBlock _Nonnull callback);
typedef void(^AuthenticateWithCode)(NSString *email, NSString *code, A0EmailLockViewModelAuthenticationBlock _Nonnull callback);

@interface A0EmailLockViewModel ()
@property (copy, nonatomic) RequestCode requestCode;
@property (strong, nonatomic) AuthenticateWithCode authenticateWithCode;
@end

@implementation A0EmailLockViewModel

- (instancetype)initWithRequestCode:(_Nonnull RequestCode)requestCode authenticateWithCode:(_Nonnull AuthenticateWithCode)authenticateWithCode {
    self = [super init];
    if (self) {
        self.requestCode = requestCode;
        self.authenticateWithCode = authenticateWithCode;
    }
    return self;
}

- (instancetype)initWithLock:(A0Lock *)lock authenticationParameters:(A0AuthParameters *)parameters {
    A0APIClient *client = [lock apiClient];
    return [self initWithRequestCode:^(NSString *email, A0EmailLockViewModelRequestBlock callback) {
            [client startPasswordlessWithEmail:email
                                       success:^{
                                           callback(nil);
                                       } failure:^(NSError * _Nonnull error) {
                                           callback(error);
                                       }];
    } authenticateWithCode:^(NSString *email, NSString *code, A0EmailLockViewModelAuthenticationBlock  _Nonnull callback) {
        [client loginWithEmail:email passcode:code parameters:[parameters copy] success:^(A0UserProfile * _Nonnull profile, A0Token * _Nonnull tokenInfo) {
            callback(nil, profile, tokenInfo);
        } failure:^(NSError * _Nonnull error) {
            callback(error, nil, nil);
        }];
    }];
}

- (instancetype)initForMagicLinkWithLock:(A0Lock *)lock authenticationParameters:(A0AuthParameters *)parameters {
    A0APIClient *client = [lock apiClient];
    return [self initWithRequestCode:^(NSString *email, A0EmailLockViewModelRequestBlock callback) {
        [client startPasswordlessWithMagicLinkInEmail:email
                                           parameters:[parameters copy]
                                              success:^{
                                                  callback(nil);
                                              } failure:^(NSError * _Nonnull error) {
                                                  callback(error);
                                              }];
    } authenticateWithCode:^(NSString *email, NSString *code, A0EmailLockViewModelAuthenticationBlock  _Nonnull callback) {
        [client loginWithEmail:email passcode:code parameters:[parameters copy] success:^(A0UserProfile * _Nonnull profile, A0Token * _Nonnull tokenInfo) {
            callback(nil, profile, tokenInfo);
        } failure:^(NSError * _Nonnull error) {
            callback(error, nil, nil);
        }];
    }];
}

- (void)requestVerificationCodeWithCallback:(A0EmailLockViewModelRequestBlock)callback {
    self.requestCode(self.email, callback);
}

- (void)authenticateWithVerificationCode:(NSString *)verificationCode
                                callback:(A0EmailLockViewModelAuthenticationBlock)callback {

}

- (BOOL)hasEmail {
    return [self.email stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0;
}
@end
