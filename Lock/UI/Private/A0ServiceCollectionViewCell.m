// A0ServiceCollectionViewCell.m
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

#import "A0ServiceCollectionViewCell.h"

#import <CoreGraphics/CoreGraphics.h>

@implementation A0ServiceCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupLayout {
    UIButton *serviceButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    serviceButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:serviceButton];

    NSDictionary<NSString *, id> *metrics = @{ @"margin": @6 };
    NSDictionary<NSString *, id> *views = @{ @"button": serviceButton };
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-margin-[button]-margin-|"
                                                                 options:0 
                                                                 metrics:metrics
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-margin-[button]-margin-|"
                                                                 options:0
                                                                 metrics:metrics
                                                                   views:views]];

    self.serviceButton = serviceButton;
    [self setNeedsUpdateConstraints];
}

- (void)setupUI {
    [self setupLayout];


    self.serviceButton.layer.cornerRadius = 5.0f;
    self.serviceButton.clipsToBounds = YES;
}

- (void)prepareForReuse {
    [self.serviceButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
}

@end
