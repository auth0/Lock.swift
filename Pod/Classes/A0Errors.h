//
//  A0Errors.h
//  Pods
//
//  Created by Hernan Zalazar on 7/21/14.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, A0ErrorCode) {
    A0ErrorCodeInvalidLoginCredentials = 0,
    A0ErrorCodeInvalidLoginUsername,
    A0ErrorCodeInvalidLoginPassword
};

@interface A0Errors : NSObject

+ invalidLoginCredentialsUsingEmail:(BOOL)usesEmail;
+ invalidLoginUsernameUsingEmail:(BOOL)usesEmail;
+ invalidLoginPassword;

@end
