//
//  Auth0User.h
//  Auth0Client
//
//  Created by Ezequiel Morito on 9/4/13.
//  Copyright (c) 2013 Auth0. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Auth0User : NSData

@property (readonly) NSString *Auth0AccessToken;
@property (readonly) NSString *IdToken;
@property (readonly) NSData *Profile;

+ (Auth0User *)auth0User:(NSDictionary *)accountProperties;

@end
