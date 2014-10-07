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

+ (NSError *)noConnectionNameFound {
    return [self errorWithCode:A0ErrorCodeNoConnectionNameFound
                   description:A0LocalizedString(@"Authentication failed")
                 failureReason:A0LocalizedString(@"Can't find connection name to use for authentication")];
}

#pragma mark - Login errors

+ (NSError *)invalidLoginCredentialsUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = A0LocalizedString(@"The email and password you entered are invalid. Please try again.");
    } else {
        failureReason = A0LocalizedString(@"The username and password you entered are invalid. Please try again.");
    }
    return [self errorWithCode:A0ErrorCodeInvalidCredentials
                   description:A0LocalizedString(@"Invalid login credentials")
                 failureReason:failureReason];
}

+ (NSError *)invalidLoginUsernameUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = A0LocalizedString(@"The email you entered is invalid. Please try again.");
    } else {
        failureReason = A0LocalizedString(@"The username you entered is invalid. Please try again.");
    }
    return [self errorWithCode:A0ErrorCodeInvalidUsername
                   description:A0LocalizedString(@"Invalid login credentials")
                 failureReason:failureReason];
}

+ (NSError *)invalidLoginPassword {
    return [self errorWithCode:A0ErrorCodeInvalidPassword
                   description:A0LocalizedString(@"Invalid login credentials")
                 failureReason:A0LocalizedString(@"The password you entered is invalid. Please try again.")];
}

#pragma mark - SignUp errors

+ (NSError *)invalidSignUpCredentialsUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = A0LocalizedString(@"The email and password you entered are invalid. Please try again.");
    } else {
        failureReason = A0LocalizedString(@"The username and password you entered are invalid. Please try again.");
    }
    return [self errorWithCode:A0ErrorCodeInvalidCredentials
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:failureReason];
}

+ (NSError *)invalidSignUpUsernameUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = A0LocalizedString(@"The email you entered is invalid. Please try again.");
    } else {
        failureReason = A0LocalizedString(@"The username you entered is invalid. Please try again.");
    }
    return [self errorWithCode:A0ErrorCodeInvalidUsername
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:failureReason];
}

+ (NSError *)invalidSignUpPassword {
    return [self errorWithCode:A0ErrorCodeInvalidPassword
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:A0LocalizedString(@"The password you entered is invalid. Please try again.")];
}

#pragma mark - Change password errors

+ (NSError *)invalidChangePasswordCredentialsUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = A0LocalizedString(@"The email and password you entered are invalid. Please try again.");
    } else {
        failureReason = A0LocalizedString(@"The username and password you entered are invalid. Please try again.");
    }
    return [self errorWithCode:A0ErrorCodeInvalidCredentials
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:failureReason];
}

+ (NSError *)invalidChangePasswordUsernameUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = A0LocalizedString(@"The email you entered is invalid. Please try again.");
    } else {
        failureReason = A0LocalizedString(@"The username you entered is invalid. Please try again.");
    }
    return [self errorWithCode:A0ErrorCodeInvalidUsername
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:failureReason];
}

+ (NSError *)invalidChangePasswordPassword {
    return [self errorWithCode:A0ErrorCodeInvalidPassword
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:A0LocalizedString(@"The password you entered is invalid. Please try again.")];
}

+ (NSError *)invalidChangePasswordRepeatPassword {
    return [self errorWithCode:A0ErrorCodeInvalidRepeatPassword
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:A0LocalizedString(@"The passwords you entered must match. Please try again.")];
}

+ (NSError *)invalidChangePasswordRepeatPasswordAndPassword {
    return [self errorWithCode:A0ErrorCodeInvalidPasswordAndRepeatPassword
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:A0LocalizedString(@"The passwords you entered must match. Please try again.")];
}

#pragma mark - Social Errors

+ (NSError *)urlSchemeNotRegistered {
    return [self errorWithCode:A0ErrorCodeAuth0NoURLSchemeFound
                   description:A0LocalizedString(@"Couldn't start authentication using Safari")
                 failureReason:A0LocalizedString(@"You need to configure your auth0 scheme in CFBundleURLTypes in your app's Info.plist file")];
}

+ (NSError *)unkownProviderForStrategy:(NSString *)strategyName {
    return [self errorWithCode:A0ErrorCodeUknownProviderForStrategy
                   description:A0LocalizedString(@"Couldn't found authentication method for unknown strategy")
                 failureReason:[NSString stringWithFormat:A0LocalizedString(@"The strategy %@ has no registered authentication provider"), strategyName]];
}

