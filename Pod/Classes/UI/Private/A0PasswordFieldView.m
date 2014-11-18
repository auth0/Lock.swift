// A0PasswordFieldView.m
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

#import "A0PasswordFieldView.h"
#import "A0Theme.h"

@implementation A0PasswordFieldView

- (void)awakeFromNib {
    [super awakeFromNib];
    UIButton *passwordManagerButton = [UIButton buttonWithType:UIButtonTypeSystem];
    passwordManagerButton.translatesAutoresizingMaskIntoConstraints = NO;
    passwordManagerButton.tintColor = [[A0Theme sharedInstance] colorForKey:A0ThemeSecondaryButtonTextColor];
    [passwordManagerButton setImage:[UIImage imageNamed:@"onepassword-button"] forState:UIControlStateNormal];
    [self addSubview:passwordManagerButton];
    self.passwordManagerButton = passwordManagerButton;
    CGFloat marginRight = self.fieldTrailingSpace.constant;
    [self removeConstraint:self.fieldTrailingSpace];
    UITextField *field = self.textField;
    NSDictionary *views = NSDictionaryOfVariableBindings(field, passwordManagerButton);
    NSDictionary *metrics = @{
                              @"marginLeft": @7,
                              @"marginRight": @(marginRight)
                              };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[field]-(marginLeft)-[passwordManagerButton]-(marginRight)-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:passwordManagerButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:0]];
}

@end
