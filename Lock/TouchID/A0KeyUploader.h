// A0KeyUploader.h
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

FOUNDATION_EXPORT NSString * const A0KeyUploaderErrorDomain;

typedef NS_ENUM(NSUInteger, A0KeyUploaderErrorCode) {
    A0KeyUploaderErrorCodeFailed = 0,
    A0KeyUploaderErrorCodeUnauthorized
};

/**
 *  Callback called when upload succeds or fails
 *
 *  @param error         that made the upload fail
 *  @param keyIdentifier returned by Auth0 API after successful upload
 */
typedef void(^A0KeyUploaderCallback)(NSError * _Nullable error, NSString * _Nullable keyIdentifier);

/**
 * Uploader for Public Key using Auth0 Management API `device-credentials`.
 *
 */
@interface A0KeyUploader : NSObject

/**
 *  Initialize a public key uploader to be used by TouchID authentication
 *
 *  @param domainURL     of your Auth0 account
 *  @param clientId      of your Auth0 account
 *  @param authorization value for 'Authorization' header
 *
 *  @return initialized instance
 */
- (instancetype)initWithDomainURL:(NSURL *)domainURL
                         clientId:(NSString *)clientId
                    authorization:(NSString *)authorization;

/**
 *  Uploads a public key for a given user
 *
 *  @param key      data to upload to Auth0
 *  @param user     identifier of the user owner of the key
 *  @param callback the will have either an error of the key identifier returned by Auth0
 */
- (void)uploadKey:(NSData *)key forUser:(NSString *)user callback:(A0KeyUploaderCallback)callback;

+ (NSString *)authorizationWithUsername:(NSString *)username
                               password:(NSString *)password
                         connectionName:(NSString *)connectionName;
@end

NS_ASSUME_NONNULL_END