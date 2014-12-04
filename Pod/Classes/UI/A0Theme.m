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
NSString * const A0ThemeSecondaryButtonBackgroundColor = @"A0ThemeSecondaryButtonBackgroundColor";
NSString * const A0ThemeSecondaryButtonFont = @"A0ThemeSecondaryButtonFont";
NSString * const A0ThemeSecondaryButtonTextColor = @"A0ThemeSecondaryButtonTextColor";
NSString * const A0ThemeTextFieldFont = @"A0ThemeTextFieldFont";
NSString * const A0ThemeTextFieldPlaceholderTextColor = @"A0ThemeTextFieldPlaceholderTextColor";
NSString * const A0ThemeTextFieldTextColor = @"A0ThemeTextFieldTextColor";
NSString * const A0ThemeTextFieldIconColor = @"A0ThemeTextFieldIconColor";
NSString * const A0ThemeTitleFont = @"A0ThemeTitleFont";
NSString * const A0ThemeTitleTextColor = @"A0ThemeTitleTextColor";
NSString * const A0ThemeDescriptionFont = @"A0ThemeDescriptionFont";
NSString * const A0ThemeDescriptionTextColor = @"A0ThemeDescriptionTextColor";
NSString * const A0ThemeScreenBackgroundColor = @"A0ThemeScreenBackgroundColor";
NSString * const A0ThemeScreenBackgroundImageName = @"A0ThemeScreenBackgroundImageName";
NSString * const A0ThemeIconImageName = @"A0ThemeIconImageName";
NSString * const A0ThemeIconBackgroundColor = @"A0ThemeIconBackgroundColor";
NSString * const A0ThemeSeparatorTextFont = @"A0ThemeSeparatorTextFont";
NSString * const A0ThemeSeparatorTextColor = @"A0ThemeSeparatorTextColor";
NSString * const A0ThemeCredentialBoxBorderColor = @"A0ThemeCredentialBoxBorderColor";

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
        _statusBarStyle = UIStatusBarStyleDefault;
        _values = [@{
                     A0ThemePrimaryButtonNormalColor: [UIColor colorWithRed:0.086 green:0.129 blue:0.302 alpha:1.000],
                     A0ThemePrimaryButtonHighlightedColor: [UIColor colorWithRed:0.043 green:0.063 blue:0.145 alpha:1.000],
                     A0ThemePrimaryButtonFont: [UIFont fontWithName:@"HelveticaNeue-Medium" size:13.0f],
                     A0ThemePrimaryButtonTextColor: [UIColor whiteColor],

                     A0ThemeSecondaryButtonBackgroundColor: [UIColor colorWithWhite:0.945 alpha:1.000],
                     A0ThemeSecondaryButtonFont: [UIFont boldSystemFontOfSize:10.0f],
                     A0ThemeSecondaryButtonTextColor: [UIColor colorWithWhite:0.302 alpha:1.000],

                     A0ThemeTextFieldFont: [UIFont systemFontOfSize:13.0f],
                     A0ThemeTextFieldPlaceholderTextColor: [UIColor colorWithRed:0.616 green:0.635 blue:0.675 alpha:1.000],
                     A0ThemeTextFieldTextColor: [UIColor colorWithWhite:0.302 alpha:1.000],
                     A0ThemeTextFieldIconColor: [UIColor colorWithWhite:0.600 alpha:1.000],

                     A0ThemeDescriptionFont: [UIFont systemFontOfSize:13.0f],
                     A0ThemeDescriptionTextColor: [UIColor colorWithWhite:0.302 alpha:1.000],

                     A0ThemeTitleFont: [UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0f],
                     A0ThemeTitleTextColor: [UIColor colorWithWhite:0.298 alpha:1.000],

                     A0ThemeScreenBackgroundColor: [UIColor whiteColor],
                     A0ThemeIconBackgroundColor: [UIColor colorWithWhite:0.941 alpha:1.000],
                     A0ThemeIconImageName: @"Auth0.bundle/people",

                     A0ThemeSeparatorTextColor: [UIColor colorWithWhite:0.600 alpha:1.000],
                     A0ThemeSeparatorTextFont: [UIFont systemFontOfSize:12.0f],
                     A0ThemeCredentialBoxBorderColor: [UIColor colorWithWhite:0.800 alpha:1.000],
                     } mutableCopy];
    }
    return self;
}

- (void)registerTheme:(A0Theme *)theme {
    self.statusBarStyle = theme.statusBarStyle;
    [self.values addEntriesFromDictionary:theme.values];
}

- (void)registerDefaultTheme {
    [self.values removeAllObjects];
    [self registerTheme:[[A0Theme alloc] init]];
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

- (UIFont *)fontForKey:(NSString *)key {
    return [self fontForKey:key defaultFont:nil];
}

- (UIFont *)fontForKey:(NSString *)key defaultFont:(UIFont *)defaultFont {
    NSAssert(key != nil, @"Key must be non nil");
    return self.values[key] ?: defaultFont;
}

- (UIColor *)colorForKey:(NSString *)key {
    return [self colorForKey:key defaultColor:nil];
}

- (UIColor *)colorForKey:(NSString *)key defaultColor:(UIColor *)defaultColor {
    NSAssert(key != nil, @"Key must be non nil");
    return self.values[key] ?: defaultColor;
}

- (UIImage *)imageForKey:(NSString *)key {
    return [self imageForKey:key defaultImage:nil];
}

- (UIImage *)imageForKey:(NSString *)key defaultImage:(UIImage *)image {
    NSAssert(key != nil, @"Key must be non nil");
    return self.values[key] ? [UIImage imageNamed:self.values[key]] : image;
}

- (void)configurePrimaryButton:(UIButton *)button {
    [button setBackgroundColor:[self colorForKey:A0ThemePrimaryButtonNormalColor]
                      forState:UIControlStateNormal];
    [button setBackgroundColor:[self colorForKey:A0ThemePrimaryButtonHighlightedColor]
                      forState:UIControlStateHighlighted];
    button.layer.cornerRadius = 5;
    button.clipsToBounds = YES;
    button.titleLabel.font = [self fontForKey:A0ThemePrimaryButtonFont];
    button.titleLabel.textColor = [self colorForKey:A0ThemePrimaryButtonTextColor];
}

- (void)configureSecondaryButton:(UIButton *)button {
    UIImage *backgroundNormal = [[[UIImage imageNamed:@"Auth0.bundle/secondary_button_normal"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 28, 0, 28)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIImage *backgroundHighlighted = [[[UIImage imageNamed:@"Auth0.bundle/secondary_button_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 28, 0, 28)] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [button setBackgroundImage:backgroundNormal forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundHighlighted forState:UIControlStateHighlighted];
    button.tintColor = [self colorForKey:A0ThemeSecondaryButtonBackgroundColor];
    [button setTitleColor:[self colorForKey:A0ThemeSecondaryButtonTextColor] forState:UIControlStateNormal];
    button.titleLabel.font = [self fontForKey:A0ThemeSecondaryButtonFont];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
}

- (void)configureTextField:(UITextField *)textField {
    textField.font = [self fontForKey:A0ThemeTextFieldFont];
    textField.textColor = [self colorForKey:A0ThemeTextFieldTextColor];
}

- (void)configureLabel:(UILabel *)label {
    label.font = [self fontForKey:A0ThemeDescriptionFont];
    label.textColor = [self colorForKey:A0ThemeDescriptionTextColor];
}

@end
