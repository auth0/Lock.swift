//  A0Connection.h
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

/**
 *  Flag if the DB connection requires username
 */
FOUNDATION_EXPORT NSString * const A0ConnectionRequiresUsername;
/**
 *  Main domain for an enterprise connection
 */
FOUNDATION_EXPORT NSString * const A0ConnectionDomain;
/**
 *  List of domain aliases for an enterprise connection
 */
FOUNDATION_EXPORT NSString * const A0ConnectionDomainAliases;
/**
 *  Flag that tells if the DB connection allows forgot password
 */
FOUNDATION_EXPORT NSString * const A0ConnectionShowForgot;
/**
 *  Flag that tells if the DB connection allows signup
 */
FOUNDATION_EXPORT NSString * const A0ConnectionShowSignUp;

/**
 *  `A0Connection` represent an Auth0 connection configured for the Application.
 */
@interface A0Connection : NSObject

/**
 *  Name of the connection
 */
@property (readonly, nonatomic) NSString *name;

/**
 *  Connection values like scopes, domain, etc, obtained from Auth0
 */
@property (readonly, nonatomic) NSDictionary *values;

/**
 *  Initialise a new A0Connection from a JSON dictionary. 
 *  At least it must have a 'name' entry otherwise it will raise a NSException.
 *
 *  @param JSON dictionary with JSON values of the connection
 *
 *  @return an initialised instance
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)JSON;

/**
 *  Enables Objective-C subscripting of A0Connection object
 *
 *  @param key property value key
 *
 *  @return value of connection property
 */
- (nullable id)objectForKeyedSubscript:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
