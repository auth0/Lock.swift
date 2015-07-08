// A0HTTPStubber.h
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

#import <Foundation/Foundation.h>

@class A0Application;

typedef BOOL(^HTTPFilter)(NSURLRequest *request);

@interface A0HTTPStubber : NSObject

@property (readonly, nonatomic) A0Application *application;

- (instancetype)initWithApplication:(A0Application *)application;

- (HTTPFilter)filterForResourceOwnerWithUsername:(NSString *)username password:(NSString *)password;

- (HTTPFilter)filterForResourceOwnerWithParameters:(NSDictionary *)parameters;

- (HTTPFilter)filterForTokenInfoWithJWT:(NSString *)jwt;

- (HTTPFilter)filterForSignUpWithParameters:(NSDictionary *)parameters;

- (HTTPFilter)filterForChangePasswordWithParameters:(NSDictionary *)parameters;

- (HTTPFilter)filterForSocialAuthenticationWithParameters:(NSDictionary *)parameters;

- (HTTPFilter)filterForDelegationWithParameters:(NSDictionary *)parameters;

- (HTTPFilter)filterForUnlinkWithParameters:(NSDictionary *)parameters;

- (HTTPFilter)filterForPasswordlessStartWithPhoneNumber:(NSString *)phoneNumber;
@end
