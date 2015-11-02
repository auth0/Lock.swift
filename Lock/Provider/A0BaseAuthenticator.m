// A0BaseAuthenticator.m
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

#import "A0BaseAuthenticator.h"

@implementation A0BaseAuthenticator

- (NSString *)identifier {
    [self raiseNotImplementedException];
    return nil;
}

- (BOOL)handleURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication {
    [self raiseNotImplementedException];
    return false;
}

- (void)applicationLaunchedWithOptions:(NSDictionary *)launchOptions {
}

- (void)authenticateWithParameters:(A0AuthParameters *)parameters success:(void (^)(A0UserProfile *, A0Token *))success failure:(void (^)(NSError *))failure {
    [self raiseNotImplementedException];
}

- (void)clearSessions {
    [self raiseNotImplementedException];
}

- (void)raiseNotImplementedException {
    [NSException raise:NSInternalInconsistencyException format:@"Method %s is not implemented", __PRETTY_FUNCTION__];
}
@end
