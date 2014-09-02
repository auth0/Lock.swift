//
//  A0CredentialFieldView.m
//  Pods
//
//  Created by Hernan Zalazar on 9/2/14.
//
//

#import "A0CredentialFieldView.h"
#import "A0Theme.h"

@interface A0CredentialFieldView ()
@property (strong, nonatomic) UIColor *validTextColor;
@end

@implementation A0CredentialFieldView

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _validTextColor = self.textField.textColor;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconImageView.image = [self.iconImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
}

- (void)setInvalid:(BOOL)invalid {
    [self willChangeValueForKey:@"invalid"];
    _invalid = invalid;
    [self didChangeValueForKey:@"invalid"];
    self.iconImageView.tintColor = invalid ? [UIColor redColor] : nil;
    self.textField.tintColor = invalid ? [UIColor redColor] : nil;
    self.textField.textColor = invalid ? [UIColor redColor] : nil;
}

@end
