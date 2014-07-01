//
//  A0UserPasswordView.m
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import "A0UserPasswordView.h"

#import <CoreGraphics/CoreGraphics.h>

@implementation A0UserPasswordView

- (void)awakeFromNib {
    [super awakeFromNib];

    self.userContainerView.layer.borderWidth = 1.0f;
    self.userContainerView.layer.borderColor = [[UIColor colorWithWhite:0.302 alpha:1.000] CGColor];
    self.passwordContainerView.layer.borderWidth = 1.0f;
    self.passwordContainerView.layer.borderColor = [[UIColor colorWithWhite:0.302 alpha:1.000] CGColor];

    [self.accessButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.086 green:0.129 blue:0.302 alpha:1.000]] forState:UIControlStateNormal];
    [self.accessButton setBackgroundImage:[self imageWithColor:[UIColor colorWithRed:0.043 green:0.063 blue:0.145 alpha:1.000]] forState:UIControlStateHighlighted];
    self.accessButton.layer.cornerRadius = 5;
    self.accessButton.clipsToBounds = YES;
}

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);

    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}
@end
