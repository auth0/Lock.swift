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
#import <Auth0Client/A0FacebookAuthentication.h>
#import <Auth0Client/A0TwitterAuthentication.h>
#import <Auth0Client/A0SocialAuthenticator.h>
#import <libextobjc/EXTScope.h>

@interface A0ViewController ()

@property (strong, nonatomic) NSDictionary *authInfo;

@end

@implementation A0ViewController

- (void)signIn:(id)sender {
    A0TwitterAuthentication *twitter = [A0TwitterAuthentication newAuthenticationWithKey:@"o8HFHDVB1yEVXSvxSO5F1WuKP"
                                                                                      andSecret:@"v04WbftIrRJENoTFAr91eCEgLmVCDcaEm5brZlLJtS0ccJjHIz"
                                                                                    callbackURL:[NSURL URLWithString:@"com.auth0.Auth0Client://twitter-auth"]];
    A0FacebookAuthentication *facebook = [A0FacebookAuthentication newAuthentication];
    [[A0SocialAuthenticator sharedInstance] registerSocialAuthenticatorProviders:@[
                                                                                   twitter,
                                                                                   facebook,
                                                                                   ]];
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
