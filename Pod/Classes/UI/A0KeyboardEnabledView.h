//
//  A0KeyboardEnabledView.h
//  Pods
//
//  Created by Hernan Zalazar on 7/16/14.
//
//

#import <Foundation/Foundation.h>

@protocol A0KeyboardEnabledView <NSObject>

@required

- (CGRect)rectToKeepVisibleInView:(UIView *)view;

- (void)hideKeyboard;

@end
