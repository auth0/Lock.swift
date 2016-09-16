// A0NavigationView.m
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

#import "A0NavigationView.h"
#import "A0Theme.h"
#import "Constants.h"

#define kTopMarginButton 5.0f

@interface A0NavigationView ()
@property (strong, nonatomic) NSMutableArray *actions;
@property (strong, nonatomic) NSMutableArray *buttons;
@end

@implementation A0NavigationView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.actions = [@[] mutableCopy];
    self.buttons = [@[] mutableCopy];
    self.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)removeAll {
    [self.actions removeAllObjects];
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        [button removeTarget:self action:NULL forControlEvents:UIControlEventAllTouchEvents];
        [button removeFromSuperview];
    }];
    [self.buttons removeAllObjects];
}

- (void)addButtonWithLocalizedTitle:(NSString *)localizedTitle actionBlock:(A0NavigationViewActionBlock)actionBlock {
    if (self.buttons.count >= 2) {
        A0LogWarn(@"Already has 2 butttons which is the Max. Skipping last button with title %@", localizedTitle);
        return;
    }
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button setTitle:localizedTitle forState:UIControlStateNormal];
    button.tag = self.buttons.count;
    [button addTarget:self action:@selector(onAction:) forControlEvents:UIControlEventTouchUpInside];
    A0Theme *theme = [A0Theme sharedInstance];
    [theme configureSecondaryButton:button];
    [self.actions addObject:[actionBlock copy]];
    [self.buttons addObject:button];
    [self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        [button removeFromSuperview];
        [self addSubview:button];
    }];
    [self setNeedsUpdateConstraints];
}

- (void)onAction:(UIButton *)sender {
    NSInteger tag = [sender tag];
    A0NavigationViewActionBlock action = self.actions[tag];
    if (action) {
        action();
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    switch (self.buttons.count) {
        case 1:
            [self layoutCenteredButton:self.buttons.firstObject];
            break;
        case 2:
            [self layoutLeftButton:self.buttons.firstObject rightButton:self.buttons.lastObject];
            break;
        default:
            break;
    }
}

- (void)dealloc {
    [self removeAll];
}

- (void)layoutCenteredButton:(UIButton *)button {
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:button
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0f
                                                      constant:0.0f]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:button
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:kTopMarginButton]];
}

- (void)layoutLeftButton:(UIButton *)leftButton rightButton:(UIButton *)rightButton {
    NSDictionary *views = NSDictionaryOfVariableBindings(leftButton, rightButton);
    NSDictionary *metrics = @{
                              @"margin": @20,
                              };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(margin)-[leftButton]"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[rightButton]-(margin)-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:leftButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:kTopMarginButton]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:rightButton
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0f
                                                      constant:kTopMarginButton]];
}

- (CGSize)intrinsicContentSize {
    CGFloat height = self.preferredHeight;
    CGFloat width = UIViewNoIntrinsicMetric;
    UIButton *button = self.buttons.firstObject;
    CGSize buttonSize = [button intrinsicContentSize];
    if (self.preferredHeight == 0) {
        if (buttonSize.height != UIViewNoIntrinsicMetric) {
            height = buttonSize.height + (7.0f * 2);
        } else {
            height = UIViewNoIntrinsicMetric;
        }
    }

    if (buttonSize.width != UIViewNoIntrinsicMetric) {
        width = buttonSize.width + (7.0f * (self.buttons.count + 1));
    } else {
        width = UIViewNoIntrinsicMetric;
    }
    return CGSizeMake(width, height);
}
@end
