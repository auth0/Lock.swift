// UIViewController+LockNotification.m
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

#import "UIViewController+LockNotification.h"
#import "A0LockNotification.h"
#import "A0APIClient.h"
#import "A0Application.h"
#import "A0Strategy.h"
#import "A0Connection.h"
#import "A0AuthParameters.h"
#import "A0Lock.h"
#import "NSObject+A0APIClientProvider.h"

@implementation UIViewController (LockNotification)

- (void)postLoginErrorNotificationWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationLoginFailed
                                                        object:nil
                                                      userInfo:@{
                                                                 A0LockNotificationErrorParameterKey: error,
                                                                 }];
}

- (void)postLoginSuccessfulWithUsername:(NSString *)username andParameters:(A0AuthParameters *)parameters {
    NSString *connectionName;
    if ([self respondsToSelector:@selector(lock)]) {
        A0Lock *lock = [self performSelector:@selector(lock)];
        A0APIClient *client = [self a0_apiClientFromProvider:lock];
        connectionName = parameters[@"connection"] ?: client.application.databaseStrategy.connections.firstObject;
    }

    [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationLoginSuccessful
                                                        object:nil
                                                      userInfo:@{
                                                                 A0LockNotificationConnectionParameterKey: connectionName ?: @"Username-Password-Authentication",
                                                                 A0LockNotificationEmailParameterKey: username,
                                                                 }];
}

- (void)postLoginSuccessfulForConnection:(A0Connection *)connection {
    [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationLoginSuccessful
                                                        object:nil
                                                      userInfo:@{
                                                                 A0LockNotificationConnectionParameterKey: connection.name,
                                                                 }];
}

- (void)postSignUpSuccessfulWithEmail:(NSString *)email {
    [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationSignUpSuccessful
                                                        object:nil
                                                      userInfo:@{
                                                                 A0LockNotificationEmailParameterKey: email,
                                                                 }];
}

- (void)postSignUpErrorNotificationWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationSignUpFailed
                                                        object:nil
                                                      userInfo:@{
                                                                 A0LockNotificationErrorParameterKey: error,
                                                                 }];
}

- (void)postChangePasswordSuccessfulWithEmail:(NSString *)email {
    [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationChangePasswordSuccessful
                                                        object:nil
                                                      userInfo:@{
                                                                 A0LockNotificationEmailParameterKey: email,
                                                                 }];
}

- (void)postChangePasswordErrorNotificationWithError:(NSError *)error {
    [[NSNotificationCenter defaultCenter] postNotificationName:A0LockNotificationChangePasswordFailed
                                                        object:nil
                                                      userInfo:@{
                                                                 A0LockNotificationErrorParameterKey: error,
                                                                 }];
}
@end
