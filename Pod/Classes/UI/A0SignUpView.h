//
//  A0SignUpView.h
//  Pods
//
//  Created by Hernan Zalazar on 7/12/14.
//
//

#import <UIKit/UIKit.h>

#import "A0KeyboardEnabledView.h"
#import "A0ProgressDisplay.h"

@class A0SignUpCredentialValidator, A0ProgressButton;

typedef void(^A0SignUpBlock)(NSString *username, NSString *password);
typedef void(^A0CancelBlock)();

@interface A0SignUpView : UIView<A0KeyboardEnabledView, A0ProgressDisplay>

@property (copy, nonatomic) A0SignUpBlock signUpBlock;
@property (copy, nonatomic) A0CancelBlock cancelBlock;

@property (strong, nonatomic) A0SignUpCredentialValidator *validator;

@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet A0ProgressButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
