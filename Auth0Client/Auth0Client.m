//
//  Auth0Client.m
//  Auth0Client
//
//  Created by Ezequiel Morito on 9/3/13.
//  Copyright (c) 2013 Auth0. All rights reserved.
//

#import "Auth0Client.h"
#import "Auth0WebViewController.h"
#import "Auth0User.h"

@implementation Auth0Client

@synthesize clientId = _clientId;
@synthesize clientSecret = _clientSecret;
@synthesize subDomain = _subDomain;
@synthesize auth0User = _auth0User;

NSString *AuthorizeUrl = @"https://%@.auth0.com/authorize?client_id=%@&scope=openid&redirect_uri=%@&response_type=token&connection=%@";
NSString *LoginWidgetUrl = @"https://%@.auth0.com/login/?client=%@&scope=openid&redirect_uri=%@&response_type=token";
NSString *ResourceOwnerEndpoint = @"https://%@.auth0.com/oauth/ro";
NSString *UserInfoEndpoint = @"https://%@.auth0.com/userinfo?%@";
NSString *DefaultCallback = @"https://%@.auth0.com/mobile";

- (id)auth0Client:(NSString *)sudDomain clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret
{
    if ((self = [super init])) {
        _clientId = [clientId copy];
        _subDomain = [sudDomain copy];
        _clientSecret = [clientSecret copy];
    }
    
    return self;
}

- (void)dealloc
{
    [_clientId release];
    [_subDomain release];
    [_clientSecret release];
    [_auth0User release];
    [super dealloc];
}

+ (Auth0Client*)auth0Client:(NSString *)subDomain clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret
{
    static Auth0Client *instance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{ instance = [[Auth0Client alloc] auth0Client:subDomain clientId:clientId clientSecret:clientSecret]; });
    
    return instance;
}

- (Auth0WebViewController*)getAuthenticator:(NSString *)connection withCompletionHandler:(void (^)(BOOL authenticated))block
{
    NSString *callback = [NSString stringWithFormat:DefaultCallback, _subDomain];
    NSString *url = [NSString stringWithFormat:LoginWidgetUrl,
                     _subDomain,
                     _clientId,
                     callback];
    
    if (connection != nil) {
        url = [NSString stringWithFormat:AuthorizeUrl,
                         _subDomain,
                         _clientId,
                         callback, connection];
    }
    
    Auth0WebViewController *webController = [[Auth0WebViewController alloc] initWithAuthorizeUrl:[[NSURL URLWithString:url] retain] returnUrl:callback allowsClose:NO withCompletionHandler:^(NSString *token, NSString * jwtToken){
        if (token) {
            
            [self getUserInfo:token withCompletionHandler:^(NSMutableDictionary* profile) {
                
                NSMutableDictionary* accountProperties = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                   token ?: [NSNull null], @"access_token",
                                                   jwtToken?: [NSNull null], @"id_token",
                                                   profile?: [NSNull null], @"profile",
                                                   nil];
                
                _auth0User = [Auth0User auth0User:accountProperties];
                block(true);
            }];
        }
        else {
            block(false);
        }
    }];
    
    return webController;
}

- (void)loginAsync:(UIViewController *)controller withCompletionHandler:(void (^)(BOOL authenticated))block
{
    [self loginAsync:controller connection:nil withCompletionHandler:(void (^)(BOOL authenticated))block];
}

- (void)loginAsync:(UIViewController *)controller connection:(NSString *)connection withCompletionHandler:(void (^)(BOOL authenticated))block
{
    Auth0WebViewController * webController = (Auth0WebViewController *)[self getAuthenticator:connection withCompletionHandler:^(BOOL  authenticated)
    {
        block(authenticated);
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [controller presentViewController:navController animated:YES completion:nil];
    [navController release];
}

- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection username:(NSString *)username password:(NSString *)password withCompletionHandler:(void (^)(BOOL authenticated))block
{
    NSString *url = [NSString stringWithFormat:ResourceOwnerEndpoint, _subDomain];
    NSURL *resourceUrl = [[[NSURL URLWithString:url] retain] autorelease];
    
    NSString *post =[NSString stringWithFormat:@"client_id=%@&client_secret=%@&connection=%@&username=%@&password=%@&grant_type=password&scope=openid", _clientId, _clientSecret, connection, username, password];
    
    
    NSData *postData = [ NSData dataWithBytes: [ post UTF8String ] length: [ post length ] ];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:resourceUrl];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error == nil) {
             NSError* parseError;
             NSMutableDictionary* parseData = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization
                                                                                 JSONObjectWithData:data
                                                                                 options:kNilOptions
                                                                                 error:&parseError]];
             
             NSString *accessToken = [parseData objectForKey:@"access_token"];
             
             if (accessToken) {
                 [self getUserInfo:accessToken withCompletionHandler:^(NSMutableDictionary* profile) {
                     [parseData setObject:profile forKey:@"profile"];
                     _auth0User = [Auth0User auth0User:parseData];
                     block(true);
                 }];
             }
         }
     }];
}

- (void)logout
{
    _auth0User = nil;
    [Auth0WebViewController clearCookies];
}

- (void)getUserInfo:(NSString *)accessToken withCompletionHandler:(void (^)(NSMutableDictionary* profile))block
{
    if (![accessToken hasPrefix:@"access_token"])
    {
        accessToken = [NSString stringWithFormat:@"access_token=%@", accessToken];
    }
    
    NSString *url = [NSString stringWithFormat:UserInfoEndpoint, _subDomain, accessToken];
    NSURL *enpoint = [[[NSURL URLWithString:url] retain] autorelease];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:enpoint];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         if (error == nil) {
             NSError* parseError;
             NSMutableDictionary* parseData = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization
                                                                                 JSONObjectWithData:data
                                                                                 options:kNilOptions
                                                                                 error:&parseError]];
             block(parseData);
         }
     }];
}

@end
