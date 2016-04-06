// A0Lock.h
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "A0APIClientProvider.h"
#import "A0AuthenticatorProvider.h"

NS_ASSUME_NONNULL_BEGIN

@class A0APIClient, A0UserAPIClient, A0IdentityProviderAuthenticator, A0Telemetry;

FOUNDATION_EXPORT NSString * const A0ClientInfoHeaderName;
FOUNDATION_EXPORT NSString * const A0ClientInfoQueryParamName;

/**
 *  Main interface with Auth0 Lock for iOS.
 */
#if TARGET_OS_IPHONE
@interface A0Lock : NSObject<A0APIClientProvider, A0AuthenticatorProvider>
#else
@interface A0Lock : NSObject<A0APIClientProvider>
#endif

/**
 *  Auth0 account's client identifier
 */
@property (strong, readonly, nonatomic) NSString *clientId;
/**
 *  Auth0 account's domain URL
 */
@property (strong, readonly, nonatomic) NSURL *domainURL;
/**
 *  Auth0 account's application info URL. By default is Auth0 CDN (EU or US).
 */
@property (strong, readonly, nonatomic) NSURL *configurationURL;

/**
 *  Use Proof Key for Code Exchange for OAuth authorization requests. Default is NO
 */
@property (assign, nonatomic) BOOL usePKCE;

@property (strong, nullable, nonatomic) A0Telemetry *telemetry;

/**
 *  Initialise a new instance with values from Info.plist
 *
 *  @return an instance of A0Lock
 */
- (instancetype)init;

/**
 *  Initialise a new instance with a clientId and domain
 *
 *  @param clientId account clientId
 *  @param domain   account domain, it can be a full URL or just the domain name e.g.: samples.auth0.com.
 *
 *  @return an instance of A0Lock
 */
- (instancetype)initWithClientId:(NSString *)clientId
                          domain:(NSString *)domain;

/**
 *  Initialise a new instance with a clientId and domain
 *
 *  @param clientId account clientId
 *  @param domain   account domain, it can be a full URL or just the domain name e.g.: samples.auth0.com.
 *  @param configurationDomain domain where the account configuration can be obtained. By default https://cdn.auth0.com for US or https://cdn.eu.auth0.com for EU
 *
 *  @return an instance of A0Lock
 */
- (instancetype)initWithClientId:(NSString *)clientId
                          domain:(NSString *)domain
             configurationDomain:(NSString *)configurationDomain;

/**
 *  Creates a new instance of Lock with a clientId and domain
 *
 *  @param clientId account client identifier
 *  @param domain   account domain
 *
 *  @return a new instance
 */
+ (instancetype)newLockWithClientId:(NSString *)clientId
                             domain:(NSString *)domain;

/**
 *  Creates a new instance of Lock with a clientId, domain and configuration domain.
 *
 *  @param clientId            account client identifier
 *  @param domain              account domain
 *  @param configurationDomain domain where the account configuration can be obtained. By default https://cdn.auth0.com for US or https://cdn.eu.auth0.com for EU
 *
 *  @return a new instance
 */
+ (instancetype)newLockWithClientId:(NSString *)clientId
                             domain:(NSString *)domain
                configurationDomain:(NSString *)configurationDomain;


/**
 *  Creates a new instance of Lock using information stored in your Info.plist.
 *  These are the the valid entries:
 *      - Auth0ClientId: Your app's client identifier in Auth0.
 *      - Auth0Domain: Your app's domain name or url in Auth0. e.g: samples.auth0.com or https://samples.auth0.com
 *      - Auth0ConfigurationDomain: Your app's configuration domain name or url where we get yout app configuration. This value is optional and will default to Auth0 CDN.
 *
 *  @return a new instance
 */
+ (instancetype)newLock;

/**
 *  Returns a shared instance of Lock with credentials obtained from Info.plist.
 *  These are the the valid entries:
 *      - Auth0ClientId: Your app's client identifier in Auth0.
 *      - Auth0Domain: Your app's domain name or url in Auth0. e.g: samples.auth0.com or https://samples.auth0.com
 *      - Auth0ConfigurationDomain: Your app's configuration domain name or url where we get yout app configuration. This value is optional and will default to Auth0 CDN.
 *
 *  @return a shared instance
 */
+ (instancetype)sharedLock;

/**
 *  Auth0 Authentication API client.
 *
 *  @return an API client
 */
- (A0APIClient *)apiClient;

/**
 *  API client to make request to Auth0 authorized by the id_token
 *
 *  @param idToken user's id_token
 *
 *  @return an new API client
 */
- (A0UserAPIClient *)newUserAPIClientWithIdToken:(NSString *)idToken;

#if TARGET_OS_IPHONE
/**
 *  Handle URL received from AppDelegate when app is called from a third party app at the end of an authentication flow.
 *
 *
 *  @param url               url used by third party app to call the application
 *  @param sourceApplication caller name
 *
 *  @return if we can handle the url or not.
 */
- (BOOL)handleURL:(NSURL *)url sourceApplication:(nullable NSString *)sourceApplication;

/**
 *  Register IdP authenticator that will be used for Social & Enterprise connections.
 *  By default all Social & Enterprise authentications are performed by using the web flow with Safari but you can plug
 *  your own authenticator for a connection. e.g.: you can register A0FacebookAuthenticator in order to login with FB native SDK.
 *
 *  @param authenticators list of authenticators to register. Must be subclasses of A0BaseAuthenticator
 *  @see A0BaseAuthenticator
 */
- (void)registerAuthenticators:(NSArray *)authenticators;

/**
 *  Remove all stored sessions of any IdP in your application.
 *  If the user logged in using Safari, those sessions will not be cleaned.
 */
- (void)clearSessions;

/**
 *  Handle application launched event.
 *
 *  @param launchOptions dictionary with launch options
 */
- (void)applicationLaunchedWithOptions:(nullable NSDictionary *)launchOptions;

/**
 *  Ask Lock to continue a user activity
 *
 *  @param userActivity       to continue
 *  @param restorationHandler to call if objects are created to perform the task
 *
 *  @return YES to indicate that Lock handled the activity or NO to let iOS know that Lock did not handle the activity.
 */
- (BOOL)continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray * _Nullable))restorationHandler;

#endif

@end

NS_ASSUME_NONNULL_END
