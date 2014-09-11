//  A0AuthenticationViewController.h
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
#import "A0KeyboardEnabledView.h"

@class A0AuthenticationViewController, A0UserProfile, A0Token;

typedef void(^A0AuthenticationBlock)(A0UserProfile *profile, A0Token *token);

@interface A0AuthenticationViewController : UIViewController

@property (copy, nonatomic) A0AuthenticationBlock onAuthenticationBlock;
@property (copy, nonatomic) void(^onUserDismissBlock)();
@property (assign, nonatomic) BOOL usesEmail;
@property (assign, nonatomic) BOOL closable;
@property (assign, nonatomic) BOOL loginAfterSignUp;
@property (assign, nonatomic) NSArray *defaultScopes;
@property (strong, nonatomic) UIView *signUpDisclaimerView;

@end
