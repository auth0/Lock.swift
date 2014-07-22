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
    A0ErrorCodeInvalidPassword
};

@interface A0Errors : NSObject

+ invalidLoginCredentialsUsingEmail:(BOOL)usesEmail;
+ invalidLoginUsernameUsingEmail:(BOOL)usesEmail;
+ invalidLoginPassword;

+ invalidSignUpCredentialsUsingEmail:(BOOL)usesEmail;
+ invalidSignUpUsernameUsingEmail:(BOOL)usesEmail;
+ invalidSignUpPassword;

@end
