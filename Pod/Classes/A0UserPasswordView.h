//
//  A0UserPasswordView.h
//  Pods
//
//  Created by Hernan Zalazar on 6/30/14.
//
//

#import <UIKit/UIKit.h>

typedef void(^A0DatabaseLoginBlock)(NSString *username, NSString *password);
typedef void(^A0SwitchViewBlock)();

@interface A0UserPasswordView : UIView

@property (copy, nonatomic) A0DatabaseLoginBlock loginBlock;
@property (copy, nonatomic) A0SwitchViewBlock signUpBlock;
@property (copy, nonatomic) A0SwitchViewBlock forgotPasswordBlock;

@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *accessButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;

- (void)hideKeyboard;

@end
