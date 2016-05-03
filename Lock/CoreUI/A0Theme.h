//  A0Theme.h
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

#import <UIKit/UIKit.h>
#import <Lock/A0ServiceTheme.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const A0ThemePrimaryButtonNormalColor;
FOUNDATION_EXPORT NSString * const A0ThemePrimaryButtonHighlightedColor;
FOUNDATION_EXPORT NSString * const A0ThemePrimaryButtonNormalImageName;
FOUNDATION_EXPORT NSString * const A0ThemePrimaryButtonHighlightedImageName;
FOUNDATION_EXPORT NSString * const A0ThemePrimaryButtonFont;
FOUNDATION_EXPORT NSString * const A0ThemePrimaryButtonTextColor;

FOUNDATION_EXPORT NSString * const A0ThemeSecondaryButtonBackgroundColor;
FOUNDATION_EXPORT NSString * const A0ThemeSecondaryButtonNormalImageName;
FOUNDATION_EXPORT NSString * const A0ThemeSecondaryButtonHighlightedImageName;
FOUNDATION_EXPORT NSString * const A0ThemeSecondaryButtonFont;
FOUNDATION_EXPORT NSString * const A0ThemeSecondaryButtonTextColor;

FOUNDATION_EXPORT NSString * const A0ThemeTextFieldFont;
FOUNDATION_EXPORT NSString * const A0ThemeTextFieldTextColor;
FOUNDATION_EXPORT NSString * const A0ThemeTextFieldPlaceholderTextColor;
FOUNDATION_EXPORT NSString * const A0ThemeTextFieldIconColor;

FOUNDATION_EXPORT NSString * const A0ThemeTitleFont;
FOUNDATION_EXPORT NSString * const A0ThemeTitleTextColor;

FOUNDATION_EXPORT NSString * const A0ThemeDescriptionFont;
FOUNDATION_EXPORT NSString * const A0ThemeDescriptionTextColor;

FOUNDATION_EXPORT NSString * const A0ThemeScreenBackgroundColor;
FOUNDATION_EXPORT NSString * const A0ThemeScreenBackgroundImageName;

FOUNDATION_EXPORT NSString * const A0ThemeIconImageName;
FOUNDATION_EXPORT NSString * const A0ThemeIconBackgroundColor;

FOUNDATION_EXPORT NSString * const A0ThemeSeparatorTextFont;
FOUNDATION_EXPORT NSString * const A0ThemeSeparatorTextColor;

FOUNDATION_EXPORT NSString * const A0ThemeCredentialBoxBorderColor;
FOUNDATION_EXPORT NSString * const A0ThemeCredentialBoxSeparatorColor;
FOUNDATION_EXPORT NSString * const A0ThemeCredentialBoxBackgroundColor;

FOUNDATION_EXPORT NSString * const A0ThemeCloseButtonTintColor;
FOUNDATION_EXPORT NSString * const A0ThemeCloseButtonImageName;

FOUNDATION_EXPORT NSString * const A0ThemeIconEmail;
FOUNDATION_EXPORT NSString * const A0ThemeIconUsername;
FOUNDATION_EXPORT NSString * const A0ThemeIconLock;
FOUNDATION_EXPORT NSString * const A0ThemeIconPhone;

FOUNDATION_EXPORT NSString * const A0ThemeTouchIDLockButtonImageNormalName;
FOUNDATION_EXPORT NSString * const A0ThemeTouchIDLockButtonImageHighlightedName;
FOUNDATION_EXPORT NSString * const A0ThemeTouchIDLockContainerBackgroundColor;

@interface A0Theme : NSObject

+ (A0Theme *)sharedInstance;

@property (assign, nonatomic) UIStatusBarStyle statusBarStyle;
@property (assign, nonatomic) BOOL statusBarHidden;
@property (copy, nonatomic) A0ServiceTheme *(^customThemeForConnection)(NSString *connectionName, A0ServiceTheme *defaultTheme);

- (void)registerFont:(UIFont *)font forKey:(NSString *)key;
- (void)registerColor:(UIColor *)color forKey:(NSString *)key;
- (void)registerImageWithName:(NSString *)name bundle:(nullable NSBundle *)bundle forKey:(NSString *)key;
- (void)registerTheme:(A0Theme *)theme;
- (void)registerDefaultTheme;

- (UIImage *)imageForKey:(NSString *)key;
- (UIFont *)fontForKey:(NSString *)key defaultFont:(nullable UIFont *)defaultFont;
- (UIColor *)colorForKey:(NSString *)key;
- (UIColor *)colorForKey:(NSString *)key defaultColor:(nullable UIColor *)defaultColor;
- (UIFont *)fontForKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key defaultImage:(nullable UIImage *)image;
- (A0ServiceTheme *)themeForStrategyName:(NSString *)strategyName andConnectionName:(NSString *)connectionName;

- (void)configurePrimaryButton:(UIButton *)button;
- (void)configureSecondaryButton:(UIButton *)button;
- (void)configureTextField:(UITextField *)textField;
- (void)configureLabel:(UILabel *)label;
- (void)configureMultilineLabel:(UILabel *)label withText:(NSString *)text;
@end

@interface A0Theme (Deprecated)
- (void)registerImageWithName:(NSString *)name forKey:(NSString *)key DEPRECATED_ATTRIBUTE;
@end

NS_ASSUME_NONNULL_END
