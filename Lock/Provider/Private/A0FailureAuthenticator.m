// A0FailureAuthenticator.m
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

#import "A0FailureAuthenticator.h"
#import "Constants.h"
#import "A0Errors.h"

@interface A0FailureAuthenticator ()
@property (copy, nonatomic) NSString *connectionName;
@end

@implementation A0FailureAuthenticator

- (instancetype)initWithConnectionName:(NSString *)connectionName {
    self = [super init];
    if (self) {
        _connectionName = [connectionName copy];
    }
    return self;
}

#pragma mark - A0AuthenticationProvider

- (NSString *)identifier {
    return self.connectionName;
}

- (void)authenticateWithParameters:(A0AuthParameters *)parameters success:(A0IdPAuthenticationBlock)success failure:(A0IdPAuthenticationErrorBlock)failure {
    A0LogWarn(@"No known provider for connection %@", self.connectionName);
    if (failure) {
        failure([A0Errors unkownProviderForConnectionName:self.connectionName]);
    }
}

- (void)clearSessions {}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    return NO;
}

- (void)applicationLaunchedWithOptions:(NSDictionary *)launchOptions {}

@end
