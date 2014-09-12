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

/**
 *  `A0Application` contains your Auth0 application information
 */
@interface A0Application : NSObject

/**
 *  Application id
 */
@property (strong, nonatomic, readonly) NSString *identifier;

/**
 *  Tenant name
 */
@property (strong, nonatomic, readonly) NSString *tenant;

/**
 *  authorize URL
 */
@property (strong, nonatomic, readonly) NSURL *authorizeURL;

/**
 *  Callback URL
 */
@property (strong, nonatomic, readonly) NSURL *callbackURL;

/**
 *  Enabled authentication strategies
 */
@property (strong, nonatomic, readonly) NSArray *strategies;


/**
 *  Initialise the applcation from a JSON dictionary
 *
 *  @param JSONDict JSON response form the server
 *
 *  @return a new instance
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDict;

/**
 *  Checks whether the app has a Database strategy enabled
 *
 *  @return if the app has a database strategy
 */
- (BOOL)hasDatabaseConnection;

/**
 *  Checks whether the app has at least one non-database strategy
 *
 *  @return if the app has at least one non-database strategy
 */
- (BOOL)hasSocialOrEnterpriseStrategies;

/**
 *  Returns the databse strategy
 *
 *  @return a database stretegy
 */
- (A0Strategy *)databaseStrategy;

/**
 *  Returns all non-database strategies
 *
 *  @return a list with non-database strategies
 */
- (NSArray *)availableSocialOrEnterpriseStrategies;

@end
