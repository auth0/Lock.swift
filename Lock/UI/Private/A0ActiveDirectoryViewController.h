//  A0ActiveDirectoryViewController.h
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
#import "A0AuthenticationUIComponent.h"
#import "A0ConnectionDomainMatcher.h"

@class A0UserProfile, A0CredentialsValidator, A0Token, A0AuthParameters, A0Connection, A0Lock, A0LockConfiguration, A0LoginView;

@interface A0ActiveDirectoryViewController : UIViewController <A0AuthenticationUIComponent>

@property (copy, nonatomic) A0AuthParameters *parameters;
@property (strong, nonatomic) A0Lock *lock;
@property (strong, nonatomic) A0Connection *defaultConnection;
@property (strong, nonatomic) A0LockConfiguration *configuration;

@property (copy, nonatomic) void(^onLoginBlock)(A0UserProfile *profile, A0Token *token);

@property (strong, nonatomic) A0CredentialsValidator *validator;
@property (strong, nonatomic) id<A0ConnectionDomainMatcher> domainMatcher;

@property (weak, nonatomic) A0LoginView *loginView;

@property (copy, nonatomic) NSString *identifier;

@end
