// A0LockNotification.h
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

#ifndef A0LockNotification_h
#define A0LockNotification_h

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * const A0LockNotificationLoginSuccessful;
FOUNDATION_EXPORT NSString * const A0LockNotificationLoginFailed;

FOUNDATION_EXPORT NSString * const A0LockNotificationSignUpSuccessful;
FOUNDATION_EXPORT NSString * const A0LockNotificationSignUpFailed;

FOUNDATION_EXPORT NSString * const A0LockNotificationChangePasswordSuccessful;
FOUNDATION_EXPORT NSString * const A0LockNotificationChangePasswordFailed;

FOUNDATION_EXPORT NSString * const A0LockNotificationLockDismissed;


FOUNDATION_EXPORT NSString * const A0LockNotificationErrorParameterKey;
FOUNDATION_EXPORT NSString * const A0LockNotificationEmailParameterKey;
FOUNDATION_EXPORT NSString * const A0LockNotificationConnectionParameterKey;

FOUNDATION_EXPORT NSString * const A0LockNotificationUniversalLinkReceived;
FOUNDATION_EXPORT NSString * const A0LockNotificationUniversalLinkParameterKey;
#endif
