// A0EmailLockViewModel.h
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

#import <Foundation/Foundation.h>
#import "A0UserProfile.h"
#import "A0Token.h"
#import "A0AuthParameters.h"
#import "A0Lock.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^A0EmailLockViewModelRequestBlock)(NSError * _Nullable error);
typedef void(^A0EmailLockViewModelAuthenticationBlock)(NSError * _Nullable error);

@interface A0EmailLockViewModel : NSObject

@property (copy, nonatomic) void(^onAuthenticationBlock)(A0UserProfile *profile, A0Token *token);
@property (strong, nullable, nonatomic) NSString *email;
@property (readonly, nonatomic) BOOL hasEmail;
@property (readonly, nullable, nonatomic) NSError *emailError;
@property (copy, nonatomic) void(^onMagicLink)(NSError * _Nullable error, BOOL completed);

- (instancetype)initForMagicLinkWithLock:(A0Lock *)lock authenticationParameters:(A0AuthParameters *)parameters;
- (instancetype)initWithLock:(A0Lock *)lock authenticationParameters:(A0AuthParameters *)parameters;

- (void)requestVerificationCodeWithCallback:(A0EmailLockViewModelRequestBlock)callback;
- (void)authenticateWithVerificationCode:(NSString *)verificationCode callback:(A0EmailLockViewModelAuthenticationBlock)callback;

@end

NS_ASSUME_NONNULL_END