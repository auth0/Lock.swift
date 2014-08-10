//
//  A0LoginViewController.h
//  Pods
//
//  Created by Hernan Zalazar on 6/29/14.
//
//

#import <UIKit/UIKit.h>

@class A0LoginViewController, A0UserProfile;

typedef void(^A0AuthBlock)(A0LoginViewController *controller, A0UserProfile *profile);

@interface A0LoginViewController : UIViewController

@property (copy, nonatomic) A0AuthBlock authBlock;
@property (assign, nonatomic) BOOL usesEmail;

- (IBAction)hideKeyboard:(id)sender;

@end
