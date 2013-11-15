#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
- (IBAction)loginWithConnection:(id)sender;
- (IBAction)loginWithWidget:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *profileLabel;

@end
