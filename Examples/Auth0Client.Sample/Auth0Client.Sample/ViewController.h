#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (IBAction)loginWithConnection:(id)sender;
- (IBAction)loginWithWidget:(id)sender;
- (IBAction)loginWithUsernamePassword:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *profileLabel;
@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;

@end
