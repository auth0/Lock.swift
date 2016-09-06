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
#import "Constants.h"

NSString * const A0ThemePrimaryButtonNormalColor = @"A0ThemePrimaryButtonNormalColor";
NSString * const A0ThemePrimaryButtonHighlightedColor = @"A0ThemePrimaryButtonHighlightedColor";
NSString * const A0ThemePrimaryButtonFont = @"A0ThemePrimaryButtonFont";
NSString * const A0ThemePrimaryButtonTextColor = @"A0ThemePrimaryButtonTextColor";
NSString * const A0ThemePrimaryButtonNormalImageName = @"A0ThemePrimaryButtonNormalImageName";
NSString * const A0ThemePrimaryButtonHighlightedImageName = @"A0ThemePrimaryButtonHighlightedImageName";
NSString * const A0ThemeSecondaryButtonBackgroundColor = @"A0ThemeSecondaryButtonBackgroundColor";
NSString * const A0ThemeSecondaryButtonNormalImageName = @"A0ThemeSecondaryButtonNormalImageName";
NSString * const A0ThemeSecondaryButtonHighlightedImageName = @"A0ThemeSecondaryButtonHighlightedImageName";
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
NSString * const A0ThemeCredentialBoxSeparatorColor = @"A0ThemeCredentialBoxSeparatorColor";
NSString * const A0ThemeCredentialBoxBackgroundColor = @"A0ThemeCredentialBoxBackgroundColor";
NSString * const A0ThemeCloseButtonTintColor = @"A0ThemeCloseButtonTintColor";
NSString * const A0ThemeCloseButtonImageName = @"A0ThemeCloseButtonImageName";
NSString * const A0ThemeIconEmail = @"A0ThemeIconEmail";
NSString * const A0ThemeIconUsername = @"A0ThemeIconUsername";
NSString * const A0ThemeIconLock = @"A0ThemeIconLock";
NSString * const A0ThemeIconPhone = @"A0ThemeIconPhone";
NSString * const A0ThemeTouchIDLockButtonImageNormalName = @"A0ThemeTouchIDLockButtonImageNormalName";
NSString * const A0ThemeTouchIDLockButtonImageHighlightedName = @"A0ThemeTouchIDLockButtonImageHighlightedName";
NSString * const A0ThemeTouchIDLockContainerBackgroundColor = @"A0ThemeTouchIDLockContainerBackgroundColor";


#define kSecondaryButtonImageInsets UIEdgeInsetsMake(0, 28, 0, 28)

@interface A0ImageTheme : NSObject

@property (readonly, nonatomic) NSString *imageName;
@property (readonly, nonatomic) NSString *bundleName;
@property (readonly, nonatomic) UIImage *image;

- (instancetype)initWithImageName:(NSString *)imageName bundle:(NSBundle *)bundle;

+ (instancetype)newImageWithName:(NSString *)name bundle:(NSBundle *)bundle;

@end

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
        _statusBarHidden = NO;
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

                     A0ThemeIconEmail: [A0ImageTheme newImageWithName:@"Auth0.bundle/mail" bundle:nil],
                     A0ThemeIconUsername: [A0ImageTheme newImageWithName:@"Auth0.bundle/person" bundle:nil],
                     A0ThemeIconLock: [A0ImageTheme newImageWithName:@"Auth0.bundle/lock" bundle:nil],
                     A0ThemeIconPhone: [A0ImageTheme newImageWithName:@"Auth0.bundle/cellphone" bundle:nil],

                     A0ThemeDescriptionFont: [UIFont systemFontOfSize:13.0f],
                     A0ThemeDescriptionTextColor: [UIColor colorWithWhite:0.302 alpha:1.000],

                     A0ThemeTitleFont: [UIFont fontWithName:@"HelveticaNeue-Thin" size:24.0f],
                     A0ThemeTitleTextColor: [UIColor colorWithWhite:0.298 alpha:1.000],

                     A0ThemeScreenBackgroundColor: [UIColor whiteColor],
                     A0ThemeIconBackgroundColor: [UIColor colorWithWhite:0.941 alpha:1.000],
                     A0ThemeIconImageName: [A0ImageTheme newImageWithName:@"Auth0.bundle/people" bundle:nil],

                     A0ThemeSeparatorTextColor: [UIColor colorWithWhite:0.600 alpha:1.000],
                     A0ThemeSeparatorTextFont: [UIFont systemFontOfSize:12.0f],

                     A0ThemeCredentialBoxBorderColor: [UIColor colorWithWhite:0.800 alpha:1.000],
                     A0ThemeCredentialBoxSeparatorColor: [UIColor colorWithWhite:0.800 alpha:1.000],
                     A0ThemeCredentialBoxBackgroundColor: [UIColor clearColor],

                     A0ThemeCloseButtonTintColor: [UIColor colorWithWhite:0.302 alpha:1.000],
                     A0ThemeCloseButtonImageName: [A0ImageTheme newImageWithName:@"Auth0.bundle/close" bundle:nil],

                     A0ThemeTouchIDLockButtonImageNormalName: [A0ImageTheme newImageWithName:@"Auth0.bundle/touchid" bundle:nil],
                     A0ThemeTouchIDLockButtonImageHighlightedName: [A0ImageTheme newImageWithName:@"Auth0.bundle/touchid_selected" bundle:nil],
                     A0ThemeTouchIDLockContainerBackgroundColor: [UIColor clearColor],
                     } mutableCopy];
        _customThemeForConnection = ^(NSString *n, A0ServiceTheme *t) { return t; };
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

