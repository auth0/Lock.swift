//
//  A0LoginViewController.m
//  Pods
//
//  Created by Hernan Zalazar on 6/29/14.
//
//

#import "A0LoginViewController.h"

@interface A0LoginViewController ()

@property (strong, nonatomic) IBOutlet UIView *socialSmallView;
@property (strong, nonatomic) IBOutlet UIView *userPassSmallView;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end

@implementation A0LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.containerView addSubview:self.socialSmallView];
    self.userPassSmallView.frame = CGRectOffset(self.userPassSmallView.frame, 0, self.socialSmallView.frame.size.height);
    [self.containerView addSubview:self.userPassSmallView];
}

- (BOOL)shouldAutorotate {
    return NO;
}

@end
