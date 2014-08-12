// A0DatabaseLoginCredentialValidator.m
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
