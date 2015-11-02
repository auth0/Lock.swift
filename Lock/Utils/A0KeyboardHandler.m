// A0KeyboardHandler.m
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

#import "A0KeyboardHandler.h"

@implementation NSNotification (UIKeyboardInfo)

- (CGFloat)keyboardAnimationDuration {
    return [[self userInfo][UIKeyboardAnimationDurationUserInfoKey] doubleValue];
}

- (NSUInteger)keyboardAnimationCurve {
    return [[self userInfo][UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
}

- (CGRect)keyboardEndFrame {
    return [[self userInfo][UIKeyboardFrameEndUserInfoKey] CGRectValue];
}

@end

@interface A0KeyboardHandler ()

@property (weak, nonatomic) id<A0KeyboardEnabledView> view;
@property (weak, nonatomic) UIView *containerView;

@end

@implementation A0KeyboardHandler

- (void)start {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)stop {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)handleForView:(id<A0KeyboardEnabledView>)view inView:(UIView *)containerView {
    self.view = view;
    self.containerView = containerView;
}

- (void)keyboardWillBeShown:(NSNotification *)notification {
    CGRect keyboardFrame = [self.containerView convertRect:[notification keyboardEndFrame] fromView:nil];
    CGFloat animationDuration = [notification keyboardAnimationDuration];
    NSUInteger animationCurve = [notification keyboardAnimationCurve];
    CGRect buttonFrame = [self.view rectToKeepVisibleInView:self.containerView];
    CGRect frame = self.containerView.frame;
    CGFloat newY = (frame.size.height - keyboardFrame.size.height) - (buttonFrame.origin.y + buttonFrame.size.height);
    frame.origin.y = MIN(newY, 0);
    [UIView animateWithDuration:animationDuration delay:0.0f options:animationCurve animations:^{
        self.containerView.frame = frame;
    } completion:nil];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification {
    CGFloat animationDuration = [notification keyboardAnimationDuration];
    NSUInteger animationCurve = [notification keyboardAnimationCurve];
    CGRect frame = self.containerView.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:animationDuration delay:0.0f options:animationCurve animations:^{
        self.containerView.frame = frame;
    } completion:nil];
}

@end
