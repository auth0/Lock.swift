// A0TitleView.m
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

#import "A0TitleView.h"
#import "A0Theme.h"
#import "Constants.h"

@interface A0TitleView ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bigIconImageView;
@property (weak, nonatomic) IBOutlet UIView *iconContainerView;

@end

@implementation A0TitleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.frame = CGRectMake(0, 0, 172, 114);
        [self setupUI];
    }
    return self;
}

- (void)setupLayout {
    UIView *iconContainerView = [[UIView alloc] init];
    UIImageView *smallIconImageView = [[UIImageView alloc] init];
    UIImageView *bigIconImageView = [[UIImageView alloc] init];
    UILabel *titleLabel = [[UILabel alloc] init];

    self.translatesAutoresizingMaskIntoConstraints = NO;
    iconContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    smallIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    bigIconImageView.translatesAutoresizingMaskIntoConstraints = NO;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;

    [self addSubview:iconContainerView];
    [iconContainerView addSubview:smallIconImageView];
    [self addSubview:bigIconImageView];
    [self addSubview:titleLabel];

    [iconContainerView addConstraint:[NSLayoutConstraint constraintWithItem:smallIconImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:iconContainerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [iconContainerView addConstraint:[NSLayoutConstraint constraintWithItem:smallIconImageView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:iconContainerView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:iconContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:iconContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:60.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:iconContainerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:bigIconImageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:55.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bigIconImageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:150.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bigIconImageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:6.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:iconContainerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:bigIconImageView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:10.0]];

    self.titleLabel = titleLabel;
    self.iconContainerView = iconContainerView;
    self.iconImageView = smallIconImageView;
    self.bigIconImageView = bigIconImageView;
}

- (void)setupUI {
    [self setupLayout];

    A0Theme *theme = [A0Theme sharedInstance];

    self.titleLabel.font = [theme fontForKey:A0ThemeTitleFont];
    self.titleLabel.textColor = [theme colorForKey:A0ThemeTitleTextColor];
    self.titleLabel.text = A0LocalizedString(@"Sign Up");

    self.iconContainerView.backgroundColor = [theme colorForKey:A0ThemeIconBackgroundColor];
    self.iconContainerView.layer.cornerRadius = 30.0;

    self.iconImageView.image = [theme imageForKey:A0ThemeIconImageName];
    self.bigIconImageView.contentMode = UIViewContentModeCenter;

    [self setNeedsUpdateConstraints];
}

- (UIImage *)iconImage {
    return self.iconImageView.image ?: self.bigIconImageView.image;
}

- (void)setIconImage:(UIImage *)iconImage {
    if (iconImage.size.height > 60) {
        self.iconContainerView.hidden = YES;
        self.bigIconImageView.image = iconImage;
        self.bigIconImageView.hidden = NO;
    } else {
        self.iconImageView.image = iconImage;
    }
}

- (NSString *)title {
    return self.titleLabel.text;
}

- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSArray *)accessibilityElements {
    return @[self.titleLabel];
}
@end
