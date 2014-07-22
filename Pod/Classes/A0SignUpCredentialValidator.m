//
//  A0SignUpCredentialValidator.m
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

#import "A0SignUpCredentialValidator.h"
#import "A0BasicValidator.h"
#import "A0Errors.h"

@interface A0SignUpCredentialValidator ()

@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;

@end

@implementation A0SignUpCredentialValidator

- (void)setUsername:(NSString *)username password:(NSString *)password {
    self.username = username;
    self.password = password;
}

- (BOOL)validateCredential:(NSError **)error {
    BOOL validUsername = [self validateUsername:self.username];
    BOOL validPassword = [self validatePassword:self.password];
    if (!validUsername && !validPassword) {
        *error = [A0Errors invalidSignUpCredentialsUsingEmail:self.usesEmail];
    }
    if (validUsername && !validPassword) {
        *error = [A0Errors invalidSignUpPassword];
    }
    if (!validUsername && validPassword) {
        *error = [A0Errors invalidSignUpUsernameUsingEmail:self.usesEmail];
    }
    return validUsername && validPassword;
}
@end
