// A0PasswordlessLockViewModel.h
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

typedef void(^A0PasswordlessLockViewModelRequestBlock)(NSError * _Nullable error);
typedef void(^A0PasswordlessLockViewModelAuthenticationBlock)(NSError * _Nullable error);

/**
 *  Different ways to perform passwordless authetication with Lock
 */
typedef NS_ENUM(NSInteger, A0PasswordlessLockStrategy){
    /**
     *  Send a magic link via email. Requires iOS 9
     */
    A0PasswordlessLockStrategyEmailMagicLink,
    /**
     *  Send a magic link via sms. Requires iOS 9
     */
    A0PasswordlessLockStrategySMSMagicLink,
    /**
     *  Send a an email with a verification code to login
     */
    A0PasswordlessLockStrategyEmailCode,
    /**
     *  Send a a sms with a verification code to login
     */
    A0PasswordlessLockStrategySMSCode
};

/**
 *  Passwordless authentication component for Code/Magic Link authentication with either SMS or Email
 */
@interface A0PasswordlessLockViewModel : NSObject

/**
 *  block called when the user authenticates with it's profile and tokens
 */
@property (copy, nonatomic) void(^onAuthentication)(A0UserProfile *profile, A0Token *token);
/**
 *  The "username" of the user account, which could be an email or phone number depending of the type of passwordless strategy
 */
@property (strong, nullable, nonatomic) NSString *identifier;
/**
 *  If there is a valid identifier available
 */
@property (readonly, nonatomic) BOOL hasIdentifier;
/**
 *  If the identifier is invalid and error will be available in this property
 */
@property (readonly, nullable, nonatomic) NSError *identifierError;
/**
 *  Block that is called whenever a Magic Link is tapped by the user and Lock tries to authenticate, the authentication failed or was successful.
 */
@property (copy, nonatomic) void(^onMagicLink)(NSError * _Nullable error, BOOL completed);

/**
 *  Initialise a new instance
 *
 *  @param lock       configured with your Auth0 credentials
 *  @param parameters to send when the user is being authenticated
 *  @param strategy   how the user is authenticated
 *
 *  @return an instance
 */
- (instancetype)initWithLock:(A0Lock *)lock authenticationParameters:(A0AuthParameters *)parameters strategy:(A0PasswordlessLockStrategy)strategy;

/**
 *  Tells Auth0 to start the passwordless authentication by sending a verification code or a magic link
 *
 *  @param callback called on success or failure
 */
- (void)requestVerificationCodeWithCallback:(A0PasswordlessLockViewModelRequestBlock)callback;
/**
 *  Authenticates the user with the supplied verification code and identifier. 
 *  You only need to call this method if you are not using Magic Link and if the authentication succeeds the `onAuthentication` block will be called.
 *
 *  @param verificationCode sent to the user
 *  @param callback         called on success or failure
 */
- (void)authenticateWithVerificationCode:(NSString *)verificationCode callback:(A0PasswordlessLockViewModelAuthenticationBlock)callback;

@end

NS_ASSUME_NONNULL_END