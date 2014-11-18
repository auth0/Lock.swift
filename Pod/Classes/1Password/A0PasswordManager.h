// A0PasswordManager.h
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

#import <Foundation/Foundation.h>

#ifndef AUTH0_1PASSWORD
#define AUTH0_1PASSWORD 1
#endif

typedef void(^A0LoginInfoBlock)(NSString *username, NSString *password);

/**
 *  Class that handles the interaction with a Password Manager using iOS 8 extensions.
 *  The only supported password manager is 1Password.
 */
@interface A0PasswordManager : NSObject

/**
 *  URL String associated with the login info stored/retrieved. 
 *  It helps the user to locate their credentials.
 *  By default is the Bundle Indentifier of the app.
 */
@property (copy, nonatomic) NSString *loginURLString;

/**
 *  Returns a shared instance
 *
 *  @return shared instance
 */
+ (instancetype)sharedInstance;

/**
 *  Checks if a Password Manager extension is installed.
 *
 *  @return if the extension is available.
 */
+ (BOOL)hasPasswordManagerInstalled;

/**
 *  Fetches the login information from the password manager.
 *
 *  @param controller the UIViewController where to display the login info
 *  @param sender     action's trigger
 *  @param completion block called with the credentials.
 */
- (void)fillLoginInformationForViewController:(UIViewController *)controller
                                       sender:(id)sender
                                   completion:(A0LoginInfoBlock)completion;

/**
 *  Saves the login information in the password manager.
 *
 *  @param username   username to store. It can be nil
 *  @param password   password to store. It can be nil
 *  @param loginInfo  extra login information.
 *  @param controller the UIViewController where to display the login info
 *  @param sender     action's trigger
 *  @param completion block called with the credentials.
 */
- (void)saveLoginInformationForUsername:(NSString *)username
                               password:(NSString *)password
                              loginInfo:(NSDictionary *)loginInfo
                             controller:(UIViewController *)controller
                                 sender:(id)sender
                             completion:(A0LoginInfoBlock)completion;
@end
