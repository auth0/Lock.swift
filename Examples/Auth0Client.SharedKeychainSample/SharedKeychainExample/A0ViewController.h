#import <UIKit/UIKit.h>

@interface A0ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *welcomeLabel;
@property (weak, nonatomic) IBOutlet UILabel *appLabel;
@property (weak, nonatomic) IBOutlet UILabel *jwtLabel;
@property (weak, nonatomic) IBOutlet UILabel *refreshTokenLabel;

- (IBAction)logout:(id)sender;

@end
