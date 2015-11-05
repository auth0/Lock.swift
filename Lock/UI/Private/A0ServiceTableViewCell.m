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

@interface A0ServiceTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation A0ServiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    CGFloat size = self.button.frame.size.height;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    [self.button addSubview:view];
    UIImageView *iconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    iconImageView.contentMode = UIViewContentModeCenter;
    [view addSubview:iconImageView];
    self.button.layer.cornerRadius = 5.0f;
    self.button.clipsToBounds = YES;
    self.button.tintColor = [UIColor whiteColor];
    self.iconImageView = iconImageView;
    self.containerView = view;
}

- (void)prepareForReuse {
    [self.button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
}

- (void)applyTheme:(A0ServiceTheme *)theme {
    [self.button setBackgroundColor:theme.normalBackgroundColor forState:UIControlStateNormal];
    [self.button setBackgroundColor:theme.highlightedBackgroundColor forState:UIControlStateHighlighted];
    self.imageView.image = theme.iconImage;
    self.imageView.tintColor = theme.foregroundColor;
    self.containerView.backgroundColor = theme.highlightedBackgroundColor;
    [self.button setTitle:theme.localizedTitle.uppercaseString forState:UIControlStateNormal];
    [self updateConstraints];
}

@end
