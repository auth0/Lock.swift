//  A0ServicesTheme.m
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

#import "A0ServicesTheme.h"

#define UIColorFromRGBA(rgbValue, alphaValue) ([UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0 \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0 \
blue:((float)(rgbValue & 0xFF)) / 255.0 \
alpha:alphaValue])

#define UIColorFromRGB(rgbValue) (UIColorFromRGBA((rgbValue), 1.0))

@interface A0ServicesTheme ()
@property (strong, nonatomic) NSDictionary *themeInfo;
@end

@implementation A0ServicesTheme

- (id)init {
    self = [super init];
    if (self) {
        NSString *resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"Auth0" ofType:@"bundle"];
        NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
        NSString *plistPath = [resourceBundle pathForResource:@"Services" ofType:@"plist"];
        _themeInfo = [NSDictionary dictionaryWithContentsOfFile:plistPath];
    }
    return self;
}

- (UIColor *)selectedBackgroundColorForServiceWithName:(NSString *)name {
    return [self colorFromString:self.themeInfo[name][@"selected_background_color"]];
}

- (UIColor *)backgroundColorForServiceWithName:(NSString *)name {
    return [self colorFromString:self.themeInfo[name][@"background_color"]];
}

- (UIColor *)foregroundColorForServiceWithName:(NSString *)name {
    return [self colorFromString:self.themeInfo[name][@"foreground_color"]];
}

- (NSString *)iconCharacterForServiceWithName:(NSString *)name {
    return self.themeInfo[name][@"icon_character"];
}

- (NSString *)titleForServiceWithName:(NSString *)name {
    return self.themeInfo[name][@"title"];
}

#pragma mark - Utility methods

- (UIColor *)colorFromString:(NSString *)string {
    NSString *hexString = string.length > 0 ? string : @"000000";
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hex;
    BOOL success = [scanner scanHexInt:&hex];

    if (!success) return nil;
    if ([string length] <= 6) {
        return UIColorFromRGB(hex);
    } else {
        unsigned color = (hex & 0xFFFFFF00) >> 8;
        CGFloat alpha = 1.0 * (hex & 0xFF) / 255.0;
        return UIColorFromRGBA(color, alpha);
    }
}

@end
