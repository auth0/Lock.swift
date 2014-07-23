//
//  A0ProgressButton.m
//  Pods
//
//  Created by Hernan Zalazar on 7/23/14.
//
//

#import "A0ProgressButton.h"

@interface A0ProgressButton ()

@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;

@end

@implementation A0ProgressButton

- (void)awakeFromNib {
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.hidden = YES;
    [self addSubview:activityIndicator];
    activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(activityIndicator);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[activityIndicator]-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                              attribute:NSLayoutAttributeCenterY
                                                              relatedBy:NSLayoutRelationEqual
                                                                 toItem:activityIndicator
                                                              attribute:NSLayoutAttributeCenterY
                                                             multiplier:1.0f
                                                               constant:0.0f]];
    self.activityIndicator = activityIndicator;
}

- (void)setInProgress:(BOOL)inProgress {
    if (inProgress) {
        self.enabled = NO;
        self.activityIndicator.hidden = NO;
        [self.activityIndicator startAnimating];
    } else {
        self.enabled = YES;
        self.activityIndicator.hidden = YES;
        [self.activityIndicator stopAnimating];
    }
}

@end
