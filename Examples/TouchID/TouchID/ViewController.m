//  ViewController.m
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

#import "ViewController.h"

#import <Lock/Lock.h>
#import <SimpleKeychain/A0SimpleKeychain+KeyPair.h>
#import <libextobjc/EXTScope.h>
#import <TouchIDAuth/A0RSAKeyExporter.h>

@interface ViewController ()
@property (strong, nonatomic) A0SimpleKeychain *keychain;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.keychain = [A0SimpleKeychain keychain];
    [self populateData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSString *idToken = [self.keychain stringForKey:@"id_token"];
    if (!idToken) {
        [self showLogin];
    }
}

- (void)logout:(id)sender {
    [self.keychain deleteEntryForKey:@"id_token"];
    [self showLogin];
}

- (void)showLogin {
    A0TouchIDLockViewController *controller = [[A0TouchIDLockViewController alloc] init];
    controller.closable = NO;
    @weakify(self);
    controller.onAuthenticationBlock = ^(A0UserProfile *profile, A0Token *token) {
        @strongify(self);
        [self.keychain setString:token.idToken forKey:@"id_token"];
        [self populateData];
        [self dismissViewControllerAnimated:YES completion:nil];
    };
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:nil];
}

- (NSString *)publicKeyTag {
    return [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".pubkey"];
}

- (NSString *)privateKeyTag {
    return [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".key"];
}

- (void)populateData {
    NSString *idToken = [self.keychain stringForKey:@"id_token"];
    if (idToken) {
        self.jwtLabel.text = idToken;
        A0RSAKeyExporter *exporter = [[A0RSAKeyExporter alloc] init];
        A0SimpleKeychain *keychain = [A0SimpleKeychain keychainWithService:@"TouchIDAuthentication"];
        NSData *pubKey = [keychain dataForRSAKeyWithTag:[self publicKeyTag]];
        NSData *privKey = [keychain dataForRSAKeyWithTag:[self privateKeyTag]];
        self.publicKeyTextView.text = [[NSString alloc] initWithData:[exporter exportPublicKey:pubKey] encoding:NSUTF8StringEncoding];
        self.privateKeyTextView.text = [privKey base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength|NSDataBase64EncodingEndLineWithCarriageReturn];
    }
}
@end
