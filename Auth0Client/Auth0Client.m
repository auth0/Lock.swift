#import "Auth0Client.h"
#import "Auth0WebViewController.h"
#import "Auth0User.h"

@implementation Auth0Client

@synthesize clientId = _clientId;
@synthesize domain = _domain;
@synthesize scope = _scope;
@synthesize auth0User = _auth0User;
@synthesize offlineAccess = _offlineAccess;

NSString *AuthorizeUrl = @"https://%@/authorize?client_id=%@&scope=%@&redirect_uri=%@&response_type=token&connection=%@";
NSString *LoginWidgetUrl = @"https://%@/login/?client=%@&scope=%@&redirect_uri=%@&response_type=token";
NSString *ResourceOwnerEndpoint = @"https://%@/oauth/ro";
NSString *ResourceOwnerBody = @"client_id=%@&connection=%@&username=%@&password=%@&grant_type=password&scope=%@";
NSString *IdPAccessTokenEndpoint = @"https://%@/oauth/access_token";
NSString *IdPAccessTokenBody = @"client_id=%@&connection=%@&access_token=%@&scope=%@";
NSString *DelegationEndpoint = @"https://%@/delegation";
NSString *DelegationBody = @"grant_type=urn:ietf:params:oauth:grant-type:jwt-bearer&target=%@&client_id=%@";
NSString *UserInfoEndpoint = @"https://%@/userinfo";
NSString *TokenInfoEndpoint = @"https://%@/tokeninfo";
NSString *DefaultCallback = @"https://%@/mobile";

- (id)initAuth0Client:(NSString *)domain clientId:(NSString *)clientId offlineAccess:(BOOL)offlineAccess
{
    return [self initAuth0Client:domain clientId:clientId scope:@"openid" offlineAccess:offlineAccess];
}

- (id)initAuth0Client:(NSString *)domain clientId:(NSString *)clientId scope:(NSString *)scope offlineAccess:(BOOL)offlineAccess
{
    if ((self = [super init])) {
        _clientId = [clientId copy];
        _domain = [domain copy];
        _scope = [scope copy];
        _offlineAccess = offlineAccess;
    }
    
    return self;
}

- (void)dealloc
{
}

+ (Auth0Client*)auth0Client:(NSString *)domain clientId:(NSString *)clientId offlineAccess:(BOOL)offlineAccess
{
    static Auth0Client *instance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{ instance = [[Auth0Client alloc] initAuth0Client:domain clientId:clientId offlineAccess:offlineAccess]; });
    
    return instance;
}

+ (Auth0Client*)auth0Client:(NSString *)domain clientId:(NSString *)clientId scope:(NSString *)scope offlineAccess:(BOOL)offlineAccess
{
    static Auth0Client *instance = nil;
    static dispatch_once_t predicate;
    
    dispatch_once(&predicate, ^{ instance = [[Auth0Client alloc] initAuth0Client:domain clientId:clientId scope:scope offlineAccess:offlineAccess]; });
    
    return instance;
}

- (Auth0WebViewController*)getAuthenticator:(NSString *)connection scope:(NSString *)scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block
{
    NSString *loginScope = [self requestScopeWithDefaultScope:scope];
    NSString *callback = [NSString stringWithFormat:DefaultCallback, _domain];
    NSString *url = [NSString stringWithFormat:LoginWidgetUrl,
                     _domain,
                     _clientId,
                     [self urlEncode:loginScope],
                     callback];
    
    if (connection != nil) {
        url = [NSString stringWithFormat:AuthorizeUrl,
                         _domain,
                         _clientId,
                         [self urlEncode:loginScope],
                         callback, connection];
    }

    if (self.offlineAccess) {
        url = [url stringByAppendingFormat:@"&device=%@", [self urlEncode:[[UIDevice currentDevice] name]]];
    }
    Auth0WebViewController *webController = [[Auth0WebViewController alloc] initWithAuthorizeUrl:[NSURL URLWithString:url] returnUrl:callback allowsClose:YES withCompletionHandler:^(NSString *token, NSString * jwtToken, NSString *refreshToken, NSString * error){
        if (token) {
            
            [self getUserInfoWithAccessToken:token withCompletionHandler:^(NSMutableDictionary* profile) {
                
                NSMutableDictionary* accountProperties = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                                   token ?: [NSNull null], @"access_token",
                                                   jwtToken?: [NSNull null], @"id_token",
                                                   profile?: [NSNull null], @"profile",
                                                   refreshToken?: [NSNull null], @"refresh_token",
                                                   nil];
                
                _auth0User = [Auth0User auth0User:accountProperties];
                block(nil);
            }];
        }
        else {
            NSString * errorMsg = error ? error : @"Authentication Failed";
            block([[NSMutableDictionary alloc] initWithObjectsAndKeys: errorMsg, @"error", nil]);
        }
    }];
    
    return webController;
}

