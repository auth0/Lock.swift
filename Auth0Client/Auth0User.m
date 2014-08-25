#import "Auth0User.h"

@implementation Auth0User

@synthesize Auth0AccessToken = _auth0AccessToken;
@synthesize IdToken = _idToken;
@synthesize Profile = _profile;
@synthesize refreshToken = _refreshToken;

- (id)initAuth0User:(NSDictionary *)accountProperties
{
    if ((self = [super init])) {
        _auth0AccessToken = [accountProperties objectForKey:@"access_token"];
        _idToken = [accountProperties objectForKey:@"id_token"];
        _profile = [accountProperties objectForKey:@"profile"];
        _refreshToken = [accountProperties objectForKey:@"refresh_token"];
    }
    
    return self;
}

- (void)dealloc
{
}

- (BOOL)hasIdToken {
    BOOL noIdToken = self.IdToken == (id)[NSNull null] || self.IdToken.length == 0;
    return !(noIdToken);
}

- (BOOL)hasRefreshToken {
    BOOL noRefreshToken = self.refreshToken == (id)[NSNull null] || self.refreshToken.length == 0;
    return !(noRefreshToken);
}

+ (Auth0User*)auth0User:(NSDictionary *)accountProperties
{
    return [[Auth0User alloc] initAuth0User:accountProperties];
}

@end
