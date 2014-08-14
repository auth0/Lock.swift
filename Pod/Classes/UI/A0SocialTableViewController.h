//
//  A0SocialTableViewController.h
//  Pods
//
//  Created by Hernan Zalazar on 8/14/14.
//
//

#import <UIKit/UIKit.h>
#import "A0KeyboardEnabledView.h"

@class A0Application, A0UserProfile;

@interface A0SocialTableViewController : UIViewController<A0KeyboardEnabledView>

@property (strong, nonatomic) A0Application *application;
@property (copy, nonatomic) void(^onLoginBlock)(A0UserProfile *profile);

@end