- (void)registerImageWithName:(NSString *)name bundle:(NSBundle *)bundle forKey:(NSString *)key {
    NSAssert(name != nil && key != nil, @"Image name and Key must be non nil.");
    self.values[key] = [A0ImageTheme newImageWithName:name bundle:bundle];
}

- (void)registerImageWithName:(NSString *)name forKey:(NSString *)key {
    [self registerImageWithName:name bundle:nil forKey:key];
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
    A0ImageTheme *imageTheme = self.values[key];
    return imageTheme.image ?: image;
}

- (void)configurePrimaryButton:(UIButton *)button {
    UIImage *normalImage = [self imageForKey:A0ThemePrimaryButtonNormalImageName];
    UIImage *highlightedImage = [self imageForKey:A0ThemePrimaryButtonHighlightedImageName];
    if (normalImage && highlightedImage) {
        [button setBackgroundImage:normalImage forState:UIControlStateNormal];
        [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    } else {
        [button setBackgroundColor:[self colorForKey:A0ThemePrimaryButtonNormalColor]
                          forState:UIControlStateNormal];
        [button setBackgroundColor:[self colorForKey:A0ThemePrimaryButtonHighlightedColor]
                          forState:UIControlStateHighlighted];
        button.layer.cornerRadius = 5;
        button.clipsToBounds = YES;
    }

    button.titleLabel.font = [self fontForKey:A0ThemePrimaryButtonFont];
    [button setTitleColor:[self colorForKey:A0ThemePrimaryButtonTextColor] forState:UIControlStateNormal];
}

- (void)configureSecondaryButton:(UIButton *)button {
    UIImage *normalImage = [self imageForKey:A0ThemeSecondaryButtonNormalImageName];
    UIImage *highlightedImage = [self imageForKey:A0ThemeSecondaryButtonHighlightedImageName];
    if (!normalImage || !highlightedImage) {
        A0ImageTheme *normalThemeImage = [A0ImageTheme newImageWithName:@"Auth0.bundle/secondary_button_normal" bundle:nil];
        normalImage = [[normalThemeImage.image resizableImageWithCapInsets:kSecondaryButtonImageInsets] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        A0ImageTheme *highlightedThemeImage = [A0ImageTheme newImageWithName:@"Auth0.bundle/secondary_button_highlighted" bundle:nil];
        highlightedImage = [[highlightedThemeImage.image resizableImageWithCapInsets:kSecondaryButtonImageInsets] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        button.tintColor = [self colorForKey:A0ThemeSecondaryButtonBackgroundColor];
        button.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    }
    [button setBackgroundImage:normalImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightedImage forState:UIControlStateHighlighted];
    [button setTitleColor:[self colorForKey:A0ThemeSecondaryButtonTextColor] forState:UIControlStateNormal];
    button.titleLabel.font = [self fontForKey:A0ThemeSecondaryButtonFont];
}

- (void)configureTextField:(UITextField *)textField {
    textField.font = [self fontForKey:A0ThemeTextFieldFont];
    textField.textColor = [self colorForKey:A0ThemeTextFieldTextColor];
}

- (void)configureLabel:(UILabel *)label {
    label.font = [self fontForKey:A0ThemeDescriptionFont];
    label.textColor = [self colorForKey:A0ThemeDescriptionTextColor];
}

- (void)configureMultilineLabel:(UILabel *)label withText:(NSString *)text {
    label.preferredMaxLayoutWidth = 225;
    label.numberOfLines = 3;
    label.textAlignment = NSTextAlignmentCenter;
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 5;
    style.alignment = NSTextAlignmentCenter;
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text
                                                               attributes:@{
                                                                            NSFontAttributeName: [self fontForKey:A0ThemeDescriptionFont],
                                                                            NSForegroundColorAttributeName: [self colorForKey:A0ThemeDescriptionTextColor],
                                                                            NSParagraphStyleAttributeName: style,
                                                                            }];
    label.attributedText = attributedText;
}

- (A0ServiceTheme *)themeForStrategyName:(NSString *)strategyName andConnectionName:(NSString *)connectionName {
    NSDictionary *values;
    NSString *imageName;
    if ([strategyName isEqualToString:@"yahoo"]) {
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with Yahoo!"),
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.6353 green:0.0 blue:0.7608 alpha:1.0],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.4157 green:0.0 blue:0.5255 alpha:1.0],
                   };
    }
    if ([strategyName isEqualToString:@"linkedin"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.0 green:0.5137 blue:0.6588 alpha:1.0],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.0275 green:0.2392 blue:0.3176 alpha:1.0],
        };
    }
    if ([strategyName isEqualToString:@"google-oauth2"]) {
        imageName = @"Auth0.bundle/google";
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with Google"),
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.259 green:0.522 blue:0.957 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.1701 green:0.353 blue:0.6572 alpha:1.0],
                   };
    }
    if ([strategyName isEqualToString:@"twitter"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.275 green:0.753 blue:0.984 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.1451 green:0.4196 blue:0.5843 alpha:1.0],
                   };
    }
    if ([strategyName isEqualToString:@"facebook"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.282 green:0.388 blue:0.682 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.1333 green:0.1804 blue:0.3608 alpha:1.0],
                   };
    }
    if ([strategyName isEqualToString:@"amazon"]) {
        values = @{
                   A0ServiceThemeForegroundColor: [UIColor blackColor],
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:1.0 green:0.6784 blue:0.1137 alpha:1.0],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.4235 green:0.2706 blue:0.051 alpha:1.0],
                   };
    }
    if ([strategyName isEqualToString:@"aol"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.208 green:0.373 blue:0.655 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.153 green:0.271 blue:0.459 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"box"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.290 green:0.475 blue:0.710 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.212 green:0.341 blue:0.498 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"evernote"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.510 green:0.694 blue:0.216 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.361 green:0.486 blue:0.161 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"evernote-sandbox"]) {
        imageName = @"Auth0.bundle/evernote";
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with Evernote (Sandbox)"),
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.510 green:0.694 blue:0.216 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.361 green:0.486 blue:0.161 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"github"]) {
        values = @{
                   A0ServiceThemeForegroundColor: [UIColor blackColor],
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithWhite:0.929 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithWhite:0.651 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"instagram"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.220 green:0.325 blue:0.478 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.161 green:0.235 blue:0.341 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"miicard"]) {
        values = @{
                   A0ServiceThemeForegroundColor: [UIColor blackColor],
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.816 green:0.914 blue:1.000 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.569 green:0.635 blue:0.698 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"paypal"]) {
        values = @{
                   A0ServiceThemeForegroundColor: [UIColor colorWithRed:0.196 green:0.408 blue:0.604 alpha:1.000],
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithWhite:0.929 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithWhite:0.651 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"salesforce"]) {
        values = @{
                   A0ServiceThemeForegroundColor: [UIColor colorWithRed:0.941 green:0.000 blue:0.000 alpha:1.000],
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithWhite:0.929 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithWhite:0.651 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"salesforce-sandbox"]) {
        imageName = @"Auth0.bundle/salesforce";
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with Salesforce (Sandbox)"),
                   A0ServiceThemeForegroundColor: [UIColor colorWithRed:0.941 green:0.000 blue:0.000 alpha:1.000],
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithWhite:0.929 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithWhite:0.651 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"soundcloud"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.698 green:0.224 blue:0.000 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.612 green:0.200 blue:0.000 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"windowslive"]) {
        imageName = @"Auth0.bundle/microsoft";
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with Microsoft"),
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.000 green:0.471 blue:0.835 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.000 green:0.324 blue:0.581 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"yammer"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.235 green:0.435 blue:0.773 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.169 green:0.314 blue:0.541 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"baidu"]) {
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with 百度"),
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.165 green:0.165 blue:0.878 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.125 green:0.129 blue:0.612 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"fitbit"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.467 green:0.757 blue:0.773 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.333 green:0.529 blue:0.537 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"planningcenter"]) {
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with Planning Center"),
                   A0ServiceThemeForegroundColor: [UIColor colorWithWhite:0.820 alpha:1.000],
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithWhite:0.310 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithWhite:0.227 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"renren"]) {
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with 人人"),
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.176 green:0.329 blue:0.706 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.129 green:0.243 blue:0.494 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"thecity"]) {
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with The City"),
                   A0ServiceThemeForegroundColor: [UIColor colorWithWhite:0.820 alpha:1.000],
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.459 green:0.455 blue:0.439 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.325 green:0.322 blue:0.314 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"thecity-sandbox"]) {
        imageName = @"Auth0.bundle/thecity";
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with The City (Sandbox)"),
                   A0ServiceThemeForegroundColor: [UIColor colorWithWhite:0.820 alpha:1.000],
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.459 green:0.455 blue:0.439 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.325 green:0.322 blue:0.314 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"vkontakte"]) {
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with VKONTAKTE"),
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.318 green:0.404 blue:0.553 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.231 green:0.290 blue:0.392 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"weibo"]) {
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with 新浪微博"),
                   A0ServiceThemeForegroundColor: [UIColor colorWithRed:0.941 green:0.000 blue:0.000 alpha:1.000],
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.976 green:0.965 blue:0.945 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.678 green:0.675 blue:0.655 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"wordpress"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.314 green:0.541 blue:0.741 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.224 green:0.380 blue:0.518 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"yandex"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.690 green:0.000 blue:0.000 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.604 green:0.000 blue:0.000 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"shopify"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.510 green:0.694 blue:0.216 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.361 green:0.486 blue:0.161 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"dwolla"]) {
        values = @{
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.871 green:0.533 blue:0.102 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.608 green:0.376 blue:0.078 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"thirtysevensignals"]) {
        imageName = @"Auth0.bundle/37signals";
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with 37 Signals"),
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.380 green:0.525 blue:0.325 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.244 green:0.340 blue:0.212 alpha:1.000],
                   };
    }
    if ([strategyName isEqualToString:@"exact"]) {
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString(@"Login with Exact"),
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.635 green:0.114 blue:0.133 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.557 green:0.106 blue:0.125 alpha:1.000],
                   };
    }
    if (!values) {
        imageName = @"Auth0.bundle/auth0";
        values = @{
                   A0ServiceThemeLocalizedTitle: A0LocalizedString([@"Login with " stringByAppendingString:connectionName]),
                   A0ServiceThemeNormalBackgroundColor: [UIColor colorWithRed:0.922 green:0.325 blue:0.137 alpha:1.000],
                   A0ServiceThemeHighlightedBackgroundColor: [UIColor colorWithRed:0.655 green:0.229 blue:0.099 alpha:1.000],
                   };
    }
    if (!imageName) {
        imageName = [@"Auth0.bundle/" stringByAppendingString:strategyName];
    }
    A0ServiceTheme *theme = [[A0ServiceTheme alloc] initWithName:strategyName
                                                          values:values];
    theme.iconImageName = imageName;
    return self.customThemeForConnection(connectionName, theme);
}

@end

@implementation A0ImageTheme

- (instancetype)initWithImageName:(NSString *)imageName bundle:(NSBundle *)bundle {
    self = [super init];
    if (self) {
        _imageName = [imageName copy];
        _bundleName = [bundle bundleIdentifier];
    }
    return self;
}

+ (instancetype)newImageWithName:(NSString *)name bundle:(NSBundle *)bundle {
    return [[A0ImageTheme alloc] initWithImageName:name bundle:bundle];
}

- (UIImage *)image {
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        NSBundle *bundle = self.bundleName ? [NSBundle bundleWithIdentifier:self.bundleName] : [NSBundle bundleForClass:self.class];
        return [UIImage imageNamed:self.imageName inBundle:bundle compatibleWithTraitCollection:nil];
    } else {
        return [UIImage imageNamed:self.imageName];
    }
}

@end

