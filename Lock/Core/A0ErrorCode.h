// A0ErrorCode.h
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

#ifndef Pods_A0ErrorCode_h
#define Pods_A0ErrorCode_h

typedef NS_ENUM(NSInteger, A0ErrorCode) {
    A0ErrorCodeAuthenticationFailed = 0,
    /**
     *  Both password and email/username are invalid
     */
    A0ErrorCodeInvalidCredentials,
    /**
     *  Username is invalid
     */
    A0ErrorCodeInvalidUsername,
    /**
     *  Email is invalid.
     */
    A0ErrorCodeInvalidEmail,
    /**
     *  Password is invalid
     */
    A0ErrorCodeInvalidPassword,
    /**
     *  Phone number is invalid
     */
    A0ErrorCodeInvalidPhoneNumber,
    /**
     *  Repeat password is invalid (empty or doesnt match password)
     */
    A0ErrorCodeInvalidRepeatPassword,
    /**
     *  Both password and repeat password are invalid
     */
    A0ErrorCodeInvalidPasswordAndRepeatPassword,
    /**
     *  User cancelled facebook auth flow (Safari or Native)
     */
    A0ErrorCodeFacebookCancelled,
    /**
     *  User didn't authorize twitter app for authentication
     */
    A0ErrorCodeTwitterAppNotAuthorized,
    /**
     *  User cancelled twitter auth flow (Safari or Native)
     */
    A0ErrorCodeTwitterCancelled,
    /**
     *  Twitter is not configured in Auth0 Dashboard
     */
    A0ErrorCodeTwitterNotConfigured,
    /**
     *  Twitter account in iOS is invalid (e.g: password changed). It must be reentered in iOS Settings.
     */
    A0ErrorCodeTwitterInvalidAccount,
    /**
     *  Strategy is not found in A0Application. Please check if it's enabled in Auth0 Dashboard
     */
    A0ErrorCodeUknownProviderForStrategy,
    /**
     *  Safari/WebView auth flow was cancelled by the user
     */
    A0ErrorCodeAuth0Cancelled,
    /**
     *  User didn't authorize the app during Safari/WebView auth flow.
     */
    A0ErrorCodeAuth0NotAuthorized,
    /**
     *  Auth0 connection was not configured properly in Dashboard.
     */
    A0ErrorCodeAuth0InvalidConfiguration,
    /**
     *  iOS custom scheme for Auth0 was not registered in Info plist file.
     */
    A0ErrorCodeAuth0NoURLSchemeFound,
    /**
     *  Authentication parameters didn't contain a valid connection name.
     */
    A0ErrorCodeNoConnectionNameFound,
    /**
     *  When device is not connected to internet.
     */
    A0ErrorCodeNotConnectedToInternet,
    /**
     *  When Google+ authentication fails
     */
    A0ErrorCodeGooglePlusFailed,
    /**
     *  When Google+ authentication was cancelled by the user.
     */
    A0ErrorCodeGooglePlusCancelled,
    /**
     *  When Auth0 App information cannot be retrieved from configuration URL.
     */
    A0ErrorCodeConfigurationLoadFailed,
};

#endif
