// NSError+A0LockErrors.h
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
#import "A0ErrorCode.h"

FOUNDATION_EXPORT NSString * const A0ErrorDomain;

/**
 *  Category for Lock & A0IdentityProviderAuthenticator errors. (A0APICient errors are not included)
 */
@interface NSError (A0LockErrors)

/**
 *  Check if the NSError is an Auth0 Lock error with a specific code.
 *
 *  @param code of the Lock error
 *
 *  @return if its an expected Lock Error
 */
- (BOOL)a0_auth0ErrorWithCode:(A0ErrorCode)code;

/**
 *  Check if the error is from a cancelled social authentication
 *
 *  @return if its a cancelled social authentication error.
 */
- (BOOL)a0_cancelledSocialAuthenticationError;

///----------------------------------------
/// @name Localized Messages
///----------------------------------------

/**
 *  Returns localized message for login error
 *
 *  @param connectionName used to login
 *
 *  @return localized message
 */
- (NSString *)a0_localizedStringErrorForConnectionName:(NSString *)connectionName;

/**
 *  Returns localized message for login error
 *
 *  @param connectionName used to login
 *
 *  @return localized message
 */
- (NSString *)a0_localizedStringForLoginError;

/**
 *  Returns localized message for passwordless email login error
 *
 *  @return localized message
 */
- (NSString *)a0_localizedStringForPasswordlessEmailLoginError;

/**
 *  Returns localized message for passwordless sms login error
 *
 *  @return localized message
 */
- (NSString *)a0_localizedStringForPasswordlessSMSLoginError;

/**
 *  Returns localized message for signup error
 *
 *  @return localized message
 */
- (NSString *)a0_localizedStringForSignUpError;

/**
 *  Returns localized message for change password error
 *
 *  @return localized message
 */
- (NSString *)a0_localizedStringForChangePasswordError;

@end
