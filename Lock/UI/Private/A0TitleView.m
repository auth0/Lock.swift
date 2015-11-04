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
        [self loadNib];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self loadNib];
    }
    return self;
}

- (void)loadNib {
    UIView *view = [[[NSBundle bundleForClass:self.class] loadNibNamed:NSStringFromClass(self.class)
                                                                owner:self
                                                              options:nil]
                    firstObject];
    if (view != nil) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:view];
        NSDictionary *views = NSDictionaryOfVariableBindings(view);
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:views]];
    }

    A0Theme *theme = [A0Theme sharedInstance];
    self.titleLabel.font = [theme fontForKey:A0ThemeTitleFont];
    self.titleLabel.textColor = [theme colorForKey:A0ThemeTitleTextColor];
    self.iconContainerView.backgroundColor = [theme colorForKey:A0ThemeIconBackgroundColor];
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
@end
