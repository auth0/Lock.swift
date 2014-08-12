//
//  A0LoadingViewController.m
//  Pods
//
//  Created by Hernan Zalazar on 8/12/14.
//
//

#import "A0LoadingViewController.h"

@interface A0LoadingViewController ()

@end

@implementation A0LoadingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"";
    }
    return self;
}

#pragma mark - A0KeyboardEnabledView

- (void)hideKeyboard {}

- (CGRect)rectToKeepVisibleInView:(UIView *)view {
    return CGRectZero;
}

@end
