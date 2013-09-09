//
//  Auth0User.m
//  Auth0Client
//
//  Created by Ezequiel Morito on 9/4/13.
//  Copyright (c) 2013 Auth0. All rights reserved.
//

#import "Auth0User.h"
#import "NSData+Base64.h"

@implementation Auth0User

@synthesize Auth0AccessToken = _auth0AccessToken;
@synthesize IdToken = _idToken;
@synthesize Profile = _profile;

- (id)auth0User:(NSDictionary *)accountProperties
{
    if ((self = [super init])) {
        _auth0AccessToken = [accountProperties objectForKey:@"access_token"];
        _idToken = [accountProperties objectForKey:@"id_token"];
        _profile = [self decodeBase64UrlEncode:[[[accountProperties objectForKey:@"id_token"] componentsSeparatedByString: @"."] objectAtIndex: 1]];
    }
    
    return self;
}

- (void)dealloc
{
    [_auth0AccessToken release];
    [_idToken release];
    [_profile release];
    [super dealloc];
}

+ (Auth0User*)auth0User:(NSDictionary *)accountProperties
{
    return [[[Auth0User alloc] auth0User:accountProperties] autorelease];
}

- (NSDictionary *)decodeBase64UrlEncode:(NSString *)encodedString
{
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"-"
                                                   withString:@"+"];
    encodedString = [encodedString stringByReplacingOccurrencesOfString:@"_"
                                                   withString:@"/"];
    
    NSUInteger len = [encodedString length];
    switch (len % 4) {
        case 0:
            break;
        case 2:
            encodedString = [encodedString stringByAppendingString:@"=="];
            break;
        case 3:
            encodedString = [encodedString stringByAppendingString:@"="];
            break;
            
        default:
            [NSException raise:@"Invalid Operation" format:@"Illegal base64url string!"];
            break;
    }
    
    NSData *data = [[[NSData alloc] initWithData:[NSData dataFromBase64String:encodedString]] autorelease];
    NSError* parseError;
    NSDictionary* parseData = [NSJSONSerialization
                               JSONObjectWithData:data
                               options:kNilOptions
                               error:&parseError];
    
    return parseData;
}

@end
