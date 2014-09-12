// A0SocialCredentials.h
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
 *  `A0IdentityProviderCredentials` wraps the access_token and extra information from an identity provider like Facebook or Twitter.
 */
@interface A0IdentityProviderCredentials : NSObject
/**
 *  User's acceess token from the identity provider
 */
@property (readonly, nonatomic) NSString *accessToken;

/**
 *  User's extra information from the identity provider.
 */
@property (readonly, nonatomic) NSDictionary *extraInfo;

/**
 *  Initialise credentials with access_token and extra info
 *
 *  @param accessToken user's access_token
 *  @param extraInfo   user's extra information
 *
 *  @return a new instance of `A0IdentityProviderCredentials`
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken extraInfo:(NSDictionary *)extraInfo;

/**
 *  Initialise credentials with access_token
 *
 *  @param accessToken user's access_token
 *
 *  @return a new instance of `A0IdentityProviderCredentials`
 */
- (instancetype)initWithAccessToken:(NSString *)accessToken;

@end