// Login with widget
- (void)loginAsync:(UIViewController *)controller withCompletionHandler:(void (^)(NSMutableDictionary* error))block
{
    [self loginAsync:controller connection:nil scope:_scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block];
}

- (void)loginAsync:(UIViewController *)controller scope:(NSString *)scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block
{
    [self loginAsync:controller connection:nil scope:scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block];
}

// Login with specified connection
- (void)loginAsync:(UIViewController *)controller connection:(NSString *)connection withCompletionHandler:(void (^)(NSMutableDictionary* error))block
{
    [self loginAsync:controller connection:connection scope:_scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block];
}

- (void)loginAsync:(UIViewController *)controller connection:(NSString *)connection scope:(NSString *)scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block
{
    Auth0WebViewController * webController = (Auth0WebViewController *)[self getAuthenticator:connection scope:scope withCompletionHandler:^(NSMutableDictionary* error)
    {
        [controller dismissViewControllerAnimated:YES completion:nil];
        block(error);
    }];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:webController];
    navController.navigationBar.barStyle = UIBarStyleBlack;
    
    [controller presentViewController:navController animated:YES completion:nil];
}

// Login with username/password
- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection username:(NSString *)username password:(NSString *)password withCompletionHandler:(void (^)(NSMutableDictionary* error))block
{
    [self loginAsync:controller connection:connection username:username password:password scope:_scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block];
}

- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection username:(NSString *)username password:(NSString *)password scope:(NSString *)scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block;
{
    NSString *url = [NSString stringWithFormat:ResourceOwnerEndpoint, _domain];
    NSURL *resourceUrl = [NSURL URLWithString:url];
    NSString *loginScope = [self requestScopeWithDefaultScope:scope];

    NSString *postBody =[NSString stringWithFormat:ResourceOwnerBody, _clientId, [self urlEncode:connection], [self urlEncode:username], [self urlEncode:password], [self urlEncode:loginScope]];
    if (self.offlineAccess) {
        postBody = [postBody stringByAppendingFormat:@"&device=%@", [self urlEncode:[[UIDevice currentDevice] name]]];
    }
    NSData *postData = [NSData dataWithBytes: [postBody UTF8String] length: [postBody length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:resourceUrl];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
		 if (error && !data) {
			 block([[error userInfo] mutableCopy]);
			 return;
		 }
		 
         NSError* parseError;
         NSMutableDictionary* parseData = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseError]];
         
		 if (parseError) {
			 block([[parseError userInfo] mutableCopy]);
			 return;
		 }
		 
         NSString *accessToken = [parseData objectForKey:@"access_token"];
		 
		 if (!accessToken) {
			 block(parseData);
			 return;
		 }
		 
		 [self getUserInfoWithAccessToken:accessToken withCompletionHandler:^(NSMutableDictionary* profile) {
			 [parseData setObject:profile forKey:@"profile"];
			 _auth0User = [Auth0User auth0User:parseData];
			 block(nil);
		 }];
     }];
}

// Login with Identity Provider access_token
- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection accessToken:(NSString *)accessToken withCompletionHandler:(void (^)(NSMutableDictionary* error))block
{
    [self loginAsync:controller connection:connection accessToken:accessToken scope:_scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block];
}

- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection accessToken:(NSString *)accessToken scope:(NSString *)scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block;
{
    NSString *url = [NSString stringWithFormat:IdPAccessTokenEndpoint, _domain];
    NSURL *resourceUrl = [NSURL URLWithString:url];
    
    NSString *postBody =[NSString stringWithFormat:IdPAccessTokenBody, _clientId, [self urlEncode:connection], [self urlEncode:accessToken], [self urlEncode:scope]];
    
    NSData *postData = [NSData dataWithBytes: [postBody UTF8String] length: [postBody length]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:resourceUrl];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
		 if (error && !data) {
			 block([[error userInfo] mutableCopy]);
			 return;
		 }
		 
         NSError* parseError;
         NSMutableDictionary* parseData = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&parseError]];
         
		 if (parseError) {
			 block([[parseError userInfo] mutableCopy]);
			 return;
		 }
		 
         NSString *auth0_accessToken = [parseData objectForKey:@"access_token"];
		 
		 if (!auth0_accessToken) {
			 block(parseData);
			 return;
		 }
		 
		 [self getUserInfoWithAccessToken:auth0_accessToken withCompletionHandler:^(NSMutableDictionary* profile) {
			 [parseData setObject:profile forKey:@"profile"];
			 _auth0User = [Auth0User auth0User:parseData];
			 block(nil);
		 }];
     }];
}

