// A0ChangePasswordView.h
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

typedef NS_OPTIONS(NSInteger, A0ChangePasswordIndentifierType) {
    A0ChangePasswordIndentifierTypeUsername = 1 << 0,
    A0ChangePasswordIndentifierTypeEmail
};

@class A0Theme, A0ChangePasswordView, A0CredentialFieldView, A0ProgressButton;

typedef void(^A0ChangePasswordViewCompletionHandler)(BOOL success);

@protocol A0ChangePasswordViewDelegate <NSObject>

- (void)changePasswordView:(A0ChangePasswordView *)changePasswordView didSubmitWithCompletionHandler:(A0ChangePasswordViewCompletionHandler)completionHandler;

@end

@interface A0ChangePasswordView : UIView

@property (weak, nonatomic) A0CredentialFieldView *identifierField;
@property (weak, nonatomic) A0ProgressButton *submitButton;

@property (weak, nonatomic) id<A0ChangePasswordViewDelegate> delegate;
@property (copy, nullable, nonatomic) NSString *identifier;
@property (assign, nonatomic) A0ChangePasswordIndentifierType identifierType;
@property (assign, nonatomic) BOOL identifierValid;

- (instancetype)initWithTheme:(A0Theme *)theme;

@end

NS_ASSUME_NONNULL_END