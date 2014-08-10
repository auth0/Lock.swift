//
//  A0ServiceTableViewCell.h
//  Pods
//
//  Created by Hernan Zalazar on 8/10/14.
//
//

#import <UIKit/UIKit.h>

@interface A0ServiceTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *button;

- (void)configureWithBackground:(UIColor *)background highlighted:(UIColor *)highlighted symbol:(NSString *)symbol name:(NSString *)name;

@end
