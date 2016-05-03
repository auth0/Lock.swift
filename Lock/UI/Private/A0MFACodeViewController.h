// A0MFACodeViewController.h
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
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

@class A0AuthParameters, A0CredentialsValidator, A0Lock, A0UserProfile, A0Token;

@interface A0MFACodeViewController : UIViewController<A0AuthenticationUIComponent>

- (instancetype)initWithIdentifier:(NSString *)identifier password:(NSString *)password connectionName:(NSString *)connectionName;

@property (copy, nonatomic) void(^onLoginBlock)(A0UserProfile *profile, A0Token *token);

@property (copy, nonatomic) A0AuthParameters *parameters;
@property (strong, nonatomic) A0Lock *lock;

@end
