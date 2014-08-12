// A0Errors.m
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

#import "A0Errors.h"

NSString * const A0ErrorDomain = @"com.auth0";
NSString * const A0JSONResponseSerializerErrorDataKey = @"A0JSONResponseSerializerErrorDataKey";

@implementation A0Errors

#pragma mark - Login errors

+ (NSError *)invalidLoginCredentialsUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = NSLocalizedString(@"The email and password you entered are invalid. Please try again.", nil);
    } else {
        failureReason = NSLocalizedString(@"The username and password you entered are invalid. Please try again.", nil);
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
        failureReason = NSLocalizedString(@"The email and password you entered are invalid. Please try again.", nil);
    } else {
        failureReason = NSLocalizedString(@"The username and password you entered are invalid. Please try again.", nil);
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
        failureReason = NSLocalizedString(@"The email and password you entered are invalid. Please try again.", nil);
    } else {
        failureReason = NSLocalizedString(@"The username and password you entered are invalid. Please try again.", nil);
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

#pragma mark - Social Errors

+ (NSError *)facebookCancelled {
    return [self errorWithCode:A0ErrorCodeFacebookCancelled
                   description:NSLocalizedString(@"There was an error contacting Facebook", nil)
                 failureReason:NSLocalizedString(@"You need to authorize the application", nil)];
}

+ (NSError *)twitterAppNotAuthorized {
    return [self errorWithCode:A0ErrorCodeTwitterAppNotAuthorized
                   description:NSLocalizedString(@"There was an error contacting Twitter", nil)
                 failureReason:NSLocalizedString(@"Permissions were not granted. Please authorize the app in Settings > Twitter", nil)];
}

+ (NSError *)twitterAppOauthNotAuthorized {
    return [self errorWithCode:A0ErrorCodeTwitterAppNotAuthorized
                   description:NSLocalizedString(@"There was an error contacting Twitter", nil)
                 failureReason:NSLocalizedString(@"Permissions were not granted. Try again", nil)];
}

+ (NSError *)twitterCancelled {
    return [self errorWithCode:A0ErrorCodeTwitterCancelled
                   description:NSLocalizedString(@"There was an error contacting Twitter", nil)
                 failureReason:NSLocalizedString(@"User cancelled the login operation. Try again", nil)];
}

+ (NSError *)twitterNotConfigured {
    return [self errorWithCode:A0ErrorCodeTwitterNotConfigured
                   description:NSLocalizedString(@"There was an error contacting Twitter", nil)
                 failureReason:NSLocalizedString(@"The domain has not been setup for Twitter.", nil)];
}

+ (NSError *)twitterInvalidAccount {
    return [self errorWithCode:A0ErrorCodeTwitterInvalidAccount
                   description:NSLocalizedString(@"There was an error contacting Twitter", nil)
                 failureReason:NSLocalizedString(@"The twitter account seems to be invalid. Please check it in Settings > Twitter and re-enter them.", nil)];
}

#pragma mark - Localized error messages

+ (NSString *)localizedStringForLoginError:(NSError *)error {
    NSDictionary *apiErrorInfo = error.userInfo[A0JSONResponseSerializerErrorDataKey];
    NSString *errorKey = apiErrorInfo[@"error"];
    NSString *localizedString;
    if ([errorKey isEqualToString:@"invalid_user_password"]) {
        localizedString = NSLocalizedString(@"Wrong email or password.", nil);
    } else {
        localizedString = NSLocalizedString(@"There was an error processing the sign in.", nil);
    }
    return localizedString;
}

+ (NSString *)localizedStringForSignUpError:(NSError *)error {
    NSDictionary *apiErrorInfo = error.userInfo[A0JSONResponseSerializerErrorDataKey];
    NSString *errorKey = apiErrorInfo[@"code"];
    NSString *localizedString;
    if ([errorKey isEqualToString:@"user_exists"]) {
        localizedString = NSLocalizedString(@"The user already exists.", nil);
    } else {
        localizedString = NSLocalizedString(@"There was an error processing the sign up.", nil);
    }
    return localizedString;
}

+ (NSString *)localizedStringForChangePasswordError:(NSError *)error {
    return NSLocalizedString(@"There was an error processing the reset password.", nil);
}

+ (NSString *)localizedStringForSocialLoginError:(NSError *)error {
    return NSLocalizedString(@"There was an error processing the sign in.", nil);
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
