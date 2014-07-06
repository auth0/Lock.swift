//
//  A0UserPasswordView.h
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import <UIKit/UIKit.h>

typedef void(^A0DatabaseLoginBlock)(NSString *username, NSString *password);

@interface A0UserPasswordView : UIView

@property (copy, nonatomic) A0DatabaseLoginBlock loginBlock;

@end
