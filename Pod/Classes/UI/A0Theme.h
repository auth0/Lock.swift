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

FOUNDATION_EXPORT NSString * const A0ThemePrimaryButtonNormalColor;
FOUNDATION_EXPORT NSString * const A0ThemePrimaryButtonHighlightedColor;
FOUNDATION_EXPORT NSString * const A0ThemePrimaryButtonFont;
FOUNDATION_EXPORT NSString * const A0ThemePrimaryButtonTextColor;
FOUNDATION_EXPORT NSString * const A0ThemeSecondaryButtonNormalColor;
FOUNDATION_EXPORT NSString * const A0ThemeSecondaryButtonHighlightedColor;
FOUNDATION_EXPORT NSString * const A0ThemeSecondaryButtonFont;
FOUNDATION_EXPORT NSString * const A0ThemeSecondaryButtonTextColor;
FOUNDATION_EXPORT NSString * const A0ThemeTextFieldFont;
FOUNDATION_EXPORT NSString * const A0ThemeTextFieldTextColor;
FOUNDATION_EXPORT NSString * const A0ThemeTitleFont;
FOUNDATION_EXPORT NSString * const A0ThemeTitleTextColor;
FOUNDATION_EXPORT NSString * const A0ThemeDescriptionFont;
FOUNDATION_EXPORT NSString * const A0ThemeDescriptionTextColor;
FOUNDATION_EXPORT NSString * const A0ThemeScreenBackgroundColor;
FOUNDATION_EXPORT NSString * const A0ThemeIconImageName;
FOUNDATION_EXPORT NSString * const A0ThemeIconBackgroundColor;

@interface A0Theme : NSObject

+ (A0Theme *)sharedInstance;

- (void)registerFont:(UIFont *)font forKey:(NSString *)key;
- (void)registerColor:(UIColor *)color forKey:(NSString *)key;
- (void)registerImageWithName:(NSString *)name forKey:(NSString *)key;

- (UIFont *)fontForKey:(NSString *)key defaultFont:(UIFont *)defaultFont;
- (UIColor *)colorForKey:(NSString *)key defaultColor:(UIColor *)defaultColor;
- (UIImage *)imageForKey:(NSString *)key defaultImage:(UIImage *)image;

- (void)configurePrimaryButton:(UIButton *)button;
- (void)configureSecondaryButton:(UIButton *)button;
- (void)configureTextField:(UITextField *)textField;
- (void)configureLabel:(UILabel *)label;

@end
