//  A0SignUpView.h
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

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, A0SignUpIndentifierType) {
    A0SignUpIndentifierTypeUsername = 1 << 0,
    A0SignUpIndentifierTypeEmail
};

@class A0Theme, A0SignUpView, A0CredentialFieldView, A0ProgressButton;

typedef void(^A0SignUpViewCompletionHandler)(BOOL success);

@protocol A0SignUpViewDelegate <NSObject>

- (void)signUpView:(A0SignUpView *)signUpView didSubmitWithCompletionHandler:(A0SignUpViewCompletionHandler)completionHandler;

@end

@interface A0SignUpView : UIView

@property (weak, nonatomic) A0CredentialFieldView *identifierField;
@property (weak, nonatomic) A0CredentialFieldView *usernameField;
@property (weak, nonatomic) A0CredentialFieldView *passwordField;
@property (weak, nonatomic) A0ProgressButton *submitButton;

@property (weak, nonatomic) id<A0SignUpViewDelegate> delegate;
@property (copy, nullable, nonatomic) NSString *identifier;
@property (copy, nullable, nonatomic) NSString *username;
@property (copy, nullable, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *title;
@property (assign, nonatomic) A0SignUpIndentifierType identifierType;
@property (assign, nonatomic) BOOL identifierValid;
@property (assign, nonatomic) BOOL usernameValid;
@property (assign, nonatomic) BOOL passwordValid;

- (instancetype)initWithTheme:(A0Theme *)theme requiresUsername:(BOOL)requiresUsername;

@end

NS_ASSUME_NONNULL_END