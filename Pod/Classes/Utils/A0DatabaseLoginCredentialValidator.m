//
//  A0DatabaseLoginCredentialValidator.m
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

#import "A0DatabaseLoginCredentialValidator.h"
#import "A0Errors.h"

@interface A0DatabaseLoginCredentialValidator ()

@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;
@end

@implementation A0DatabaseLoginCredentialValidator

- (void)setUsername:(NSString *)username password:(NSString *)password {
    self.username = username;
    self.password = password;
}

- (BOOL)validateCredential:(NSError **)error {
    BOOL validUsername = [self validateUsername:self.username];
    BOOL validPassword = [self validatePassword:self.password];
    if (!validUsername && !validPassword) {
        *error = [A0Errors invalidLoginCredentialsUsingEmail:self.usesEmail];
    }
    if (validUsername && !validPassword) {
        *error = [A0Errors invalidLoginPassword];
    }
    if (!validUsername && validPassword) {
        *error = [A0Errors invalidLoginUsernameUsingEmail:self.usesEmail];
    }
    return validUsername && validPassword;
}

@end
