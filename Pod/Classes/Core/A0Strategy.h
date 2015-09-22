// A0Strategy.h
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
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

NS_ASSUME_NONNULL_BEGIN

///----------------------------------------
/// @name Strategy Names
///----------------------------------------

FOUNDATION_EXPORT NSString * const A0StrategyNameGoogleOpenId;
FOUNDATION_EXPORT NSString * const A0StrategyNameGoogleApps;
FOUNDATION_EXPORT NSString * const A0StrategyNameGooglePlus;
FOUNDATION_EXPORT NSString * const A0StrategyNameFacebook;
FOUNDATION_EXPORT NSString * const A0StrategyNameWindowsLive;
FOUNDATION_EXPORT NSString * const A0StrategyNameLinkedin;
FOUNDATION_EXPORT NSString * const A0StrategyNameGithub;
FOUNDATION_EXPORT NSString * const A0StrategyNamePaypal;
FOUNDATION_EXPORT NSString * const A0StrategyNameTwitter;
FOUNDATION_EXPORT NSString * const A0StrategyNameAmazon;
FOUNDATION_EXPORT NSString * const A0StrategyNameVK;
FOUNDATION_EXPORT NSString * const A0StrategyNameYandex;
FOUNDATION_EXPORT NSString * const A0StrategyNameOffice365;
FOUNDATION_EXPORT NSString * const A0StrategyNameWaad;
FOUNDATION_EXPORT NSString * const A0StrategyNameADFS;
FOUNDATION_EXPORT NSString * const A0StrategyNameSAMLP;
FOUNDATION_EXPORT NSString * const A0StrategyNamePingFederate;
FOUNDATION_EXPORT NSString * const A0StrategyNameIP;
FOUNDATION_EXPORT NSString * const A0StrategyNameMSCRM;
FOUNDATION_EXPORT NSString * const A0StrategyNameActiveDirectory;
FOUNDATION_EXPORT NSString * const A0StrategyNameCustom;
FOUNDATION_EXPORT NSString * const A0StrategyNameAuth0;
FOUNDATION_EXPORT NSString * const A0StrategyNameAuth0LDAP;
FOUNDATION_EXPORT NSString * const A0StrategyName37Signals;
FOUNDATION_EXPORT NSString * const A0StrategyNameBox;
FOUNDATION_EXPORT NSString * const A0StrategyNameSalesforce;
FOUNDATION_EXPORT NSString * const A0StrategyNameSalesforceSandbox;
FOUNDATION_EXPORT NSString * const A0StrategyNameFitbit;
FOUNDATION_EXPORT NSString * const A0StrategyNameBaidu;
FOUNDATION_EXPORT NSString * const A0StrategyNameRenRen;
FOUNDATION_EXPORT NSString * const A0StrategyNameYahoo;
FOUNDATION_EXPORT NSString * const A0StrategyNameAOL;
FOUNDATION_EXPORT NSString * const A0StrategyNameYammer;
FOUNDATION_EXPORT NSString * const A0StrategyNameWordpress;
FOUNDATION_EXPORT NSString * const A0StrategyNameDwolla;
FOUNDATION_EXPORT NSString * const A0StrategyNameShopify;
FOUNDATION_EXPORT NSString * const A0StrategyNameMiicard;
FOUNDATION_EXPORT NSString * const A0StrategyNameSoundcloud;
FOUNDATION_EXPORT NSString * const A0StrategyNameEBay;
FOUNDATION_EXPORT NSString * const A0StrategyNameEvernote;
FOUNDATION_EXPORT NSString * const A0StrategyNameEvernoteSandbox;
FOUNDATION_EXPORT NSString * const A0StrategyNameSharepoint;
FOUNDATION_EXPORT NSString * const A0StrategyNameWeibo;
FOUNDATION_EXPORT NSString * const A0StrategyNameInstagram;
FOUNDATION_EXPORT NSString * const A0StrategyNameTheCity;
FOUNDATION_EXPORT NSString * const A0StrategyNameTheCitySandbox;
FOUNDATION_EXPORT NSString * const A0StrategyNamePlanningCenter;
FOUNDATION_EXPORT NSString * const A0StrategyNameSMS;
FOUNDATION_EXPORT NSString * const A0StrategyNameEmail;

///----------------------------------------
/// @name Social Strategy parameter names
///----------------------------------------

/**
 *  Social Authentication token parameter
 */
FOUNDATION_EXPORT NSString * const A0StrategySocialTokenParameter;
/**
 *  Social Authentication token secret parameter
 */
FOUNDATION_EXPORT NSString * const A0StrategySocialTokenSecretParameter;
/**
 *  Social Authentication user id parameter
 */
FOUNDATION_EXPORT NSString * const A0StrategySocialUserIdParameter;

/**
 *  Types of Strategy.
 */
typedef NS_ENUM(NSUInteger, A0StrategyType) {
    /**
     *  Twitter, Facebook, Linkedin, Google+, Weibo, etc.
     */
    A0StrategyTypeSocial = 0,
    /**
     *  Username and Password
     */
    A0StrategyTypeDatabase,
    /**
     *  LDAP, Sharepoint, IP, etc.
     */
    A0StrategyTypeEnterprise,
    /**
     *  Passwordless authentication like SMS or Email
     */
    A0StrategyTypePasswordless
};

/**
 *  `A0Strategy` represents an enabled connection in your Auth0 application
 */
@interface A0Strategy : NSObject

/**
 *  Strategy name
 */
@property (readonly, nonatomic) NSString *name;

/**
 *  List of connections associated to this strategy.
 *  @see A0Connection
 */
@property (readonly, nonatomic) NSArray *connections;

/**
 *  Type of the strategy
 */
@property (readonly, nonatomic) A0StrategyType type;

/**
 *  If the strategy should authenticate with the `/ro` endpoint.
 */
@property (readonly, nonatomic) BOOL useResourceOwnerEndpoint;

/**
 *  Initialise with a JSON dictionary
 *
 *  @param JSONDictionary JSON dictionary
 *
 *  @return a new instance
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary;

/**
 *  Initialise a new Strategy instance
 *
 *  @param name        name of the strategy
 *  @param connections array of connections available for that strategy
 *  @param type        type of the strategy
 *
 *  @return a new instance
 */
- (instancetype)initWithName:(NSString *)name connections:(NSArray *)connections type:(A0StrategyType)type;

/**
 *  Checks if the strategy contains a connection with a given name
 *
 *  @param name connection name
 *
 *  @return if the strategy has a connection with name or not.
 */
- (BOOL)hasConnectionWithName:(NSString *)name;

/**
 *  Creates a new enterprise strategy
 *
 *  @param name        name of the strategy
 *  @param connections array of enabled connections
 *
 *  @return a new instance
 */
+ (instancetype)newEnterpriseStrategyWithName:(NSString *)name connections:(NSArray *)connections;

/**
 *  Creates a new database strategy
 *
 *  @param connections list of available database connections
 *
 *  @return a new instance
 */
+ (instancetype)newDatabaseStrategyWithConnections:(NSArray *)connections;
@end

NS_ASSUME_NONNULL_END
