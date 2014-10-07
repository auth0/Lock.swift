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

NSString * const A0Auth0AuthenticationName = @"auth0";
NSString * const A0TwitterAuthenticationName = @"twitter";
NSString * const A0FacebookAuthenticationName = @"facebook";

NSString * const A0StrategySocialTokenParameter = @"access_token";
NSString * const A0StrategySocialTokenSecretParameter = @"access_token_secret";
NSString * const A0StrategySocialUserIdParameter = @"user_id";

@implementation A0Strategy

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
        if ([_name isEqualToString:A0Auth0AuthenticationName]) {
            _type = A0StrategyTypeDatabase;
        } else if ([[A0Strategy enterpriseNames] containsObject:_name]) {
            _type = A0StrategyTypeEnterprise;
        } else {
            _type = A0StrategyTypeSocial;
        }
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<A0Strategy name = '%@' connections = %@>", self.name, self.connections];
}

+ (NSSet *)enterpriseNames {
    static NSSet *enterpriseNames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *names = @[@"google-apps",
                           @"office365",
                           @"waad",
                           @"adfs",
                           @"samlp",
                           @"pingfederate",
                           @"ip",
                           @"mscrm",
                           @"ad",
                           @"custom",
                           @"sharepoint"];
        enterpriseNames = [NSSet setWithArray:names];
    });
    return enterpriseNames;
}
@end
