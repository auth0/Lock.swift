// A0RequestAccessTokenOperation.h
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

#import <AFNetworking/AFNetworking.h>

/**
 *  HTTP operation to request for Auth0 API access token using client credentials.
 *  Please be careful with how you store and handle your application client secret.
 */
@interface A0RequestAccessTokenOperation : AFHTTPRequestOperation

/**
 *  Initialises the operation
 *
 *  @param baseURL      Auth0 endpoint base URL
 *  @param clientId     Auth0's app client id
 *  @param clientSecret Auth0's app client secret
 *
 *  @return an initialised instance.
 */
- (instancetype)initWithBaseURL:(NSURL *)baseURL clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret;

/**
 *  Sets the operation success and failure callbacks
 *
 *  @param success block called on success with access token.
 *  @param error   block called on error with reason.
 */
- (void)setSuccess:(void(^)(NSString *accessToken))success failure:(void(^)(NSError *error))error;

@end
