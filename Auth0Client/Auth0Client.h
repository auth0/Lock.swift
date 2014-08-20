#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Auth0User.h"

@interface Auth0Client : NSObject
{
    Auth0User * _auth0User;
@private
    NSString * _clientId;
    NSString * _domain;
    NSString * _scope;
    BOOL _offlineAccess;
}

@property (readonly) NSString *clientId;
@property (readonly) NSString *domain;
@property (readonly) NSString *scope;
@property (readonly) Auth0User *auth0User;
@property (readonly) BOOL offlineAccess;

+ (Auth0Client *)auth0Client:(NSString *)domain clientId:(NSString *)clientId offlineAccess:(BOOL)offlineAccess;

+ (Auth0Client *)auth0Client:(NSString *)domain clientId:(NSString *)clientId scope:(NSString *)scope offlineAccess:(BOOL)offlineAccess;

- (UIViewController *)getAuthenticator:(NSString *)connection scope:(NSString *)scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block;

- (void)loginAsync:(UIViewController*)controller withCompletionHandler:(void (^)(NSMutableDictionary* error))block;

- (void)loginAsync:(UIViewController*)controller scope:(NSString *)scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block;

- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection withCompletionHandler:(void (^)(NSMutableDictionary* error))block;

- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection scope:(NSString *)scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block;

- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection username:(NSString *)username password:(NSString *)password scope:(NSString *)scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block;

- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection username:(NSString *)username password:(NSString *)password withCompletionHandler:(void (^)(NSMutableDictionary* error))block;

- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection accessToken:(NSString *)accessToken scope:(NSString *)scope withCompletionHandler:(void (^)(NSMutableDictionary* error))block;

- (void)loginAsync:(UIViewController*)controller connection:(NSString *)connection accessToken:(NSString *)accessToken withCompletionHandler:(void (^)(NSMutableDictionary* error))block;

- (void)logout;

- (void)getDelegationToken:(NSString *)targetClientId withCompletionHandler:(void (^)(NSMutableDictionary* delegationResult))block;

- (void)getDelegationToken:(NSString *)targetClientId options:(NSMutableDictionary *)options withCompletionHandler:(void (^)(NSMutableDictionary* delegationResult))block;

- (void)getUserInfoWithAccessToken:(NSString *)accessToken withCompletionHandler:(void (^)(NSMutableDictionary* profile))block;
- (void)getUserInfoWithIdToken:(NSString *)idToken withCompletionHandler:(void (^)(NSMutableDictionary* profile))block;

@end
