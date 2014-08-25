#import <Foundation/Foundation.h>

@interface Auth0User : NSObject
{
    NSString * _auth0AccessToken;
    NSString * _idToken;
    NSDictionary * _profile;
    NSString * _refreshToken;
}

@property (readonly) NSString *Auth0AccessToken;
@property (readonly) NSString *IdToken;
@property (readonly) NSDictionary *Profile;
@property (readonly) NSString *refreshToken;

+ (Auth0User *)auth0User:(NSDictionary *)accountProperties;

- (BOOL)hasIdToken;
- (BOOL)hasRefreshToken;

@end
