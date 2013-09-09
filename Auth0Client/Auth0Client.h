//
//  Auth0Client.h
//  Auth0Client
//
//  Created by Ezequiel Morito on 9/3/13.
//  Copyright (c) 2013 Auth0. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Auth0User.h"

@interface Auth0Client : NSObject
{
    Auth0User * _auth0User;
@private
    NSString * _clientId;
    NSString * _clientSecret;
    NSString * _subDomain;
}

@property (readonly) NSString *clientId;
@property (readonly) NSString *clientSecret;
@property (readonly) NSString *subDomain;
@property (readonly) Auth0User *auth0User;

+ (Auth0Client *)auth0Client:(NSString *)subDomain clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

- (UIViewController *)getAuthenticator:(NSString *)connection withCompletionHandler:(void (^)(BOOL authenticated))block;

- (void)loginAsync:(UIViewController*)controller withCompletionHandler:(void (^)(BOOL authenticated))block;

- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection withCompletionHandler:(void (^)(BOOL authenticated))block;

- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection username:(NSString *)username password:(NSString *)password withCompletionHandler:(void (^)(BOOL authenticated))block;
@end
