//
//  A0UserPasswordView.h
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import <UIKit/UIKit.h>

#import "A0KeyboardEnabledView.h"

typedef void(^A0DatabaseLoginBlock)(NSString *username, NSString *password);
typedef void(^A0SwitchViewBlock)();
typedef BOOL(^A0DatabaseLoginValidateBlock)(NSString *username, NSString *password, NSError **error);

@interface A0UserPasswordView : UIView<A0KeyboardEnabledView>

@property (copy, nonatomic) A0DatabaseLoginBlock loginBlock;
@property (copy, nonatomic) A0SwitchViewBlock signUpBlock;
@property (copy, nonatomic) A0SwitchViewBlock forgotPasswordBlock;
@property (copy, nonatomic) A0DatabaseLoginValidateBlock validateBlock;


@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *accessButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@end
