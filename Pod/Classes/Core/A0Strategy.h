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

/**
 *  Twitter Identity provider strategy identifier
 */
FOUNDATION_EXPORT NSString * const A0TwitterAuthenticationName;
/**
 *  Facebook Identity provider strategy identifier
 */
FOUNDATION_EXPORT NSString * const A0FacebookAuthenticationName;

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
    A0StrategyTypeEnterprise
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
 *  Initialise with a JSON dictionary
 *
 *  @param JSONDictionary JSON dictionary
 *
 *  @return a new instance
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDictionary;

@end
