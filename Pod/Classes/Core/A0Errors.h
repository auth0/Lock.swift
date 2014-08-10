//
//  A0Errors.h
//  Pods
//
//  Created by Hernan Zalazar on 7/21/14.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, A0ErrorCode) {
    A0ErrorCodeInvalidCredentials = 0,
    A0ErrorCodeInvalidUsername,
    A0ErrorCodeInvalidPassword,
    A0ErrorCodeInvalidRepeatPassword,
    A0ErrorCodeInvalidPasswordAndRepeatPassword,
    A0ErrorCodeFacebookCancelled,
    A0ErrorCodeTwitterAppNoAuthorized,
    A0ErrorCodeTwitterCancelled,
};

FOUNDATION_EXPORT NSString * const A0JSONResponseSerializerErrorDataKey;

@interface A0Errors : NSObject

#pragma mark - Login Errors

+ (NSError *)invalidLoginCredentialsUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidLoginUsernameUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidLoginPassword;

#pragma mark - Sign Up Errors

+ (NSError *)invalidSignUpCredentialsUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidSignUpUsernameUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidSignUpPassword;

#pragma mark - Change Password Errors

+ (NSError *)invalidChangePasswordCredentialsUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidChangePasswordUsernameUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidChangePasswordPassword;
+ (NSError *)invalidChangePasswordRepeatPassword;
+ (NSError *)invalidChangePasswordRepeatPasswordAndPassword;

#pragma mark - Social Errors

+ (NSError *)facebookCancelled;
+ (NSError *)twitterAppNoAuthorized;
+ (NSError *)twitterCancelled;

#pragma mark - Localized Messages

+ (NSString *)localizedStringForSocialLoginError:(NSError *)error;
+ (NSString *)localizedStringForLoginError:(NSError *)error;
+ (NSString *)localizedStringForSignUpError:(NSError *)error;
+ (NSString *)localizedStringForChangePasswordError:(NSError *)error;

@end
