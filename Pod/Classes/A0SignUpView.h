//
//  A0SignUpView.h
//  Pods
//
//  Created by Hernan Zalazar on 7/12/14.
//
//

#import <UIKit/UIKit.h>

typedef void(^A0SignUpBlock)(NSString *username, NSString *password);
typedef void(^A0CancelBlock)();

@interface A0SignUpView : UIView

@property (copy, nonatomic) A0SignUpBlock signUpBlock;
@property (copy, nonatomic) A0CancelBlock cancelBlock;

@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

- (void)hideKeyboard;

@end
