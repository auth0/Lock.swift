#import "Auth0User.h"

@implementation Auth0User

@synthesize Auth0AccessToken = _auth0AccessToken;
@synthesize IdToken = _idToken;
@synthesize Profile = _profile;

- (id)initAuth0User:(NSDictionary *)accountProperties
{
    if ((self = [super init])) {
        _auth0AccessToken = [accountProperties objectForKey:@"access_token"];
        _idToken = [accountProperties objectForKey:@"id_token"];
        _profile = [accountProperties objectForKey:@"profile"];
    }
    
    return self;
}

- (void)dealloc
{
}

+ (Auth0User*)auth0User:(NSDictionary *)accountProperties
{
    return [[Auth0User alloc] initAuth0User:accountProperties];
}

@end
