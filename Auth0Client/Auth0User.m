//
//  Auth0User.m
//  Auth0Client
//
//  Created by Ezequiel Morito on 9/4/13.
//  Copyright (c) 2013 Auth0. All rights reserved.
//

#import "Auth0User.h"

@implementation Auth0User

@synthesize Auth0AccessToken = _Auth0AccessToken;
@synthesize IdToken = _IdToken;
@synthesize Profile = _Profile;

- (id)auth0User:(NSDictionary *)accountProperties
{
    if ((self = [super init])) {
        _Auth0AccessToken = [accountProperties objectForKey:@"access_token"];
        _IdToken = [accountProperties objectForKey:@"id_token"];
        _Profile = [[[accountProperties objectForKey:@"id_token"] componentsSeparatedByString: @"."] objectAtIndex: 1];
    }
    
    return self;
}

- (void)dealloc
{
    [_Auth0AccessToken release];
    [_IdToken release];
    [_Profile release];
    [super dealloc];
}

+ (Auth0User*)auth0User:(NSDictionary *)accountProperties
{
    return [[[Auth0User alloc] auth0User:accountProperties] autorelease];
}

@end
