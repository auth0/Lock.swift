// A0ProgressButton.m
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

#import "A0ProgressButton.h"

@interface A0ProgressButton ()

@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation A0ProgressButton

- (void)setInProgress:(BOOL)inProgress {
    if (inProgress) {
        self.enabled = NO;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
    } else {
        self.enabled = YES;
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
    }
}

#pragma mark - Factory Methods

+ (instancetype)progressButton {
    return [self progressButtonWithFrame:CGRectZero];
}

+ (instancetype)progressButtonWithFrame:(CGRect)frame {
    A0ProgressButton *button = [A0ProgressButton buttonWithType:UIButtonTypeCustom];
    button.frame = frame;
    [button setupLayout];
    [button setTitle:@" " forState:UIControlStateDisabled];
    return button;
}

#pragma mark - Layout
- (void)setupLayout {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.hidden = YES;
    [self addSubview:activityIndicator];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:activityIndicator
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:activityIndicator
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    self.activityIndicator = activityIndicator;
}
@end
