//
//  A0CompositeAuthView.m
//  Pods
//
//  Created by Hernan Zalazar on 7/16/14.
//
//

#import "A0CompositeAuthView.h"

@implementation A0CompositeAuthView

- (void)hideKeyboard {
    [self.delegate hideKeyboard];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    return [self.delegate rectToKeepVisibleInView:view];
}
@end
