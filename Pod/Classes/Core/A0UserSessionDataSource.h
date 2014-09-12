//  A0UserSessionDataSource.h
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

/**
 *  `A0UserSessionDataSource` is a default implementation of `A0SessionDataSource`. It stores all token information from `A0Token` and from `A0UserProfile` idenitities in iOS keychain. The rest of `A0UserProfile` information is stored in `NSUserDefaults`. It can be configured to store in iOS Keychain under an accessGroup to allow keychain sharing between apps.
 */
@interface A0UserSessionDataSource : NSObject<A0SessionDataSource>

/**
 *  Initialise a new instance with no access group for Keychain storage
 *
 *  @return a new instance
 */
- (instancetype)init;

/**
 *  Initialise a new instance specifying an access group to allow keychain sharing. The access group must be declared in your apps entitlements file and should match with the NSString supplied as a parameter. (Must include your Team Prefix)
 *
 *  @param accessGroup string with the access group identifier
 *
 *  @return a new instance
 */
- (instancetype)initWithAccessGroup:(NSString *)accessGroup;

@end
