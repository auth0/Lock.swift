//
//  A0CompositeAuthView.h
//  Pods
//
//  Created by Hernan Zalazar on 7/16/14.
//
//

#import <UIKit/UIKit.h>

#import "A0KeyboardEnabledView.h"
#import "A0ProgressDisplay.h"

@interface A0CompositeAuthView : UIView<A0KeyboardEnabledView, A0ProgressDisplay>

@property (weak, nonatomic) id<A0KeyboardEnabledView> delegate;

- (instancetype)initWithFirstView:(UIView *)firstView
                    andSecondView:(UIView *)secondView;
@end
