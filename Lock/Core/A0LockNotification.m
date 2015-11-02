// A0LockNotification.m
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

#import "A0LockNotification.h"

NSString * const A0LockNotificationLoginSuccessful = @"A0LockNotificationLoginSuccessful";
NSString * const A0LockNotificationLoginFailed = @"A0LockNotificationLoginFailed";

NSString * const A0LockNotificationSignUpSuccessful = @"A0LockNotificationSignUpSuccessful";
NSString * const A0LockNotificationSignUpFailed = @"A0LockNotificationSignUpFailed";

NSString * const A0LockNotificationChangePasswordSuccessful = @"A0LockNotificationChangePasswordSuccessful";
NSString * const A0LockNotificationChangePasswordFailed = @"A0LockNotificationChangePasswordFailed";

NSString * const A0LockNotificationLockDismissed = @"A0LockNotificationLockDismissed";

NSString * const A0LockNotificationErrorParameterKey = @"A0LockNotificationErrorParameterKey";
NSString * const A0LockNotificationEmailParameterKey = @"A0LockNotificationEmailParameterKey";
NSString * const A0LockNotificationConnectionParameterKey = @"A0LockNotificationConnectionParameterKey";

NSString * const A0LockNotificationUniversalLinkReceived = @"com.auth0.universal-link.received";
NSString * const A0LockNotificationUniversalLinkParameterKey = @"com.auth0.universal-link.url";