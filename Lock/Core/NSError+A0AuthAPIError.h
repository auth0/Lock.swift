// NSError+A0AuthAPIError.h
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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
 *  Auth0 Error response key in NSError userInfo property
 */
FOUNDATION_EXPORT NSString * const A0JSONResponseSerializerErrorDataKey;

/**
 *  Category with helper methods to check Auth0 Auth API error responses.
 */
@interface NSError (A0AuthAPIError)

/**
 *  Auth0 API error response
 *
 *  @return response from Auth0 or nil
 */
- (NSDictionary * _Nullable)a0_payload;

/**
 *  Auth0 error code from Auth0 Auth API
 *
 *  @return a string code or nil
 */
- (NSString * _Nullable)a0_error;

/**
 *  Auth0 error message from Auth0 Auth API
 *
 *  @return a message or nil
 */
- (NSString * _Nullable)a0_errorDescription;

/**
 *  If Auth0 error for authentication indicates that a MFA step is needed
 *
 *  @return if login requires an additional step or not
 */
- (BOOL)a0_mfaRequired;

@end

NS_ASSUME_NONNULL_END
