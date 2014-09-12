//  A0Session.h
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

#import "A0SessionDataSource.h"
#import "A0Token.h"
#import "A0UserProfile.h"

typedef void(^A0RefreshBlock)(A0UserProfile *profile, A0Token *token);
typedef void(^A0RefreshFailureBlock)(NSError *error);

/**
 `A0Session` objective is to handle expiration and refresh of Session information (Tokens) without the need to manually call the Auth0 Delegation API. It delegates storage handling of Token & User's profile to an instance of `A0SessionDataSource`. Auth0.iOS comes with a basic class called `A0SessionDataSource` that stores the User's token in iOS Keychain and the User's profile in `NSUserDefaults`, but you can write your own `A0SessionDataSource` class and supply it to your `A0Session` instance.
 */
@interface A0Session : NSObject

/**
 Session information DataSource (User's tokens and profile).
 */
@property (readonly, nonatomic) id<A0SessionDataSource> dataSource;

/**
 Returns the current token from the DataSource or nil.
 */
@property (readonly, nonatomic) A0Token *token;

/**
 Returns the current profile from the DataSource or nil.
 */
@property (readonly, nonatomic) A0UserProfile *profile;

/**
 Initialise the session with info from the dataSource. You can implement your own or use Auth0's `A0UserSessionDataSource` protocol.
 @param sessionDataSource session information DataSource.
 @return new `A0Session` instance
 */
- (instancetype)initWithSessionDataSource:(id<A0SessionDataSource>)sessionDataSource;

/**
 Returns YES if the *id_token* is expired
 */
- (BOOL)isExpired;

/**
 Checks whether the id_token is expired. If it is, it will request a new one using the stored refresh_token. Otherwise it will request a new id_token using the old id_token. On success, it will update the stored id_token.
 @param success block that will be called on successful id_tokem refresh. It will include updated token and user's profile as parameters.
 @param failure block that will be called when `A0Session` couldnt refresh the token with a NSError describing what went wrong.
 */
- (void)refreshWithSuccess:(A0RefreshBlock)success failure:(A0RefreshFailureBlock)failure;

/**
 It will only request a new id_token using the stored refresh_token if it's expired. On successful request of a new id_token it will update it in the DataSource. If the token is not expired, it will be returned as a paramater in the success block.
 @param success block that will be called on successful id_tokem refresh. It will include updated token and user's profile as parameters.
 @param failure block that will be called when `A0Session` couldnt refresh the token with a NSError describing what went wrong.
 */
- (void)refreshIfExpiredWithSuccess:(A0RefreshBlock)success failure:(A0RefreshFailureBlock)failure;

/**
 Tries to refresh User's profile using the stored id_token. On success returns both the stored token and updated profile, and updates the DataSource with the new one.
 @param success block that will be called on successful refresh of User's profile. It will include current token and updated user's profile as parameters.
 @param failure block that will be called when `A0Session` couldnt update User's profile with a NSError describing what went wrong.
 */
- (void)renewUserProfileWithSuccess:(A0RefreshBlock)success failure:(A0RefreshFailureBlock)failure;

/**
 Removes all session information & clears the DataSource calling it's clearAll method.
 */
- (void)clear;

/**
 Returns a new `A0Session` instance with the default DataSource `A0UserSessionDataSource`.
 @return new `A0Session` instance
 */
+ (instancetype)newDefaultSession;

/**
 Returns a new `A0Session` instance.
 @param dataSource session DataSource for the new `A0Session` instance.
 @return new `A0Session` instance
 */
+ (instancetype)newSessionWithDataSource:(id<A0SessionDataSource>)dataSource;

@end
