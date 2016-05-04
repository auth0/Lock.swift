// A0Token.h
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
 *  `A0Token` holds all token information for a user.
 */
@interface A0Token : NSObject<NSSecureCoding>

/**
 *  User's accessToken for Auth0 API
 */
@property (readonly, nullable, nonatomic) NSString *accessToken;
/**
 *  User's JWT token
 */
@property (readonly, nonatomic) NSString *idToken;
/**
 *  Type of token return by Auth0 API
 */
@property (readonly, nonatomic) NSString *tokenType;
/**
 *  Refresh token used to obtain new JWT tokens. Can be nil if no offline access was requested
 */
@property (readonly, nullable, nonatomic) NSString *refreshToken;

/**
 *  Initialise a token
 *
 *  @param accessToken  user's access token
 *  @param idToken      user's JWT token
 *  @param tokenType    type of token
 *  @param refreshToken token used to refresh id_token. Can be nil
 *
 *  @return new instance
 */
- (instancetype)initWithAccessToken:(nullable NSString *)accessToken
                            idToken:(NSString *)idToken
                          tokenType:(NSString *)tokenType
                       refreshToken:(nullable NSString *)refreshToken;

/**
 *  Initialise a token from a JSON dictionary
 *
 *  @param dictionary JSON dictionary
 *
 *  @return a new instance
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
NS_ASSUME_NONNULL_END