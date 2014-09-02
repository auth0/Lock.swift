//
//  A0CredentialFieldView.h
//  Pods
//
//  Created by Hernan Zalazar on 9/2/14.
//
//

#import <UIKit/UIKit.h>

@interface A0CredentialFieldView : UIView

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (assign, nonatomic) BOOL invalid;

@end
