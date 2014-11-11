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

@class A0UserProfile, A0Token, A0AuthParameters;

typedef void(^A0AuthenticationBlock)(A0UserProfile *profile, A0Token *token);

/**
 `A0LockViewController` displays Auth0's native widget and configures itself with your app's configuration and it allows further customization using it's properties or `A0Theme`.
  It should be presented in screen as a modal view controller calling in any of your controllers `[self presentViewController:authController animated:YES completion:nil]`
 */
@interface A0LockViewController : A0ContainerViewController

/**
 Block that is called on successful authentication. It has two parameters profile and token, which will be non-nil unless login is disabled after signup.
 */
@property (copy, nonatomic) A0AuthenticationBlock onAuthenticationBlock;

/**
 Block that is called on when the user dismisses the Login screen. Only when closable property is YES.
 */
@property (copy, nonatomic) void(^onUserDismissBlock)();

/**
 Enable the username to be treated as an email (and validated as one too) in all Auth0 screens. Default is YES
 */
@property (assign, nonatomic) BOOL usesEmail;

/**
 Allows the A0AuthenticationViewController to be dismissed by adding a button. Default is NO
 */
@property (assign, nonatomic) BOOL closable;

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
 View that will appear in the bottom of Signup screen. It should be used to show Terms & Conditions of your app.
 */
@property (strong, nonatomic) UIView *signUpDisclaimerView;

/**
 *  When authenticating with a social connection, it will use an embedded webView instead of Safari. Default is NO.
 */
@property (assign, nonatomic) BOOL useWebView;

/**
 *  Parameters to be sent to all Authentication request to Auth0 API.
 *  @see A0AuthParameters
 */
@property (strong, nonatomic) A0AuthParameters *authenticationParameters;

@end