//
//  Auth0User.h
//  Auth0Client
//
//  Created by Ezequiel Morito on 9/4/13.
//  Copyright (c) 2013 Auth0. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Auth0User : NSData
{
    NSString * _auth0AccessToken;
    NSString * _idToken;
    NSDictionary * _profile;
}

@property (readonly) NSString *Auth0AccessToken;
@property (readonly) NSString *IdToken;
@property (readonly) NSDictionary *Profile;

+ (Auth0User *)auth0User:(NSDictionary *)accountProperties;

@end
