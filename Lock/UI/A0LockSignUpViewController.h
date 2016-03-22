// A0LockSignUpViewController.h
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

#import <UIKit/UIKit.h>
#import "A0ContainerViewController.h"

@class A0AuthParameters, A0UserProfile, A0Token, A0Lock;

@interface A0LockSignUpViewController : UIViewController

/**
 *  Initialize a new instance of the ViewController
 *
 *  @param lock an instance of Lock configured for an Auth0 application
 *  @return an initialized instance.
 *  @see A0Lock
 */
- (instancetype)initWithLock:(A0Lock *)lock;

/**
 *  Initialize a new instance of the ViewController
 *
 *  @return an initialized instance.
 *  @deprecated 1.12.0. Please use `initWithLock:` or create using an `A0Lock` instance
 *  @see A0Lock
 */
- (instancetype)init DEPRECATED_ATTRIBUTE;

/**
 Block that is called on successful authentication. It has two parameters profile and token, which will be non-nil unless login is disabled after signup.
 */
@property (copy, nonatomic) void(^onAuthenticationBlock)(A0UserProfile *, A0Token *) ;

/**
 Block that is called on when the user dismisses the Login screen. Only when closable property is YES.
 */
@property (copy, nonatomic) void(^onUserDismissBlock)();

/**
 After a successful Signup, `A0AuthenticationViewController` will attempt to login the user if this property is YES otherwise will call onAuthenticationBlock with both parameters nil. Default value is YES
 */
@property (assign, nonatomic) BOOL loginAfterSignUp;

/**
 *  When authenticating with a social connection, it will use an embedded webView instead of Safari. Default is NO.
 */
@property (assign, nonatomic) BOOL useWebView;

/**
 *  Parameters to be sent to all Authentication request to Auth0 API.
 *  @see A0AuthParameters
 */
@property (strong, nonatomic) A0AuthParameters *authenticationParameters;

/**
 *  List of connections to be used by Lock.
 *  It can be used to filter connections already enabled in Auth0 dashboard. If a connection is not enabled in the dashboard it will be ignored.
 */
@property (strong, nonatomic) NSArray *connections;

/**
 *  Name of the DB connection that should be used by Lock. By default is nil, which means the first connection will be used.
 */
@property (copy, nonatomic) NSString *defaultDatabaseConnectionName;

@end
