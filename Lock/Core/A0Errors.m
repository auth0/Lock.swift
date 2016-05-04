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
#import "NSError+A0APIError.h"
#import "A0GenericAPIErrorHandler.h"
#import "A0RuleErrorHandler.h"
#import "A0PasswordStrengthErrorHandler.h"
#import "Constants.h"
#import "NSError+A0LockErrors.h"

@implementation A0Errors

+ (NSError *)noConnectionNameFound {
    return [NSError errorWithCode:A0ErrorCodeNoConnectionNameFound
                      description:A0LocalizedString(@"Authentication failed")
                    failureReason:A0LocalizedString(@"Can't find connection name to use for authentication")];
}

+ (NSError *)notConnectedToInternetError {
    return [NSError errorWithCode:A0ErrorCodeNotConnectedToInternet
                      description:A0LocalizedString(@"The server could not be contacted")
                    failureReason:A0LocalizedString(@"Make sure your network settings are correct and your network connection is active, or try again later.")];
}

+ (NSError *)invalidUsername {
    return [NSError errorWithCode:A0ErrorCodeInvalidUsername
                      description:A0LocalizedString(@"Invalid credentials")
                    failureReason:A0LocalizedString(@"The username you entered is invalid. Please try again.")];
}

+ (NSError *)invalidEmail {
    return [NSError errorWithCode:A0ErrorCodeInvalidEmail
                      description:A0LocalizedString(@"Invalid credentials")
                    failureReason:A0LocalizedString(@"The email you entered is invalid. Please try again.")];
}

+ (NSError *)invalidPassword {
    return [NSError errorWithCode:A0ErrorCodeInvalidPassword
                      description:A0LocalizedString(@"Invalid credentials")
                    failureReason:A0LocalizedString(@"The password you entered is invalid. Please try again.")];
}

+ (NSError *)invalidRepeatPassword {
    return [NSError errorWithCode:A0ErrorCodeInvalidRepeatPassword
                      description:A0LocalizedString(@"Invalid credentials")
                    failureReason:A0LocalizedString(@"The passwords you entered must match. Please try again.")];
}

+ (NSError *)configurationLoadFailed {
    return [NSError errorWithCode:A0ErrorCodeConfigurationLoadFailed
                      description:A0LocalizedString(@"Failed to load Auth0 configuration")
                    failureReason:A0LocalizedString(@"Auth0 configuration for your app is not available. Please try again later.")];
}

+ (NSError *)invalidPhoneNumber {
    return [NSError errorWithCode:A0ErrorCodeInvalidPhoneNumber
                      description:A0LocalizedString(@"Invalid phone number")
                    failureReason:A0LocalizedString(@"You must enter a valid phone number")];
}

#pragma mark - Login errors

