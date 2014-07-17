//
//  A0CompositeAuthView.h
//  Pods
//
//  Created by Hernan Zalazar on 7/16/14.
//
//

#import <UIKit/UIKit.h>

#import "A0KeyboardEnabledView.h"

@interface A0CompositeAuthView : UIView<A0KeyboardEnabledView>

@property (weak, nonatomic) id<A0KeyboardEnabledView> delegate;

@end
