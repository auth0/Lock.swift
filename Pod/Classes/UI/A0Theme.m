//  A0Theme.m
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

#import "A0Theme.h"

#import "UIButton+A0SolidButton.h"

NSString * const A0ThemePrimaryButtonNormalColor = @"A0ThemePrimaryButtonNormalColor";
NSString * const A0ThemePrimaryButtonHighlightedColor = @"A0ThemePrimaryButtonHighlightedColor";
NSString * const A0ThemePrimaryButtonFont = @"A0ThemePrimaryButtonFont";
NSString * const A0ThemePrimaryButtonTextColor = @"A0ThemePrimaryButtonTextColor";
NSString * const A0ThemeSecondaryButtonNormalColor = @"A0ThemeSecondaryButtonNormalColor";
NSString * const A0ThemeSecondaryButtonHighlightedColor = @"A0ThemeSecondaryButtonHighlightedColor";
NSString * const A0ThemeSecondaryButtonFont = @"A0ThemeSecondaryButtonFont";
NSString * const A0ThemeSecondaryButtonTextColor = @"A0ThemeSecondaryButtonTextColor";
NSString * const A0ThemeTextFieldFont = @"A0ThemeTextFieldFont";
NSString * const A0ThemeTextFieldTextColor = @"A0ThemeTextFieldTextColor";
NSString * const A0ThemeTitleFont = @"A0ThemeTitleFont";
NSString * const A0ThemeTitleTextColor = @"A0ThemeTitleTextColor";
NSString * const A0ThemeDescriptionFont = @"A0ThemeDescriptionFont";
NSString * const A0ThemeDescriptionTextColor = @"A0ThemeDescriptionTextColor";
NSString * const A0ThemeScreenBackgroundColor = @"A0ThemeScreenBackgroundColor";
NSString * const A0ThemeIconImageName = @"A0ThemeIconImageName";
NSString * const A0ThemeIconBackgroundColor = @"A0ThemeIconBackgroundColor";

@interface A0Theme ()

@property (strong, nonatomic) NSMutableDictionary *values;

@end

@implementation A0Theme

+ (A0Theme *)sharedInstance {
    static A0Theme *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[A0Theme alloc] init];
    });
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        _values = [@{} mutableCopy];
    }
    return self;
}

- (void)registerColor:(UIColor *)color forKey:(NSString *)key {
    NSAssert(color != nil && key != nil, @"Color and Key must be non nil.");
    self.values[key] = color;
}

- (void)registerFont:(UIFont *)font forKey:(NSString *)key {
    NSAssert(font != nil && key != nil, @"Font and Key must be non nil.");
    self.values[key] = font;
}

- (void)registerImageWithName:(NSString *)name forKey:(NSString *)key {
    NSAssert(name != nil && key != nil, @"Image name and Key must be non nil.");
    self.values[key] = name;
}

- (UIFont *)fontForKey:(NSString *)key defaultFont:(UIFont *)defaultFont {
    NSAssert(key != nil, @"Key must be non nil");
    return self.values[key] ?: defaultFont;
}

- (UIColor *)colorForKey:(NSString *)key defaultColor:(UIColor *)defaultColor {
    NSAssert(key != nil, @"Key must be non nil");
    return self.values[key] ?: defaultColor;
}

- (UIImage *)imageForKey:(NSString *)key defaultImage:(UIImage *)image {
    NSAssert(key != nil, @"Key must be non nil");
    return self.values[key] ? [UIImage imageNamed:self.values[key]] : image;
}

- (void)configurePrimaryButton:(UIButton *)button {
    [button setBackgroundColor:[self colorForKey:A0ThemePrimaryButtonNormalColor
                                     defaultColor:[UIColor colorWithRed:0.086 green:0.129 blue:0.302 alpha:1.000]]
                      forState:UIControlStateNormal];
    [button setBackgroundColor:[self colorForKey:A0ThemePrimaryButtonHighlightedColor
                                     defaultColor:[UIColor colorWithRed:0.043 green:0.063 blue:0.145 alpha:1.000]]
                      forState:UIControlStateHighlighted];
    button.layer.cornerRadius = 5;
    button.clipsToBounds = YES;
    button.titleLabel.font = [self fontForKey:A0ThemePrimaryButtonFont defaultFont:button.titleLabel.font];
    button.titleLabel.textColor = [self colorForKey:A0ThemePrimaryButtonTextColor defaultColor:button.titleLabel.textColor];
}

- (void)configureSecondaryButton:(UIButton *)button {
    [button setBackgroundColor:[self colorForKey:A0ThemeSecondaryButtonNormalColor
                                     defaultColor:[UIColor clearColor]]
                      forState:UIControlStateNormal];
    [button setBackgroundColor:[self colorForKey:A0ThemeSecondaryButtonHighlightedColor
                                     defaultColor:[UIColor clearColor]]
                      forState:UIControlStateHighlighted];
    button.layer.cornerRadius = 2;
    button.clipsToBounds = YES;
    button.titleLabel.font = [self fontForKey:A0ThemeSecondaryButtonFont defaultFont:button.titleLabel.font];
    button.titleLabel.textColor = [self colorForKey:A0ThemeSecondaryButtonTextColor defaultColor:button.titleLabel.textColor];
}

- (void)configureTextField:(UITextField *)textField {
    textField.font = [self fontForKey:A0ThemeTextFieldFont defaultFont:textField.font];
    textField.textColor = [self colorForKey:A0ThemeTextFieldTextColor defaultColor:textField.textColor];
}

- (void)configureLabel:(UILabel *)label {
    label.font = [self fontForKey:A0ThemeDescriptionFont defaultFont:label.font];
    label.textColor = [self colorForKey:A0ThemeDescriptionTextColor defaultColor:label.textColor];
}

@end