+ (NSError *)invalidLoginCredentialsUsingEmail:(BOOL)usesEmail {
    NSString *failureReason;
    if (usesEmail) {
        failureReason = A0LocalizedString(@"The email and password you entered are invalid. Please try again.");
    } else {
        failureReason = A0LocalizedString(@"The username and password you entered are invalid. Please try again.");
    }
    return [NSError errorWithCode:A0ErrorCodeInvalidCredentials
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
    return [NSError errorWithCode:A0ErrorCodeInvalidUsername
                      description:A0LocalizedString(@"Invalid login credentials")
                    failureReason:failureReason];
}

+ (NSError *)invalidLoginPassword {
    return [NSError errorWithCode:A0ErrorCodeInvalidPassword
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
    return [NSError errorWithCode:A0ErrorCodeInvalidCredentials
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
    return [NSError errorWithCode:A0ErrorCodeInvalidUsername
                      description:A0LocalizedString(@"Invalid credentials")
                    failureReason:failureReason];
}

+ (NSError *)invalidSignUpPassword {
    return [NSError errorWithCode:A0ErrorCodeInvalidPassword
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
    return [NSError errorWithCode:A0ErrorCodeInvalidCredentials
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
    return [NSError errorWithCode:A0ErrorCodeInvalidUsername
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:failureReason];
}

+ (NSError *)invalidChangePasswordPassword {
    return [NSError errorWithCode:A0ErrorCodeInvalidPassword
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:A0LocalizedString(@"The password you entered is invalid. Please try again.")];
}

+ (NSError *)invalidChangePasswordRepeatPassword {
    return [NSError errorWithCode:A0ErrorCodeInvalidRepeatPassword
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:A0LocalizedString(@"The passwords you entered must match. Please try again.")];
}

+ (NSError *)invalidChangePasswordRepeatPasswordAndPassword {
    return [NSError errorWithCode:A0ErrorCodeInvalidPasswordAndRepeatPassword
                   description:A0LocalizedString(@"Invalid credentials")
                 failureReason:A0LocalizedString(@"The passwords you entered must match. Please try again.")];
}

#pragma mark - Social Errors

+ (NSError *)failedLoginWithConnectionName:(NSString *)connectionName for:(NSError *)error {
    return [NSError errorWithCode:A0ErrorCodeAuthenticationFailed
                      description:A0LocalizedString(@"There was an error logging in")
                    failureReason:[error a0_localizedStringErrorForConnectionName:connectionName]];
}

+ (NSError *)urlSchemeNotRegistered {
    return [NSError errorWithCode:A0ErrorCodeAuth0NoURLSchemeFound
                   description:A0LocalizedString(@"Couldn't start authentication using Safari")
                 failureReason:A0LocalizedString(@"You need to configure your auth0 scheme in CFBundleURLTypes in your app's Info.plist file")];
}

+ (NSError *)unkownProviderForConnectionName:(NSString *)connectionName {
    return [NSError errorWithCode:A0ErrorCodeUknownProviderForStrategy
                   description:A0LocalizedString(@"Couldn't found authentication method for unknown connection")
                 failureReason:[NSString stringWithFormat:A0LocalizedString(@"The connection %@ has no registered authentication provider. Please register one or add 'Lock/WebView' subspec to use WebView by default."), connectionName]];
}

+ (NSError *)facebookCancelled {
    return [NSError errorWithCode:A0ErrorCodeFacebookCancelled
                   description:A0LocalizedString(@"There was an error contacting Facebook")
                 failureReason:A0LocalizedString(@"You need to authorize the application")];
}

+ (NSError *)twitterAppNotAuthorized {
    return [NSError errorWithCode:A0ErrorCodeTwitterAppNotAuthorized
                   description:A0LocalizedString(@"There was an error contacting Twitter")
                 failureReason:A0LocalizedString(@"Permissions were not granted. Please authorize the app in Settings > Twitter")];
}

+ (NSError *)twitterAppOauthNotAuthorized {
    return [NSError errorWithCode:A0ErrorCodeTwitterAppNotAuthorized
                   description:A0LocalizedString(@"There was an error contacting Twitter")
                 failureReason:A0LocalizedString(@"Permissions were not granted. Try again")];
}

+ (NSError *)twitterCancelled {
    return [NSError errorWithCode:A0ErrorCodeTwitterCancelled
                   description:A0LocalizedString(@"There was an error contacting Twitter")
                 failureReason:A0LocalizedString(@"User cancelled the login operation. Try again")];
}

+ (NSError *)twitterNotConfigured {
    return [NSError errorWithCode:A0ErrorCodeTwitterNotConfigured
                   description:A0LocalizedString(@"There was an error contacting Twitter")
                 failureReason:A0LocalizedString(@"The domain has not been setup for Twitter.")];
}

+ (NSError *)twitterInvalidAccount {
    return [NSError errorWithCode:A0ErrorCodeTwitterInvalidAccount
                   description:A0LocalizedString(@"There was an error contacting Twitter")
                 failureReason:A0LocalizedString(@"The twitter account seems to be invalid. Please check it in Settings > Twitter and re-enter them.")];
}

+ (NSError *)auth0CancelledForConnectionName:(NSString *)connectionName {
    NSString *description = [NSString stringWithFormat:@"There was an error contacting %@", connectionName];
    return [NSError errorWithCode:A0ErrorCodeAuth0Cancelled
                   description:A0LocalizedString(description)
                 failureReason:A0LocalizedString(@"User cancelled the login operation. Try again")];
}

+ (NSError *)auth0NotAuthorizedForConnectionName:(NSString *)connectionName {
    NSString *description = [NSString stringWithFormat:@"There was an error contacting %@", connectionName];
    return [NSError errorWithCode:A0ErrorCodeAuth0NotAuthorized
                   description:A0LocalizedString(description)
                 failureReason:A0LocalizedString(@"Permissions were not granted. Try again")];
}

+ (NSError *)auth0InvalidConfigurationForConnectionName:(NSString *)connectionName {
    NSString *description = [NSString stringWithFormat:@"There was an error contacting %@", connectionName];
    NSString *failureReason = [NSString stringWithFormat:@"The application isn't configured properly for %@. Please check your Auth0's application configuration", connectionName];
    return [NSError errorWithCode:A0ErrorCodeAuth0InvalidConfiguration
                   description:A0LocalizedString(description)
                 failureReason:A0LocalizedString(failureReason)];
}

+ (NSError *)googleplusFailed {
    return [NSError errorWithCode:A0ErrorCodeGooglePlusFailed
                   description:A0LocalizedString(@"There was an error contacting Google+")
                 failureReason:A0LocalizedString(@"Permissions were not granted. Try again")];
}

+ (NSError *)googleplusCancelled {
    return [NSError errorWithCode:A0ErrorCodeGooglePlusCancelled
                   description:A0LocalizedString(@"There was an error contacting Google+")
                 failureReason:A0LocalizedString(@"User cancelled the login operation. Try again")];
}

@end
