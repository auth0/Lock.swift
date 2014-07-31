//
//  A0ChangePasswordCredentialValidator.m
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

#import "A0ChangePasswordCredentialValidator.h"
#import "A0Errors.h"

@interface A0ChangePasswordCredentialValidator ()

@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *repeatPassword;

@end

@implementation A0ChangePasswordCredentialValidator

- (void)setUsername:(NSString *)username password:(NSString *)password repeatPassword:(NSString *)repeatPassword {
    self.username = username;
    self.password = password;
    self.repeatPassword = repeatPassword;
}

- (BOOL)validateCredential:(NSError **)error {
    BOOL validUsername = [self validateUsername:self.username];
    BOOL validPassword = [self validatePassword:self.password];
    BOOL validRepeat = [self validatePassword:self.repeatPassword] && [self.password isEqualToString:self.repeatPassword];
    if (!validUsername && (!validPassword || !validRepeat)) {
        *error = [A0Errors invalidChangePasswordCredentialsUsingEmail:self.usesEmail];
    }
    if (validUsername && !validPassword && !validRepeat) {
        *error = [A0Errors invalidChangePasswordRepeatPasswordAndPassword];
    }
    if (validUsername && validPassword && !validRepeat) {
        *error = [A0Errors invalidChangePasswordRepeatPassword];
    }
    if (validUsername && !validPassword && validRepeat) {
        *error = [A0Errors invalidChangePasswordPassword];
    }
    if (!validUsername && validPassword && validRepeat) {
        *error = [A0Errors invalidChangePasswordUsernameUsingEmail:self.usesEmail];
    }
    return validUsername && validPassword && validRepeat;
}

@end
