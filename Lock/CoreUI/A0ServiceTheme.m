// A0ServiceTheme.m
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

#import "A0ServiceTheme.h"
#import "Constants.h"

NSString * const A0ServiceThemeLocalizedTitle = @"localized_title";
NSString * const A0ServiceThemeLongTitle = @"long_title";
NSString * const A0ServiceThemeNormalBackgroundColor = @"normal_background_color";
NSString * const A0ServiceThemeHighlightedBackgroundColor = @"highlighted_background_color";
NSString * const A0ServiceThemeForegroundColor = @"foreground_color";
NSString * const A0ServiceThemeIconImageName = @"icon_image_name";

@implementation A0ServiceTheme

- (instancetype)initWithName:(NSString *)name values:(NSDictionary<NSString *,id> *)values {
    self = [super init];
    if (self) {
        _name = name;
        _localizedTitle = values[@"localized_title"] ?: [NSString stringWithFormat:A0LocalizedString(@"Login with %@"), name];
        _normalBackgroundColor = values[@"normal_background_color"];
        _highlightedBackgroundColor = values[@"highlighted_background_color"];
        _foregroundColor = values[@"foreground_color"] ?: [UIColor whiteColor];
        _iconImageName = values[@"icon_image_name"] ?: name;
        _iconImageRenderingMode = UIImageRenderingModeAlwaysTemplate;
    }
    return self;
}

- (UIImage *)iconImage {
    if ([UIImage respondsToSelector:@selector(imageNamed:inBundle:compatibleWithTraitCollection:)]) {
        NSBundle *bundle = self.iconImageBundle ?: [NSBundle bundleForClass:self.class];
        return [[UIImage imageNamed:self.iconImageName inBundle:bundle compatibleWithTraitCollection:nil] imageWithRenderingMode:self.iconImageRenderingMode];
    } else {
        return [[UIImage imageNamed:self.iconImageName] imageWithRenderingMode:self.iconImageRenderingMode];
    }
}
@end
