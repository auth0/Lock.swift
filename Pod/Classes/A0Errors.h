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
    A0ErrorCodeInvalidPasswordAndRepeatPassword
};

FOUNDATION_EXPORT NSString * const A0JSONResponseSerializerErrorDataKey;

@interface A0Errors : NSObject

+ (NSError *)invalidLoginCredentialsUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidLoginUsernameUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidLoginPassword;

+ (NSError *)invalidSignUpCredentialsUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidSignUpUsernameUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidSignUpPassword;

+ (NSError *)invalidChangePasswordCredentialsUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidChangePasswordUsernameUsingEmail:(BOOL)usesEmail;
+ (NSError *)invalidChangePasswordPassword;
+ (NSError *)invalidChangePasswordRepeatPassword;
+ (NSError *)invalidChangePasswordRepeatPasswordAndPassword;

+ (NSString *)localizedStringForLoginError:(NSError *)error;
+ (NSString *)localizedStringForSignUpError:(NSError *)error;

@end
