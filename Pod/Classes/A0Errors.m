//
//  A0Errors.m
//  Pods
//
//  Created by Hernan Zalazar on 7/21/14.
//
//

#import "A0Errors.h"

NSString * const A0ErrorDomain = @"com.auth0";

@implementation A0Errors

#pragma mark - Login errors

+ (NSError *)invalidLoginCredentialsUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = NSLocalizedString(@"The email and password you entered is invalid. Please try again.", nil);
    } else {
        failureReason = NSLocalizedString(@"The username and password you entered is invalid. Please try again.", nil);
    }
    return [self errorWithCode:A0ErrorCodeInvalidCredentials
                   description:NSLocalizedString(@"Invalid login credentials", nil)
                 failureReason:failureReason];
}

+ (NSError *)invalidLoginUsernameUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = NSLocalizedString(@"The email you entered is invalid. Please try again.", nil);
    } else {
        failureReason = NSLocalizedString(@"The username you entered is invalid. Please try again.", nil);
    }
    return [self errorWithCode:A0ErrorCodeInvalidUsername
                   description:NSLocalizedString(@"Invalid login credentials", nil)
                 failureReason:failureReason];
}

+ (NSError *)invalidLoginPassword {
    return [self errorWithCode:A0ErrorCodeInvalidPassword
                   description:NSLocalizedString(@"Invalid login credentials", nil)
                 failureReason:NSLocalizedString(@"The password you entered is invalid. Please try again.", nil)];
}

#pragma mark - SignUp errors

+ (NSError *)invalidSignUpCredentialsUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = NSLocalizedString(@"The email and password you entered is invalid. Please try again.", nil);
    } else {
        failureReason = NSLocalizedString(@"The username and password you entered is invalid. Please try again.", nil);
    }
    return [self errorWithCode:A0ErrorCodeInvalidCredentials
                   description:NSLocalizedString(@"Invalid credentials", nil)
                 failureReason:failureReason];
}

+ (NSError *)invalidSignUpUsernameUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = NSLocalizedString(@"The email you entered is invalid. Please try again.", nil);
    } else {
        failureReason = NSLocalizedString(@"The username you entered is invalid. Please try again.", nil);
    }
    return [self errorWithCode:A0ErrorCodeInvalidUsername
                   description:NSLocalizedString(@"Invalid credentials", nil)
                 failureReason:failureReason];
}

+ (NSError *)invalidSignUpPassword {
    return [self errorWithCode:A0ErrorCodeInvalidPassword
                   description:NSLocalizedString(@"Invalid credentials", nil)
                 failureReason:NSLocalizedString(@"The password you entered is invalid. Please try again.", nil)];
}

#pragma mark - Change password errors

+ (NSError *)invalidChangePasswordCredentialsUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = NSLocalizedString(@"The email and password you entered is invalid. Please try again.", nil);
    } else {
        failureReason = NSLocalizedString(@"The username and password you entered is invalid. Please try again.", nil);
    }
    return [self errorWithCode:A0ErrorCodeInvalidCredentials
                   description:NSLocalizedString(@"Invalid credentials", nil)
                 failureReason:failureReason];
}

+ (NSError *)invalidChangePasswordUsernameUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = NSLocalizedString(@"The email you entered is invalid. Please try again.", nil);
    } else {
        failureReason = NSLocalizedString(@"The username you entered is invalid. Please try again.", nil);
    }
    return [self errorWithCode:A0ErrorCodeInvalidUsername
                   description:NSLocalizedString(@"Invalid credentials", nil)
                 failureReason:failureReason];
}

+ (NSError *)invalidChangePasswordPassword {
    return [self errorWithCode:A0ErrorCodeInvalidPassword
                   description:NSLocalizedString(@"Invalid credentials", nil)
                 failureReason:NSLocalizedString(@"The password you entered is invalid. Please try again.", nil)];
}

+ (NSError *)invalidChangePasswordRepeatPassword {
    return [self errorWithCode:A0ErrorCodeInvalidRepeatPassword
                   description:NSLocalizedString(@"Invalid credentials", nil)
                 failureReason:NSLocalizedString(@"The passwords you entered must match. Please try again.", nil)];
}

+ (NSError *)invalidChangePasswordRepeatPasswordAndPassword {
    return [self errorWithCode:A0ErrorCodeInvalidPasswordAndRepeatPassword
                   description:NSLocalizedString(@"Invalid credentials", nil)
                 failureReason:NSLocalizedString(@"The passwords you entered must match. Please try again.", nil)];
}

#pragma mark - Utility methods

+ (NSError *)errorWithCode:(NSInteger)code description:(NSString *)description failureReason:(NSString *)failureReason {
    NSError *error = [NSError errorWithDomain:A0ErrorDomain
                                         code:code
                                     userInfo:@{
                                                NSLocalizedDescriptionKey: description,
                                                NSLocalizedFailureReasonErrorKey: failureReason,
                                                }];
    return error;
}

@end
