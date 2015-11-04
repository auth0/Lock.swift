//  A0UserIdentity.h
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
 *  User's linked accounts identities.
 */
@interface A0UserIdentity : NSObject<NSCoding>

/**
 *  Name of the connection used to link this account
 */
@property (readonly, nonatomic) NSString *connection;

/**
 *  Name of the identity provider
 */
@property (readonly, nonatomic) NSString *provider;

/**
 *  User Id in the identity provider
 */
@property (readonly, nonatomic) NSString *userId;

/**
 *  Flag that indicates if the identity is `Social`. e.g: Facebook
 */
@property (readonly, nonatomic, getter = isSocial) BOOL social;

/**
 *  If the identity provider is OAuth2, you will find the access_token that can be used to call the provider API
 *  and obtain more information from the user (e.g: Facebook friends, Google contacts, LinkedIn contacts, etc.).
 */
@property (readonly, nonatomic) NSString *accessToken;

/**
 *  Identity id for Auth0 api. It has the format `provider|userId`
 */
@property (readonly, nonatomic) NSString *identityId;

/**
 *  If the identity provider is OAuth 1.0a, an access_token_secret property will be present 
 *  and can be used to call the provider API and obtain more information from the user.
 *  Currently only for twitter.
 */
@property (readonly, nonatomic) NSString *accessTokenSecret;

/**
 *  User's profile data in the Identity Provider
 */
@property (readonly, nonatomic) NSDictionary *profileData;

/**
 *  Initialises an instance from a JSON dictionary
 *
 *  @param JSONDict dictionary with JSON values
 *
 *  @return an initialised instance
 */
- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDict;

@end
