//
//  A0WebViewController.h
//  Pods
//
//  Created by Hernan Zalazar on 9/24/14.
//
//

#import <UIKit/UIKit.h>

@class A0Token, A0UserProfile, A0Application, A0Strategy;

@interface A0WebViewController : UIViewController

@property (copy, nonatomic) void(^onAuthentication)(A0UserProfile *profile, A0Token *token);
@property (copy, nonatomic) void(^onFailure)(NSError *error);

- (instancetype)initWithApplication:(A0Application *)application strategy:(A0Strategy *)strategy;

@end
