// A0CompositeAuthView.m
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

#import "A0CompositeAuthView.h"

@implementation A0CompositeAuthView

- (instancetype)initWithFirstView:(UIView *)firstView
                    andSecondView:(UIView *)secondView {
    self = [super init];
    if (self) {
        [self performLayoutWithFirstView:firstView andSecondView:secondView];
    }
    return self;
}

- (void)hideKeyboard {
    [self.delegate hideKeyboard];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    return [self.delegate rectToKeepVisibleInView:view];
}

- (void)showInProgress {
}

- (void)hideInProgress {
}

#pragma mark - Layout methods

- (void)performLayoutWithFirstView:(UIView *)firstView
                     andSecondView:(UIView *)secondView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    firstView.translatesAutoresizingMaskIntoConstraints = NO;
    secondView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:firstView];
    [self addSubview:secondView];

    NSDictionary *views = NSDictionaryOfVariableBindings(firstView, secondView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[firstView][secondView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views];
    [self addConstraints:verticalConstraints];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[firstView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[secondView]|" options:0 metrics:nil views:views]];
}
@end
