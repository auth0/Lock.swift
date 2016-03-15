// A0SettingsViewController.m
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

#import "A0SettingsViewController.h"

#import <SimpleKeychain/A0SimpleKeychain.h>
#import <Lock/Lock.h>
#import <TouchIDAuth/A0TouchIDAuthentication.h>

@interface A0SettingsViewController ()

@property (strong, nonatomic) A0Theme *mindjetTheme;

@end

@implementation A0SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    A0Theme *theme = [[A0Theme alloc] init];
    theme.statusBarStyle = UIStatusBarStyleLightContent;
    [theme registerColor:[UIColor colorWithWhite:1.000 alpha:0.300] forKey:A0ThemePrimaryButtonNormalColor];
    [theme registerColor:[UIColor colorWithWhite:0.500 alpha:0.300] forKey:A0ThemePrimaryButtonHighlightedColor];
    [theme registerColor:[UIColor clearColor] forKey:A0ThemeSecondaryButtonBackgroundColor];
    [theme registerColor:[UIColor whiteColor] forKey:A0ThemeSecondaryButtonTextColor];
    [theme registerColor:[UIColor whiteColor] forKey:A0ThemeTextFieldTextColor];
    [theme registerColor:[UIColor whiteColor] forKey:A0ThemeTitleTextColor];
    [theme registerColor:[UIColor whiteColor] forKey:A0ThemeSeparatorTextColor];
    [theme registerColor:[UIColor whiteColor] forKey:A0ThemeDescriptionTextColor];
    [theme registerColor:[UIColor whiteColor] forKey:A0ThemeCloseButtonTintColor];
    [theme registerColor:[UIColor colorWithWhite:1.000 alpha:0.700] forKey:A0ThemeTextFieldPlaceholderTextColor];
    [theme registerColor:[UIColor colorWithWhite:0.800 alpha:1.000] forKey:A0ThemeTextFieldIconColor];
    [theme registerColor:[UIColor clearColor] forKey:A0ThemeIconBackgroundColor];
    [theme registerImageWithName:@"mindjet-icon" bundle:[NSBundle mainBundle] forKey:A0ThemeIconImageName];
    [theme registerImageWithName:@"mindjet-bg" bundle:[NSBundle mainBundle] forKey:A0ThemeScreenBackgroundImageName];
    [theme registerColor:[UIColor colorWithWhite:1.000 alpha:0.300] forKey:A0ThemeTouchIDLockContainerBackgroundColor];
    self.mindjetTheme = theme;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger index = [defaults integerForKey:@"selected-theme"];
    self.themeControl.selectedSegmentIndex = index;
    [self themeSelected:self.themeControl];
}

- (IBAction)clearKeychain:(id)sender {
    [[A0SimpleKeychain keychainWithService:@"Auth0"] clearAll];
    A0IdentityProviderAuthenticator *authenticator = [[A0Lock sharedLock] identityProviderAuthenticator];
    [authenticator clearSessions];
}

- (IBAction)clearTouchID:(id)sender {
    [[[A0TouchIDAuthentication alloc] init] reset];
}

- (IBAction)clearSMS:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"auth0-lock-sms-phone"];
    [defaults removeObjectForKey:@"auth0-lock-sms-country-code"];
    [defaults synchronize];
}

- (void)themeSelected:(UISegmentedControl *)sender {
    if (sender.selectedSegmentIndex == 1) {
        [[A0Theme sharedInstance] registerTheme:self.mindjetTheme];
    } else {
        [[A0Theme sharedInstance] registerDefaultTheme];
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:sender.selectedSegmentIndex forKey:@"selected-theme"];
    [defaults synchronize];
}

@end
