//  A0ChangePasswordViewController.h
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
#import "A0FieldValidator.h"

@class A0AuthParameters, A0Connection, A0Lock, A0CredentialFieldView;

@interface A0ChangePasswordViewController : UIViewController<A0AuthenticationUIComponent>

@property (copy, nonatomic) void(^onChangePasswordBlock)();
@property (copy, nonatomic) A0AuthParameters *parameters;
@property (assign, nonatomic) BOOL forceUsername;
@property (strong, nonatomic) id<A0FieldValidator> validator;
@property (copy, nonatomic) NSString *email;
@property (strong, nonatomic) A0Connection *defaultConnection;
@property (strong, nonatomic) A0Lock *lock;

@end
