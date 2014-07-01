//
//  A0ServiceCollectionViewCell.m
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import "A0ServiceCollectionViewCell.h"

#import <CoreGraphics/CoreGraphics.h>

@implementation A0ServiceCollectionViewCell

- (void)awakeFromNib {
    self.backgroundColor = [UIColor redColor];
    self.layer.cornerRadius = 5.0f;
    self.selectedBackgroundView = [[UIView alloc] init];
    self.selectedBackgroundView.layer.cornerRadius = 5.0f;
    self.selectedBackgroundView.backgroundColor = [UIColor blueColor];
}
@end
