// A0ServiceViewModel.m
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

#import "A0ServiceViewModel.h"
#import "A0Connection.h"
#import "A0Strategy.h"

UIColor *UIColorFromRGBA(value, alpha) {
    return [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16)) / 255.0 \
                           green:((float)((value & 0xFF00) >> 8)) / 255.0 \
                            blue:((float)(value & 0xFF)) / 255.0 \
                           alpha:alpha];
}

UIColor *UIColorFromRGB(value) { return UIColorFromRGBA(value, 1.0); }

@interface A0ServiceViewModel ()
@property (strong, nonatomic) NSDictionary *theme;
@end

@implementation A0ServiceViewModel

- (instancetype)initWithStrategy:(A0Strategy *)strategy connection:(A0Connection *)connection {
    self = [super init];
    if (self) {
        _name = strategy.name;
        _connection = connection;
    }
    return self;
}

- (void)applyTheme:(NSDictionary *)theme {
    self.theme = [NSDictionary dictionaryWithDictionary:theme[self.name]];
}

#pragma mark - Theme

- (UIColor *)selectedBackgroundColor {
    return [self colorFromString:self.theme[@"selected_background_color"]];
}

- (UIColor *)backgroundColor {
    return [self colorFromString:self.theme[@"background_color"]];
}

- (UIColor *)foregroundColor {
    return [self colorFromString:self.theme[@"foreground_color"]];
}

- (NSString *)iconCharacter {
    return self.theme[@"icon_character"];
}

- (NSString *)title {
    return self.theme[@"title"];
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

@implementation A0ServiceViewModel (Builder)

+ (NSArray *)servicesFromStrategy:(A0Strategy *)strategy {
    NSMutableArray *services = [NSMutableArray arrayWithCapacity:strategy.connections.count];
    for (A0Connection *connection in strategy.connections) {
        [services addObject:[[A0ServiceViewModel alloc] initWithStrategy:strategy connection:connection]];
    }
    return [NSArray arrayWithArray:services];
}

+ (NSArray *)servicesFromStrategies:(NSArray *)strategies {
    NSMutableArray *services = [NSMutableArray arrayWithCapacity:strategies.count];
    for (A0Strategy *strategy in strategies) {
        [services addObjectsFromArray:[self servicesFromStrategy:strategy]];
    }
    return [NSArray arrayWithArray:services];
}

@end

@implementation A0ServiceViewModel (ThemeLoad)

+ (NSDictionary *)loadThemeInformation {
    NSString *resourceBundlePath = [[NSBundle bundleForClass:self.class] pathForResource:@"Auth0" ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourceBundlePath];
    NSString *plistPath = [resourceBundle pathForResource:@"Services" ofType:@"plist"];
    return [NSDictionary dictionaryWithContentsOfFile:plistPath];
}
@end