//  A0WebViewController.h
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
#import <Lock/A0WebAuthenticable.h>

@class A0Token, A0UserProfile, A0Application, A0Strategy, A0AuthParameters, A0APIClient;

NS_ASSUME_NONNULL_BEGIN

@interface A0WebViewController : UIViewController<A0WebAuthenticable>

@property (copy, nonatomic) NSString *localizedCancelButtonTitle;
@property (copy, nullable, nonatomic) void(^onAuthentication)(A0UserProfile *profile, A0Token *token);
@property (copy, nullable, nonatomic) void(^onFailure)(NSError *error);

- (instancetype)initWithAPIClient:(A0APIClient *)client connectionName:(NSString *)connectionName parameters:(nullable A0AuthParameters *)parameters usePKCE:(BOOL)usePKCE;
- (instancetype)initWithAPIClient:(A0APIClient *)client connectionName:(NSString *)connectionName parameters:(nullable A0AuthParameters *)parameters;

@end

NS_ASSUME_NONNULL_END