// A0Application.h
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

@class A0Strategy;

NS_ASSUME_NONNULL_BEGIN

/**
 *  `A0Application` contains your Auth0 application information
 */
@interface A0Application : NSObject

/**
 *  Application id
 */
@property (readonly, nonatomic) NSString *identifier;

/**
 *  Tenant name
 */
@property (readonly, nonatomic) NSString *tenant;

/**
 *  authorize URL
 */
@property (readonly, nonatomic) NSURL *authorizeURL;

/**
 *  Enabled authentication strategies
 *
 *  @see A0Strategy
 *  @see A0Connection
 */
@property (readonly, nonatomic) NSArray *strategies;

/**
 *  Database authentication strategy for this Application.
 *  It will return nil if no Database connection was configured in Auth0 Dashboard
 *
 *  @see A0Strategy
 *  @see A0Connection
 */
@property (readonly, nullable, nonatomic) A0Strategy *databaseStrategy;

/**
 *  List of social strategies enabled for the application. e.g: Facebook, Twitter, Linkedin.
 *
 *  @see A0Strategy
 *  @see A0Connection
 */
@property (readonly, nonatomic) NSArray *socialStrategies;

/**
 *  List of enterprise strategies enabled for the application. e.g: Active Directory, IP, Sharepoint, etc.
 *
 *  @see A0Strategy
 *  @see A0Connection
 */
@property (readonly, nonatomic) NSArray *enterpriseStrategies;

/**
 *  Active Directory strategy for this application (if configured).
 *
 *  @see A0Strategy
 *  @see A0Connection
 */
@property (readonly, nullable, nonatomic) A0Strategy *activeDirectoryStrategy;

/**
 *  Initialise the applcation from a JSON dictionary
 *
 *  @param JSONDict JSON response form the server
 *
 *  @return a new instance
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDict;

/**
 *  Returns an available strategy by its name.
 *
 *  @param name strategy name.
 *
 *  @return an available strategy or nil
 */
- (nullable A0Strategy *)strategyByName:(NSString *)name;

/**
 *  Find the enterprise `A0Strategy` that has a connection
 *
 *  @param connectionName name of the connection
 *
 *  @return an enterprise strategy or nil if not found
 */
- (nullable A0Strategy *)enterpriseStrategyWithConnection:(NSString *)connectionName;

@end

NS_ASSUME_NONNULL_END
