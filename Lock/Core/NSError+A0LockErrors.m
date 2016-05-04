// NSError+A0LockErrors.m
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

#import "NSError+A0LockErrors.h"
#import "A0ErrorCode.h"
#import "A0GenericAPIErrorHandler.h"
#import "A0RuleErrorHandler.h"
#import "Constants.h"
#import "A0PasswordStrengthErrorHandler.h"

NSString * const A0ErrorDomain = @"com.auth0";

@implementation NSError (A0LockErrors)

- (BOOL)a0_auth0ErrorWithCode:(A0ErrorCode)code {
    return [self.domain isEqualToString:A0ErrorDomain] && self.code == code;
}

- (BOOL)a0_cancelledSocialAuthenticationError {
    return self.code == A0ErrorCodeFacebookCancelled
    || self.code == A0ErrorCodeTwitterCancelled
    || self.code == A0ErrorCodeAuth0Cancelled
    || self.code == A0ErrorCodeGooglePlusCancelled;
}

#pragma mark - Localized error messages

- (NSString *)a0_localizedStringWithHandlers:(NSArray *)handlers defaultMessage:(NSString *)defaultMessage {
    __block NSString *message = nil;
    [handlers enumerateObjectsUsingBlock:^(id<A0ErrorHandler> handler, NSUInteger idx, BOOL *stop) {
        message = [handler localizedMessageFromError:self];
        *stop = message != nil;
    }];
    return message ?: defaultMessage;
}

- (NSString *)a0_localizedStringForLoginError {
    NSArray *handlers = @[
                          [A0GenericAPIErrorHandler handlerForErrorString:@"invalid_user_password" returnMessage:A0LocalizedString(@"Wrong email or password.")],
                          [A0GenericAPIErrorHandler handlerForErrorString:@"a0.mfa_invalid_code" returnMessage:A0LocalizedString(@"Invalid or expired verification code.")],
                          [A0RuleErrorHandler handler],
                          ];
    return [self a0_localizedStringWithHandlers:handlers defaultMessage:A0LocalizedString(@"There was an error processing the sign in.")];
}

- (NSString *)a0_localizedStringForPasswordlessSMSLoginError {
    NSArray *handlers = @[
                          [A0GenericAPIErrorHandler handlerForErrorString:@"invalid_user_password" returnMessage:A0LocalizedString(@"Wrong phone number or passcode.")],
                          [A0RuleErrorHandler handler],
                          ];
    return [self a0_localizedStringWithHandlers:handlers defaultMessage:A0LocalizedString(@"There was an error processing the sign in.")];
}

- (NSString *)a0_localizedStringForPasswordlessEmailLoginError {
    NSArray *handlers = @[
                          [A0GenericAPIErrorHandler handlerForErrorString:@"invalid_user_password" returnMessage:A0LocalizedString(@"Wrong email or passcode.")],
                          [A0RuleErrorHandler handler],
                          ];
    return [self a0_localizedStringWithHandlers:handlers defaultMessage:A0LocalizedString(@"There was an error processing the sign in.")];
}

- (NSString *)a0_localizedStringForSignUpError {
    NSArray *handlers = @[
                          [A0GenericAPIErrorHandler handlerForCodes:@[@"user_exists", @"username_exists"] returnMessage:A0LocalizedString(@"The user already exists.")],
                          [A0RuleErrorHandler handler],
                          [[A0PasswordStrengthErrorHandler alloc] init],
                          ];
    return [self a0_localizedStringWithHandlers:handlers defaultMessage:A0LocalizedString(@"There was an error processing the sign up.")];
}

- (NSString *)a0_localizedStringForChangePasswordError {
    return [self a0_localizedStringWithHandlers:@[] defaultMessage:A0LocalizedString(@"There was an error processing the reset password.")];
}

- (NSString *)a0_localizedStringForSocialLoginError {
    NSArray *handlers = @[
                          [A0RuleErrorHandler handler],
                          ];
    return [self a0_localizedStringWithHandlers:handlers defaultMessage:A0LocalizedString(@"There was an error processing the sign in.")];
}

- (NSString *)a0_localizedStringErrorForConnectionName:(NSString *)connectionName {
    NSString *connectionScopeMessage = [NSString stringWithFormat:@"The scopes for the connection %@ are invalid, please check your configuration in Auth0 Dashboard.", connectionName];
    NSArray *handlers = @[
                          [A0GenericAPIErrorHandler handlerForErrorString:@"access_denied" returnMessage:A0LocalizedString(@"Permissions were not granted. Try again")],
                          [A0GenericAPIErrorHandler handlerForErrorString:@"invalid_scope" returnMessage:A0LocalizedString(connectionScopeMessage)],
                          [A0RuleErrorHandler handler],
                          ];
    return [self a0_localizedStringWithHandlers:handlers defaultMessage:A0LocalizedString(@"There was an error processing the sign in.")];
}

@end
