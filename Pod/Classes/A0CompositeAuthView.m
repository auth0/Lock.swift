//
//  A0CompositeAuthView.m
//  Pods
//
//  Created by Hernan Zalazar on 7/16/14.
//
//

#import "A0CompositeAuthView.h"

@implementation A0CompositeAuthView

- (instancetype)initWithFirstView:(UIView *)firstView
                    andSecondView:(UIView *)secondView {
    self = [super init];
    if (self) {
        [self performLayoutWithFirstView:firstView andSecondView:secondView];
    }
    return self;
}

- (void)hideKeyboard {
    [self.delegate hideKeyboard];
}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    return [self.delegate rectToKeepVisibleInView:view];
}

- (void)showInProgress {
}

- (void)hideInProgress {
}

#pragma mark - Layout methods

- (void)performLayoutWithFirstView:(UIView *)firstView
                     andSecondView:(UIView *)secondView {
    self.translatesAutoresizingMaskIntoConstraints = NO;
    firstView.translatesAutoresizingMaskIntoConstraints = NO;
    secondView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:firstView];
    [self addSubview:secondView];

    NSDictionary *views = NSDictionaryOfVariableBindings(firstView, secondView);
    NSArray *verticalConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[firstView][secondView]|"
                                                                           options:0
                                                                           metrics:nil
                                                                             views:views];
    [self addConstraints:verticalConstraints];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[firstView]|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[secondView]|" options:0 metrics:nil views:views]];
}
@end
