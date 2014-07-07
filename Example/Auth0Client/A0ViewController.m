//
//  A0ViewController.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 06/26/2014.
//  Copyright (c) 2014 Hernan Zalazar. All rights reserved.
//

#import "A0ViewController.h"

#import "A0UserProfileViewController.h"
#import <Auth0Client/A0LoginViewController.h>
#import <libextobjc/EXTScope.h>

@interface A0ViewController ()

@property (strong, nonatomic) NSDictionary *authInfo;
@end

@implementation A0ViewController

- (void)signIn:(id)sender {
    A0LoginViewController *controller = [[A0LoginViewController alloc] init];
    @weakify(self);
    controller.authBlock = ^(A0LoginViewController *controller, NSDictionary *authInfo) {
        NSLog(@"SUCCESS %@", authInfo);
        @strongify(self);
        self.authInfo = authInfo;
        [self performSegueWithIdentifier:@"ShowInfo" sender:self];
    };
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ShowInfo"]) {
        A0UserProfileViewController *controller = segue.destinationViewController;
        controller.authInfo = self.authInfo;
    }
}
@end
