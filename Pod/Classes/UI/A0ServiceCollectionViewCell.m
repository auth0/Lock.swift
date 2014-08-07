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
    self.serviceButton.layer.cornerRadius = 5.0f;
    self.serviceButton.clipsToBounds = YES;
}

- (void)prepareForReuse {
    [self.serviceButton removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
}

@end