// Delegation Token
- (void)getDelegationToken:(NSString *)targetClientId withCompletionHandler:(void (^)(NSMutableDictionary* delegationResult))block
{
    [self getDelegationToken:targetClientId options:[NSMutableDictionary dictionary] withCompletionHandler:(void (^)(NSMutableDictionary* delegationResult))block];
}

- (void)getDelegationToken:(NSString *)targetClientId options:(NSMutableDictionary *)options withCompletionHandler:(void (^)(NSMutableDictionary* delegationResult))block
{
    NSString *id_token = [options objectForKey:@"id_token"];
    [options removeObjectForKey:@"id_token"];
    NSString *refresh_token = [options objectForKey:@"refresh_token"];
    [options removeObjectForKey:@"refresh_token"];

    if (refresh_token == nil && id_token == nil && ![self.auth0User hasIdToken] && ![self.auth0User hasRefreshToken]) {
        [NSException raise:@"Empty id_token or refresh_token" format:@"You need to login first or specify a value for id_token or refresh_token parameter."];
    }

    if (refresh_token == nil) {
        refresh_token = self.auth0User.refreshToken;
    }

    if (id_token == nil) {
        id_token = self.auth0User.IdToken;
    }

    if (refresh_token) {
        options[@"refresh_token"] = refresh_token;
    } else {
        options[@"id_token"] = id_token;
    }

    NSString *url = [NSString stringWithFormat:DelegationEndpoint, _domain];
    NSURL *delegationUrl = [NSURL URLWithString:url];
    
    NSString *postBody = [NSString stringWithFormat:DelegationBody, targetClientId, _clientId];
    
    for (NSString* key in options) {
        id value = [options objectForKey:key];
        postBody = [postBody stringByAppendingString:[NSString stringWithFormat:@"&%@=%@", key, [self urlEncode:value]]];
    }
    
    NSData *postData = [ NSData dataWithBytes: [ postBody UTF8String ] length: [ postBody length ] ];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:delegationUrl];
    [request setHTTPMethod:@"POST"];
    
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSError* parseError;
         NSMutableDictionary* parseData = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization
                                                                                           JSONObjectWithData:data
                                                                                           options:kNilOptions
                                                                                           error:&parseError]];
         
         block(parseData);
     }];
}

// Logout
- (void)logout
{
    _auth0User = nil;
    [Auth0WebViewController clearCookies];
}

// Helper methods
- (void)getUserInfoWithAccessToken:(NSString *)accessToken withCompletionHandler:(void (^)(NSMutableDictionary* profile))block
{
    if (![accessToken hasPrefix:@"access_token"])
    {
        accessToken = [NSString stringWithFormat:@"access_token=%@", accessToken];
    }
    
    NSString *url = [NSString stringWithFormat:UserInfoEndpoint, _domain];
    url = [url stringByAppendingFormat:@"?%@", accessToken];
    NSURL *enpoint = [NSURL URLWithString:url];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:enpoint];
    [request setHTTPMethod:@"GET"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSError* parseError;
         NSMutableDictionary* parseData = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization
                                                                                           JSONObjectWithData:data
                                                                                           options:kNilOptions
                                                                                           error:&parseError]];
         block(parseData);
     }];
}

- (void)getUserInfoWithIdToken:(NSString *)idToken withCompletionHandler:(void (^)(NSMutableDictionary* profile))block
{
    if (![idToken hasPrefix:@"id_token"])
    {
        idToken = [NSString stringWithFormat:@"id_token=%@", [self urlEncode:idToken]];
    }

    NSString *url = [NSString stringWithFormat:TokenInfoEndpoint, _domain];

    NSURL *enpoint = [NSURL URLWithString:url];

    NSData *postData = [ NSData dataWithBytes: [ idToken UTF8String ] length: [ idToken length ] ];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:enpoint];
    [request setHTTPMethod:@"POST"];

    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody:postData];

    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
     {
         NSError* parseError;
         NSMutableDictionary* parseData = [[NSMutableDictionary alloc] initWithDictionary:[NSJSONSerialization
                                                                                           JSONObjectWithData:data
                                                                                           options:kNilOptions
                                                                                           error:&parseError]];
         block(parseData);
     }];
}

-(NSString *)urlEncode:(NSString *)url {
	NSString *escapedString =
        (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
            NULL,
            (__bridge CFStringRef) url,
            NULL,
            CFSTR("!*'();:@&=+$,/?%#[]\" "),
            kCFStringEncodingUTF8));
    
    return escapedString;
}

- (NSString *)requestScopeWithDefaultScope:(NSString *)defaultScope {
    NSString *scope = [defaultScope copy];
    if (self.offlineAccess && [scope rangeOfString:@"offline_access"].location == NSNotFound) {
        scope = [scope stringByAppendingString:@" offline_access"];
    }
    return scope;
}
@end
