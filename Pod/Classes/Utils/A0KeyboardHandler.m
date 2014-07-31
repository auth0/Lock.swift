//
//  A0KeyboardHandler.m
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

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

@property (weak, nonatomic) UIView<A0KeyboardEnabledView> *view;
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

- (void)handleForView:(UIView<A0KeyboardEnabledView> *)view inView:(UIView *)containerView {
    self.view = view;
    self.containerView = containerView;
}

- (void)keyboardWillBeShown:(NSNotification *)notification {
    CGRect keyboardFrame = [self.containerView convertRect:[notification keyboardEndFrame] fromView:nil];
    CGFloat animationDuration = [notification keyboardAnimationDuration];
    NSUInteger animationCurve = [notification keyboardAnimationCurve];
    CGRect buttonFrame = [self.view rectToKeepVisibleInView:self.containerView];
    CGRect frame = self.containerView.frame;
    CGFloat newY = keyboardFrame.origin.y - (buttonFrame.origin.y + buttonFrame.size.height);
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
