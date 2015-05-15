// A0LockApplication.m
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

#import "A0LockApplication.h"

#import <Lock/Lock.h>

@implementation A0LockApplication

- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = [A0Lock newLock];
        A0TwitterAuthenticator *twitter = [A0TwitterAuthenticator newAuthenticatorWithKey:@""
                                                                                andSecret:@""];
        A0FacebookAuthenticator *facebook = [A0FacebookAuthenticator newAuthenticatorWithDefaultPermissions];
        NSString *googlePlusClientId = [[NSBundle mainBundle] infoDictionary][@"GooglePlusClientId"];
        A0GooglePlusAuthenticator *googleplus = [A0GooglePlusAuthenticator newAuthenticatorWithClientId:googlePlusClientId];
        [_lock registerAuthenticators:@[
                                        twitter,
                                        facebook,
                                        googleplus,
                                        ]];
    }
    return self;
}

+ (A0LockApplication *)sharedInstance {
    static A0LockApplication *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[A0LockApplication alloc] init];
    });
    return instance;
}
@end
