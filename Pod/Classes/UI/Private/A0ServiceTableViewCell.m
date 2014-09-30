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
#import "UIFont+A0Social.h"

#import <CoreGraphics/CoreGraphics.h>

@interface A0ServiceTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation A0ServiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont zocialFontOfSize:14.0f];
    [self.button addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(label);
    [self.button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[label(45)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self.button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[label]-(0)-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    self.button.layer.cornerRadius = 5.0f;
    self.button.clipsToBounds = YES;
    self.button.tintColor = [UIColor whiteColor];
    self.label = label;
}

- (void)prepareForReuse {
    [self.button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureWithBackground:(UIColor *)background highlighted:(UIColor *)highlighted foreground:(UIColor *)foreground symbol:(NSString *)symbol name:(NSString *)name {
    [self.button setBackgroundColor:background forState:UIControlStateNormal];
    [self.button setBackgroundColor:highlighted forState:UIControlStateHighlighted];
    [self.button setTitleColor:foreground forState:UIControlStateNormal];
    self.label.backgroundColor = highlighted;
    self.label.text = symbol;
    self.label.textColor = foreground;
    NSString *title = [NSString stringWithFormat:A0LocalizedString(@"Login with %@"), name];
    [self.button setTitle:title.uppercaseString forState:UIControlStateNormal];
}

@end
