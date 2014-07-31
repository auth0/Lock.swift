//
//  A0UserPasswordView.h
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import <UIKit/UIKit.h>
#import "A0KeyboardEnabledView.h"
#import "A0ProgressDisplay.h"

@class A0DatabaseLoginCredentialValidator, A0ProgressButton;

typedef void(^A0DatabaseLoginBlock)(NSString *username, NSString *password);
typedef void(^A0SwitchViewBlock)();

@interface A0UserPasswordView : UIView<A0KeyboardEnabledView, A0ProgressDisplay>

@property (copy, nonatomic) A0DatabaseLoginBlock loginBlock;
@property (copy, nonatomic) A0SwitchViewBlock signUpBlock;
@property (copy, nonatomic) A0SwitchViewBlock forgotPasswordBlock;

@property (strong, nonatomic) A0DatabaseLoginCredentialValidator *validator;

@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet A0ProgressButton *accessButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

@end
