//
//  A0RecoverPasswordView.h
//  Pods
//
//  Created by Hernan Zalazar on 7/14/14.
//
//

#import <UIKit/UIKit.h>

typedef void(^A0RecoverPasswordBlock)(NSString *username, NSString *newPassword);
typedef void(^A0CancelBlock)();

@interface A0RecoverPasswordView : UIView

@property (copy, nonatomic) A0RecoverPasswordBlock recoverBlock;
@property (copy, nonatomic) A0CancelBlock cancelBlock;

@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *repeatPasswordTextField;
@property (weak, nonatomic) IBOutlet UIButton *recoverButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (void)hideKeyboard;

@end
