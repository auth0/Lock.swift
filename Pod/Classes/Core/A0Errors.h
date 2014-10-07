// A0Errors.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, A0ErrorCode) {
    /**
     *  Both password and email/username are invalid
     */
    A0ErrorCodeInvalidCredentials = 0,
    /**
     *  Username/Email is invalid
     */
    A0ErrorCodeInvalidUsername,
    /**
     *  Password is invalid
     */
    A0ErrorCodeInvalidPassword,
    /**
     *  Repeat password is invalid (empty or doesnt match password)
     */
    A0ErrorCodeInvalidRepeatPassword,
    /**
     *  Both password and repeat password are invalid
     */
    A0ErrorCodeInvalidPasswordAndRepeatPassword,
    /**
     *  User cancelled facebook auth flow (Safari or Native)
     */
    A0ErrorCodeFacebookCancelled,
    /**
     *  User didn't authorize twitter app for authentication
     */
    A0ErrorCodeTwitterAppNotAuthorized,
    /**
     *  User cancelled twitter auth flow (Safari or Native)
     */
    A0ErrorCodeTwitterCancelled,
    /**
     *  Twitter is not configured in Auth0 Dashboard
     */
    A0ErrorCodeTwitterNotConfigured,
    /**
     *  Twitter account in iOS is invalid (e.g: password changed). It must be reentered in iOS Settings.
     */
    A0ErrorCodeTwitterInvalidAccount,
    /**
     *  Strategy is not found in A0Application. Please check if it's enabled in Auth0 Dashboard
     */
    A0ErrorCodeUknownProviderForStrategy,
    /**
     *  Safari/WebView auth flow was cancelled by the user
     */
    A0ErrorCodeAuth0Cancelled,
    /**
     *  User didn't authorize the app during Safari/WebView auth flow.
     */
    A0ErrorCodeAuth0NotAuthorized,
    /**
     *  Auth0 connection was not configured properly in Dashboard.
     */
    A0ErrorCodeAuth0InvalidConfiguration,
    /**
     *  iOS custom scheme for Auth0 was not registered in Info plist file.
     */
    A0ErrorCodeAuth0NoURLSchemeFound,
    /**
     *  Authentication parameters didn't contain a valid connection name.
     */
    A0ErrorCodeNoConnectionNameFound,
};

FOUNDATION_EXPORT NSString * const A0JSONResponseSerializerErrorDataKey;

@interface A0Errors : NSObject

+ (NSError *)noConnectionNameFound;

///----------------------------------------
/// @name Login Errors
///----------------------------------------

+ (NSError *)invalidLoginCredentialsUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidLoginUsernameUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidLoginPassword;

///----------------------------------------
/// @name Sign Up Errors
///----------------------------------------

+ (NSError *)invalidSignUpCredentialsUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidSignUpUsernameUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidSignUpPassword;

///----------------------------------------
/// @name Change Password Errors
///----------------------------------------

+ (NSError *)invalidChangePasswordCredentialsUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidChangePasswordUsernameUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidChangePasswordPassword;
+ (NSError *)invalidChangePasswordRepeatPassword;
+ (NSError *)invalidChangePasswordRepeatPasswordAndPassword;

///----------------------------------------
/// @name Enterprise & Social Errors
///----------------------------------------

+ (NSError *)urlSchemeNotRegistered;
+ (NSError *)unkownProviderForStrategy:(NSString *)strategyName;
+ (NSError *)facebookCancelled;
+ (NSError *)twitterAppNotAuthorized;
+ (NSError *)twitterAppOauthNotAuthorized;
+ (NSError *)twitterCancelled;
+ (NSError *)twitterNotConfigured;
+ (NSError *)twitterInvalidAccount;
+ (NSError *)auth0CancelledForStrategy:(NSString *)strategyName;
+ (NSError *)auth0NotAuthorizedForStrategy:(NSString *)strategyName;
+ (NSError *)auth0InvalidConfigurationForStrategy:(NSString *)strategyName;

///----------------------------------------
/// @name Localized Messages
///----------------------------------------

+ (NSString *)localizedStringForSocialLoginError:(NSError *)error;
+ (NSString *)localizedStringForLoginError:(NSError *)error;
+ (NSString *)localizedStringForSignUpError:(NSError *)error;
+ (NSString *)localizedStringForChangePasswordError:(NSError *)error;

@end
