// A0ServiceTableViewCell.m
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

#import "A0ServiceTableViewCell.h"
#import "UIButton+A0SolidButton.h"
#import "A0ProgressButton.h"
#import <CoreGraphics/CoreGraphics.h>
#import "Constants.h"
#import "A0ServiceTheme.h"

static const CGFloat ServiceButtonHeight = 46.0f;
static const CGFloat ServiceButtonTitlePaddingLeft = 10.0f;

@interface A0ServiceTableViewCell ()

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation A0ServiceTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupLayout {
    CGRect frame = self.frame;
    A0ProgressButton *serviceButton = [A0ProgressButton progressButtonWithFrame:CGRectMake(0, 0, frame.size.width, ServiceButtonHeight)];
    UIView *iconContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ServiceButtonHeight, ServiceButtonHeight)];

    serviceButton.translatesAutoresizingMaskIntoConstraints = NO;
    iconContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:serviceButton];
    [serviceButton insertSubview:iconContainerView belowSubview:serviceButton.imageView];

    [iconContainerView addConstraint:[NSLayoutConstraint constraintWithItem:iconContainerView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:iconContainerView
                                                                  attribute:NSLayoutAttributeWidth
                                                                 multiplier:1.0 constant:0.0]];

    NSDictionary<NSString *, id> *views = @{ @"container": iconContainerView };
    [serviceButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[container]" options:0 metrics:nil views:views]];
    [serviceButton addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[container]-0-|" options:0 metrics:nil views:views]];

    views = @{ @"button": serviceButton };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[button]-0-|" options:0 metrics:nil views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:serviceButton
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:NSLayoutAttributeNotAnAttribute
                                                    multiplier:1.0 constant:ServiceButtonHeight]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:serviceButton
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0 constant:0.0]];

    self.button = serviceButton;
    self.containerView = iconContainerView;
}

- (void)setupUI {
    [self setupLayout];

    self.button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.button.layer.cornerRadius = 5.0f;
    self.button.clipsToBounds = YES;
    self.button.tintColor = [UIColor whiteColor];
    self.button.titleLabel.font = [UIFont systemFontOfSize:11.0];
    self.button.imageView.tintColor = [UIColor whiteColor];

    [self setNeedsUpdateConstraints];
}

- (void)prepareForReuse {
    [self.button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
}

- (void)applyTheme:(A0ServiceTheme *)theme {
    [self.button setBackgroundColor:theme.normalBackgroundColor forState:UIControlStateNormal];
    [self.button setBackgroundColor:theme.highlightedBackgroundColor forState:UIControlStateDisabled];
    [self.button setBackgroundColor:theme.highlightedBackgroundColor forState:UIControlStateHighlighted];
    UIImage *image = theme.iconImage;
    CGFloat inset = MAX((ServiceButtonHeight - image.size.width) / 2, 0);
    self.button.contentEdgeInsets = UIEdgeInsetsMake(0, inset, 0, 0);
    self.button.titleEdgeInsets = UIEdgeInsetsMake(0, inset + ServiceButtonTitlePaddingLeft, 0, 0);
    [self.button setImage:image forState:UIControlStateNormal];
    self.button.imageView.tintColor = theme.foregroundColor;
    self.containerView.backgroundColor = theme.highlightedBackgroundColor;
    [self.button setTitle:theme.localizedTitle.uppercaseString forState:UIControlStateNormal];
    [self setNeedsUpdateConstraints];
}

@end
