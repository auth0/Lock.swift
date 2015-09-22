// A0Strategy.m
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

#import "A0Strategy.h"
#import "A0Connection.h"

NSString * const A0StrategyNameGoogleOpenId = @"google-openid";
NSString * const A0StrategyNameGoogleApps = @"google-apps";
NSString * const A0StrategyNameGooglePlus = @"google-oauth2";
NSString * const A0StrategyNameFacebook = @"facebook";
NSString * const A0StrategyNameWindowsLive = @"windowslive";
NSString * const A0StrategyNameLinkedin = @"linkedin";
NSString * const A0StrategyNameGithub = @"github";
NSString * const A0StrategyNamePaypal = @"paypal";
NSString * const A0StrategyNameTwitter = @"twitter";
NSString * const A0StrategyNameAmazon = @"amazon";
NSString * const A0StrategyNameVK = @"vkontakte";
NSString * const A0StrategyNameYandex = @"yandex";
NSString * const A0StrategyNameOffice365 = @"office365";
NSString * const A0StrategyNameWaad = @"waad";
NSString * const A0StrategyNameADFS = @"adfs";
NSString * const A0StrategyNameSAMLP = @"samlp";
NSString * const A0StrategyNamePingFederate = @"pingfederate";
NSString * const A0StrategyNameIP = @"ip";
NSString * const A0StrategyNameMSCRM = @"mscrm";
NSString * const A0StrategyNameActiveDirectory = @"ad";
NSString * const A0StrategyNameCustom = @"custom";
NSString * const A0StrategyNameAuth0 = @"auth0";
NSString * const A0StrategyNameAuth0LDAP = @"auth0-adldap";
NSString * const A0StrategyName37Signals = @"thirtysevensignals";
NSString * const A0StrategyNameBox = @"box";
NSString * const A0StrategyNameSalesforce = @"salesforce";
NSString * const A0StrategyNameSalesforceSandbox = @"salesforce-sandbox";
NSString * const A0StrategyNameFitbit = @"fitbit";
NSString * const A0StrategyNameBaidu = @"baidu";
NSString * const A0StrategyNameRenRen = @"renren";
NSString * const A0StrategyNameYahoo = @"yahoo";
NSString * const A0StrategyNameAOL = @"aol";
NSString * const A0StrategyNameYammer = @"yammer";
NSString * const A0StrategyNameWordpress = @"wordpress";
NSString * const A0StrategyNameDwolla = @"dwolla";
NSString * const A0StrategyNameShopify = @"shopify";
NSString * const A0StrategyNameMiicard = @"miicard";
NSString * const A0StrategyNameSoundcloud = @"soundcloud";
NSString * const A0StrategyNameEBay = @"ebay";
NSString * const A0StrategyNameEvernote = @"evernote";
NSString * const A0StrategyNameEvernoteSandbox = @"evernote-sandbox";
NSString * const A0StrategyNameSharepoint = @"sharepoint";
NSString * const A0StrategyNameWeibo = @"weibo";
NSString * const A0StrategyNameInstagram = @"instagram";
NSString * const A0StrategyNameTheCity = @"thecity";
NSString * const A0StrategyNameTheCitySandbox = @"thecity-sandbox";
NSString * const A0StrategyNamePlanningCenter = @"planningcenter";
NSString * const A0StrategyNameSMS = @"sms";
NSString * const A0StrategyNameEmail = @"email";

NSString * const A0StrategySocialTokenParameter = @"access_token";
NSString * const A0StrategySocialTokenSecretParameter = @"access_token_secret";
NSString * const A0StrategySocialUserIdParameter = @"user_id";
@implementation A0Strategy

- (instancetype)initWithName:(NSString *)name connections:(NSArray *)connections type:(A0StrategyType)type {
    self = [super init];
    if (self) {
        _name = name;
        _connections = [connections copy];
        _type = type;
    }
    return self;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary {
    self = [super init];
    if (self) {
        _name = [JSONDictionary[@"name"] copy];
        NSArray *connectionsJSON = JSONDictionary[@"connections"];
        NSMutableArray *connections = [@[] mutableCopy];
        for (NSDictionary *connectionJSON in connectionsJSON) {
            [connections addObject:[[A0Connection alloc] initWithJSONDictionary:connectionJSON]];
        }
        _connections = [NSArray arrayWithArray:connections];
        if ([_name isEqualToString:A0StrategyNameAuth0]) {
            _type = A0StrategyTypeDatabase;
        } else if ([[A0Strategy enterpriseNames] containsObject:_name]) {
            _type = A0StrategyTypeEnterprise;
        } else if ([_name isEqualToString:A0StrategyNameSMS] || [_name isEqualToString:A0StrategyNameEmail]) {
            _type = A0StrategyTypePasswordless;
        } else {
            _type = A0StrategyTypeSocial;
        }
    }
    return self;
}

- (BOOL)hasConnectionWithName:(NSString *)name {
    return [self.connections indexOfObjectPassingTest:^BOOL(A0Connection *connection, NSUInteger idx, BOOL *stop) {
        return [connection.name isEqualToString:name];
    }] != NSNotFound;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<A0Strategy name = '%@' connections = %@>", self.name, self.connections];
}

- (BOOL)useResourceOwnerEndpoint {
    NSArray *strategies = @[
                            A0StrategyNameActiveDirectory,
                            A0StrategyNameADFS,
                            A0StrategyNameWaad,
                            A0StrategyNameAuth0,
                            ];
    return [strategies containsObject:self.name];
}

+ (instancetype)newEnterpriseStrategyWithName:(NSString *)name connections:(NSArray *)connections {
    return [[A0Strategy alloc] initWithName:name connections:connections type:A0StrategyTypeEnterprise];
}

+ (instancetype)newDatabaseStrategyWithConnections:(NSArray *)connections {
    return [[A0Strategy alloc] initWithName:A0StrategyNameAuth0 connections:connections type:A0StrategyTypeDatabase];
}

+ (NSSet *)enterpriseNames {
    static NSSet *enterpriseNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *names = @[
                           A0StrategyNameGoogleApps,
                           A0StrategyNameOffice365,
                           A0StrategyNameWaad,
                           A0StrategyNameADFS,
                           A0StrategyNameSAMLP,
                           A0StrategyNamePingFederate,
                           A0StrategyNameIP,
                           A0StrategyNameMSCRM,
                           A0StrategyNameActiveDirectory,
                           A0StrategyNameCustom,
                           A0StrategyNameSharepoint,
                           ];
        enterpriseNames = [NSSet setWithArray:names];
    });
    return enterpriseNames;
}
@end
