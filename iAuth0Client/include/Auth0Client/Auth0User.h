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
