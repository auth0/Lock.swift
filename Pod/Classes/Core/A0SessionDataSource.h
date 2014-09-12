//  A0SessionDataSource.h
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

@class A0Token, A0UserProfile;

/**
 *  Protocol to obtain and store user's tokens and profile
 */
@protocol A0SessionDataSource <NSObject>

@required

/**
 *  Stores both the token and user profile
 *
 *  @param token       token info to store
 *  @param userProfile profile to store
 */
- (void)storeToken:(A0Token *)token andUserProfile:(A0UserProfile *)userProfile;

/**
 *  Store user's token
 *
 *  @param token token to store
 */
- (void)storeToken:(A0Token *)token;

/**
 *  Store user's profile
 *
 *  @param userProfile profile to store
 */
- (void)storeUserProfile:(A0UserProfile *)userProfile;

/**
 *  Returns the stored token
 *
 *  @return stored token or nil
 */
- (A0Token *)currentToken;

/**
 *  Returns the stored profile
 *
 *  @return user's profile or nil
 */
- (A0UserProfile *)currentUserProfile;


/**
 *  Removes both token and profile from its store
 */
- (void)clearAll;
@end
