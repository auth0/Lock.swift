// A0ViewController.m
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "A0ViewController.h"

#import "A0UserProfileViewController.h"
#import <Auth0Client/A0AuthenticationViewController.h>
#import <Auth0Client/A0FacebookAuthentication.h>
#import <Auth0Client/A0TwitterAuthentication.h>
#import <Auth0Client/A0SocialAuthenticator.h>
#import <Auth0Client/A0UserProfile.h>
#import <libextobjc/EXTScope.h>

@interface A0ViewController ()

@property (strong, nonatomic) A0UserProfile *authInfo;

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
    A0AuthenticationViewController *controller = [[A0AuthenticationViewController alloc] init];
    @weakify(self);
    controller.authBlock = ^(A0AuthenticationViewController *controller, A0UserProfile *profile, A0Token *token) {
        NSLog(@"SUCCESS %@", profile);
        @strongify(self);
        self.authInfo = profile;
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