+ (NSError *)facebookCancelled {
    return [self errorWithCode:A0ErrorCodeFacebookCancelled
                   description:A0LocalizedString(@"There was an error contacting Facebook")
                 failureReason:A0LocalizedString(@"You need to authorize the application")];
}

+ (NSError *)twitterAppNotAuthorized {
    return [self errorWithCode:A0ErrorCodeTwitterAppNotAuthorized
                   description:A0LocalizedString(@"There was an error contacting Twitter")
                 failureReason:A0LocalizedString(@"Permissions were not granted. Please authorize the app in Settings > Twitter")];
}

+ (NSError *)twitterAppOauthNotAuthorized {
    return [self errorWithCode:A0ErrorCodeTwitterAppNotAuthorized
                   description:A0LocalizedString(@"There was an error contacting Twitter")
                 failureReason:A0LocalizedString(@"Permissions were not granted. Try again")];
}

+ (NSError *)twitterCancelled {
    return [self errorWithCode:A0ErrorCodeTwitterCancelled
                   description:A0LocalizedString(@"There was an error contacting Twitter")
                 failureReason:A0LocalizedString(@"User cancelled the login operation. Try again")];
}

+ (NSError *)twitterNotConfigured {
    return [self errorWithCode:A0ErrorCodeTwitterNotConfigured
                   description:A0LocalizedString(@"There was an error contacting Twitter")
                 failureReason:A0LocalizedString(@"The domain has not been setup for Twitter.")];
}

+ (NSError *)twitterInvalidAccount {
    return [self errorWithCode:A0ErrorCodeTwitterInvalidAccount
                   description:A0LocalizedString(@"There was an error contacting Twitter")
                 failureReason:A0LocalizedString(@"The twitter account seems to be invalid. Please check it in Settings > Twitter and re-enter them.")];
}

+ (NSError *)auth0CancelledForStrategy:(NSString *)strategyName {
    NSString *description = [NSString stringWithFormat:@"There was an error contacting %@", strategyName];
    return [self errorWithCode:A0ErrorCodeAuth0Cancelled
                   description:A0LocalizedString(description)
                 failureReason:A0LocalizedString(@"User cancelled the login operation. Try again")];
}

+ (NSError *)auth0NotAuthorizedForStrategy:(NSString *)strategyName {
    NSString *description = [NSString stringWithFormat:@"There was an error contacting %@", strategyName];
    return [self errorWithCode:A0ErrorCodeAuth0NotAuthorized
                   description:A0LocalizedString(description)
                 failureReason:A0LocalizedString(@"Permissions were not granted. Try again")];
}

+ (NSError *)auth0InvalidConfigurationForStrategy:(NSString *)strategyName {
    NSString *description = [NSString stringWithFormat:@"There was an error contacting %@", strategyName];
    NSString *failureReason = [NSString stringWithFormat:@"The application isn't configured properly for %@. Please check your Auth0's application configuration", strategyName];
    return [self errorWithCode:A0ErrorCodeAuth0InvalidConfiguration
                   description:A0LocalizedString(description)
                 failureReason:A0LocalizedString(failureReason)];
}

#pragma mark - Localized error messages

+ (NSString *)localizedStringForLoginError:(NSError *)error {
    NSDictionary *apiErrorInfo = error.userInfo[A0JSONResponseSerializerErrorDataKey];
    NSString *errorKey = apiErrorInfo[@"error"];
    NSString *localizedString;
    if ([errorKey isEqualToString:@"invalid_user_password"]) {
        localizedString = A0LocalizedString(@"Wrong email or password.");
    } else {
        localizedString = A0LocalizedString(@"There was an error processing the sign in.");
    }
    return localizedString;
}

+ (NSString *)localizedStringForSignUpError:(NSError *)error {
    NSDictionary *apiErrorInfo = error.userInfo[A0JSONResponseSerializerErrorDataKey];
    NSString *errorKey = apiErrorInfo[@"code"];
    NSString *localizedString;
    if ([errorKey isEqualToString:@"user_exists"]) {
        localizedString = A0LocalizedString(@"The user already exists.");
    } else {
        localizedString = A0LocalizedString(@"There was an error processing the sign up.");
    }
    return localizedString;
}

+ (NSString *)localizedStringForChangePasswordError:(NSError *)error {
    return A0LocalizedString(@"There was an error processing the reset password.");
}

+ (NSString *)localizedStringForSocialLoginError:(NSError *)error {
    return A0LocalizedString(@"There was an error processing the sign in.");
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
