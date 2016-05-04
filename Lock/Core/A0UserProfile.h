// A0UserProfile.h
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
 *  `A0UserProfile` has User's information obtained from Auth0.
 */
@interface A0UserProfile : NSObject<NSSecureCoding>

/**
 *  User's id in Auth0
 */
@property (readonly, nonatomic) NSString *userId;
/**
 *  User's name
 */
@property (readonly, nonatomic) NSString *name;
/**
 *  User's nickname
 */
@property (readonly, nonatomic) NSString *nickname;
/**
 *  User's email. Can be nil
 */
@property (readonly, nullable, nonatomic) NSString *email;
/**
 *  User's avatar picture URL.
 */
@property (readonly, nonatomic) NSURL *picture;
/**
 *  User creation date
 */
@property (readonly, nonatomic) NSDate *createdAt;
/**
 *  Extra user information stored in Auth0.
 */
@property (readonly, nonatomic) NSDictionary *extraInfo;
/**
 *  User's identities from other identity providers, e.g.: Facebook
 */
@property (readonly, nonatomic) NSArray *identities;
/**
 *  Values stored under `user_metadata`. 
 *  These values can be modified using and `id_token` and calling PATCH `/users/:id` with API v2
 */
@property (readonly, nonatomic) NSDictionary *userMetadata;
/**
 *  Values stored under `app_metadata`
 */
@property (readonly, nonatomic) NSDictionary *appMetadata;

/**
 *  Initialise a new profile
 *
 *  @param userId    user identifier
 *  @param name      user's name
 *  @param nickname  user's nickname
 *  @param email     user's email
 *  @param picture   user's avatar URL
 *  @param createdAt user's created date
 *
 *  @return a new instance
 */
- (instancetype)initWithUserId:(NSString *)userId
                          name:(NSString *)name
                      nickname:(NSString *)nickname
                         email:(NSString *)email
                       picture:(NSURL *)picture
                     createdAt:(NSDate *)createdAt;

/**
 *  Initialise form a JSON dictionary
 *
 *  @param dictionary JSON dictionary
 *
 *  @return a new instance
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
NS_ASSUME_NONNULL_END