// A0ChangePasswordCredentialValidator.m
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
