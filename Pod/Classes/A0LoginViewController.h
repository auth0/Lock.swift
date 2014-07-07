//
//  A0LoginViewController.h
//  Pods
//
//  Created by Hernan Zalazar on 6/29/14.
//
//

#import <UIKit/UIKit.h>

@class A0LoginViewController;

typedef void(^A0AuthBlock)(A0LoginViewController *controller, NSDictionary *authDictionary);

@interface A0LoginViewController : UIViewController

@property (copy, nonatomic) A0AuthBlock authBlock;

- (IBAction)hideKeyboard:(id)sender;

@end
