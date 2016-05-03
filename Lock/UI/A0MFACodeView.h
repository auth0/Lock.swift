// A0MFACodeView.h
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

@class A0CredentialFieldView, A0ProgressButton, A0MFACodeView, A0Theme;

typedef void(^A0MFACodeViewCompletionHandler)(BOOL success);

@protocol A0MFACodeViewDelegate <NSObject>

- (void)mfaCodeView:(A0MFACodeView *)mfaCodeView didSubmitWithCompletionHandler:(A0MFACodeViewCompletionHandler)completionHandler;

@end

@interface A0MFACodeView : UIView

- (instancetype)initWithTheme:(A0Theme *)theme;

@property (weak, nonatomic) A0CredentialFieldView *codeField;
@property (weak, nonatomic) A0ProgressButton *submitButton;

@property (weak, nullable, nonatomic) id<A0MFACodeViewDelegate> delegate;
@property (copy, nullable, nonatomic) NSString *code;
@property (assign, nonatomic) BOOL codeValid;

@end

NS_ASSUME_NONNULL_END