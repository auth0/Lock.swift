//
//  A0ServicesView.h
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import <UIKit/UIKit.h>

typedef NSString *(^A0ServiceViewNameBlock)(NSInteger serviceIndex);
typedef void(^A0ServiceViewAuthenticateBlock)(NSInteger serviceIndex);

@interface A0ServicesView : UIView

@property (assign, nonatomic) NSInteger availableServicesCount;
@property (copy, nonatomic) A0ServiceViewNameBlock nameBlock;
@property (copy, nonatomic) A0ServiceViewAuthenticateBlock authenticateBlock;

@property (weak, nonatomic) IBOutlet UICollectionView *serviceCollectionView;

@end
