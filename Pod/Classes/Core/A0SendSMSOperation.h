// A0SendSMSOperation.h
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

#import "AFHTTPRequestOperation.h"

/**
 *  Operation to send a SMS with an acess code to be used during login.
 *  Must have a `SMS` connection available and configured in your Auth0's app.
 */
@interface A0SendSMSOperation : AFHTTPRequestOperation

/**
 *  Initialises the operation with an access token and phone number.
 *
 *  @param baseURL     api base URL.
 *  @param accessToken api access token
 *  @param phoneNumber user's phone number.
 *
 *  @return an initialised instance
 */
- (instancetype)initWithBaseURL:(NSURL *)baseURL accessToken:(NSString *)accessToken phoneNumber:(NSString *)phoneNumber;

/**
 *  Initialises the operation for API v2 with a JWT and phone number.
 *
 *  @param baseURL     api base URL.
 *  @param accessToken api access token
 *  @param phoneNumber user's phone number.
 *
 *  @return an initialised instance
 */
- (instancetype)initWithBaseURL:(NSURL *)baseURL jwt:(NSString *)jwt phoneNumber:(NSString *)phoneNumber;


/**
 *  Sets the callback for success and failure of the operation
 *
 *  @param success block called on success.
 *  @param failure block called on error with the reason.
 */
- (void)setSuccess:(void(^)())success failure:(void(^)(NSError *))failure;

@end
