//
//  A0KeyboardHandler.h
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

#import <Foundation/Foundation.h>
#import "A0KeyboardEnabledView.h"

@interface A0KeyboardHandler : NSObject

- (void)start;
- (void)handleForView:(UIView<A0KeyboardEnabledView> *)view inView:(UIView *)containerView;
- (void)stop;

@end
