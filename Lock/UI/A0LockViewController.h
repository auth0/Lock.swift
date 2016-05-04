//  A0LockViewController.h
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

#import <UIKit/UIKit.h>
#import "A0ContainerViewController.h"
#import "A0LockEventDelegate.h"

@class A0UserProfile, A0Token, A0AuthParameters, A0Lock;

typedef void(^A0AuthenticationBlock)(A0UserProfile * __nullable profile, A0Token * __nullable token);

NS_ASSUME_NONNULL_BEGIN
/**
 `A0LockViewController` displays Auth0's native widget and configures itself with your app's configuration and it allows further customization using it's properties or `A0Theme`.
  It should be presented in screen as a modal view controller calling in any of your controllers `[self presentViewController:authController animated:YES completion:nil]`
 */
@interface A0LockViewController : A0ContainerViewController

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

///------------------------------------------------
/// @name Callbacks
///------------------------------------------------

/**
 Block that is called on successful authentication. It has two parameters profile and token, which will be non-nil unless login is disabled after signup.
 */
@property (copy, nullable, nonatomic) A0AuthenticationBlock onAuthenticationBlock;

/**
 Block that is called on when the user dismisses the Login screen. Only when closable property is YES.
 */
@property (copy, nullable, nonatomic) void(^onUserDismissBlock)();

///------------------------------------------------
/// @name UI customization
///------------------------------------------------

/**
 Enable the username to be treated as an email (and validated as one too) in all Auth0 screens. Default is YES
 */
@property (assign, nonatomic) BOOL usesEmail;

/**
 Allows the A0AuthenticationViewController to be dismissed by adding a button. Default is NO
 */
@property (assign, nonatomic) BOOL closable;

/**
 View that will appear in the bottom of Signup screen. It should be used to show Terms & Conditions of your app.
 */
@property (strong, nullable, nonatomic) UIView *signUpDisclaimerView;

/**
 * Hides the Sign Up button. By default is `false`.
 */
@property (assign, nonatomic) BOOL disableSignUp;

/**
 * Hides the Reset Password button. By default is `false`.
 */
@property (assign, nonatomic) BOOL disableResetPassword;

/**
 *  Hook to use a custom UIViewController for SignUp. By default is nil.
 *  The block will receive two parameters:
 *  - `A0Lock` instance of the displayed `A0LockViewController`
 *  - an instance of `A0LockEventDelegate` used to interact with `A0LockViewController`, e.g. to go back to Lock UI.
 */
@property (copy, nullable, nonatomic) UIViewController *(^customSignUp)(A0Lock *lock, A0LockEventDelegate *delegate);

///------------------------------------------------
/// @name Authentication options
///------------------------------------------------

/**
 *  Default value for identifier field (if available). Default is nil
 */
@property (copy, nullable, nonatomic) NSString *defaultIdentifier;

/**
 After a successful Signup, `A0AuthenticationViewController` will attempt to login the user if this property is YES otherwise will call onAuthenticationBlock with both parameters nil. Default value is YES
 */
@property (assign, nonatomic) BOOL loginAfterSignUp;

/**
 *  When an email matches an Active Directory connection domain, it will use the email's local part as the username in the AD login form. 
 *  For example: when entering 'user@auth0.com' the username field will have 'user'.
 *  Default is YES.
 */
@property (assign, nonatomic) BOOL defaultADUsernameFromEmailPrefix;

/**
 *  When authenticating with a social connection, it will use an embedded webView instead of Safari. Default is YES.
 */
@property (assign, nonatomic) BOOL useWebView;

/**
 *  Parameters to be sent to all Authentication request to Auth0 API.
 *  @see A0AuthParameters
 */
@property (copy, nullable, nonatomic) A0AuthParameters *authenticationParameters;

/**
 *  List of enterprise connection names that should always use web form to login.
 *  By default all ADFS, AD & WAAD connections will use native form to login unless added to this array.
 */
@property (copy, nullable, nonatomic) NSArray<NSString *> *enterpriseConnectionsUsingWebForm;

///------------------------------------------------
/// @name Connection filtering
///------------------------------------------------

/**
 *  List of connections to be used by Lock. 
 *  It can be used to filter connections already enabled in Auth0 dashboard. If a connection is not enabled in the dashboard it will be ignored.
 */
@property (copy, nullable, nonatomic) NSArray *connections;

/**
 *  Name of the DB connection that should be used by Lock. By default is nil, which means the first connection will be used.
 */
@property (copy, nullable, nonatomic) NSString *defaultDatabaseConnectionName;

@end
NS_ASSUME_NONNULL_END