//
//  A0ServicesView.h
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import <UIKit/UIKit.h>
#import "A0KeyboardEnabledView.h"
#import "A0ProgressDisplay.h"

typedef NSString *(^A0ServiceViewNameBlock)(NSInteger serviceIndex);
typedef void(^A0ServiceViewAuthenticateBlock)(NSInteger serviceIndex);

@interface A0ServicesView : UIView<A0KeyboardEnabledView, A0ProgressDisplay>

@property (assign, nonatomic) NSInteger availableServicesCount;
@property (copy, nonatomic) A0ServiceViewNameBlock nameBlock;
@property (copy, nonatomic) A0ServiceViewAuthenticateBlock authenticateBlock;

@property (weak, nonatomic) IBOutlet UICollectionView *serviceCollectionView;
@property (weak, nonatomic) IBOutlet UITableView *serviceTableView;

@end
