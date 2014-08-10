//
//  A0ServiceTableViewCell.m
//  Pods
//
//  Created by Hernan Zalazar on 8/10/14.
//
//

#import "A0ServiceTableViewCell.h"
#import "UIButton+A0SolidButton.h"

#import <CoreGraphics/CoreGraphics.h>

@interface A0ServiceTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *label;

@end

@implementation A0ServiceTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    UILabel *label = [[UILabel alloc] init];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"connections" size:14.0f];
    [self.button addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *views = NSDictionaryOfVariableBindings(label);
    [self.button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(0)-[label(45)]"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self.button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(0)-[label]-(0)-|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    self.button.layer.cornerRadius = 5.0f;
    self.button.clipsToBounds = YES;
    self.button.tintColor = [UIColor whiteColor];
    self.label = label;
}

- (void)prepareForReuse {
    [self.button removeTarget:nil action:NULL forControlEvents:UIControlEventTouchUpInside];
}

- (void)configureWithBackground:(UIColor *)background highlighted:(UIColor *)highlighted symbol:(NSString *)symbol name:(NSString *)name {
    [self.button setBackgroundColor:background forState:UIControlStateNormal];
    [self.button setBackgroundColor:highlighted forState:UIControlStateHighlighted];
    self.label.backgroundColor = highlighted;
    self.label.text = symbol;
    NSString *title = [NSString stringWithFormat:NSLocalizedString(@"Login with %@", nil), name];
    [self.button setTitle:title.uppercaseString forState:UIControlStateNormal];
}

@end
