// A0KeyUploader.m
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

#import "A0KeyUploader.h"
#import "Constants.h"
#import <AFNetworking/AFNetworking.h>

NSString * const A0KeyUploaderErrorDomain = @"com.auth0.touchid.uploader";

@interface A0KeyUploader ()
@property (copy, nonatomic) NSString *authorization;
@property (strong, nonatomic) NSURL *domainURL;
@property (copy, nonatomic) NSString *token;
@property (copy, nonatomic) NSString *clientId;
@end

@implementation A0KeyUploader

- (instancetype)initWithDomainURL:(NSURL *)domainURL clientId:(NSString *)clientId authorization:(NSString *)authorization {
    self = [super init];
    if (self) {
        _authorization = [NSString stringWithFormat:@"Basic %@", authorization];
        _domainURL = domainURL;
        _clientId = clientId;
    }
    return self;
}


- (void)uploadKey:(NSData *)key forUser:(NSString *)user callback:(A0KeyUploaderCallback)callback {
    NSString *path = @"/api/v2/device-credentials";
    NSURL *domainURL = self.domainURL;
    NSURL *url = [NSURL URLWithString:path relativeToURL:domainURL];
    NSString *name = [self deviceName];
    NSString *deviceIdentifier = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *keyBase64 = [key base64EncodedStringWithOptions:0];

    void(^registerKey)() = ^{
        A0LogDebug(@"Uploading key %@ for user %@", keyBase64, user);
        [self performRequestWithMethod:@"POST"
                                   url:url
                               payload:@{
                                         @"value": keyBase64,
                                         @"device_name": name,
                                         @"device_id": deviceIdentifier,
                                         @"type": @"public_key",
                                         @"client_id": self.clientId,
                                         }
                              callback:^(NSError * _Nullable error, id payload) {
                                  NSDictionary *key = payload;
                                  callback(error, key[@"id"]);
                              }];
    };

    NSString *(^filterKey)(NSArray *) = ^(NSArray *keys) {
        NSString *keyIdentifier = nil;
        for (NSDictionary *key in keys) {
            if ([key[@"device_name"] isEqualToString:name]) {
                keyIdentifier = key[@"id"];
                break;
            }
            if ([key[@"device_id"] isEqualToString:deviceIdentifier]) {
                keyIdentifier = key[@"id"];
                break;
            }
        }
        return keyIdentifier;
    };

    void(^removeKey)(NSString *, void(^)(NSError *)) = ^(NSString *keyIdentifier, void(^callback)(NSError *)) {
        NSString *deletePath = [[path stringByAppendingPathComponent:keyIdentifier] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
        NSURL *deleteURL = [NSURL URLWithString:deletePath relativeToURL:domainURL];
        A0LogDebug(@"Removing old key with identifier %@", keyIdentifier);
        [self performRequestWithMethod:@"DELETE"
                                   url:deleteURL
                               payload:nil
                              callback:^(NSError * _Nullable error, id none) {
                                  callback(error);
                              }];
    };

    [self performRequestWithMethod:@"GET"
                               url:url
                           payload:@{
                                     @"client_id": self.clientId,
                                     @"type": @"public_key",
                                     @"user_id": user,
                                     }
                          callback:^(NSError * _Nullable error, id payload) {
                              if (error) {
                                  callback([self errorFromCause:error], nil);
                                  return;
                              }
                              NSString *keyIdentifier = filterKey(payload);
                              if (!keyIdentifier) {
                                  registerKey();
                                  return;
                              }

                              removeKey(keyIdentifier, ^(NSError * _Nullable error) {
                                  registerKey();
                              });
                          }];
}


- (void)performRequestWithMethod:(NSString *)method url:(NSURL *)url payload:(NSDictionary *)payload callback:(nonnull void (^)(NSError * _Nullable, id _Nullable))callback {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSError *error;
    NSURLRequest *request = [self requestWithMethod:method
                                                url:url
                                            payload:payload
                                              error:&error];

    if (error) {
        callback([self errorFromCause:error], nil);
        return;
    }

    NSURLSessionTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            callback([self errorFromCause:error], nil);
        } else {
            callback(nil, responseObject);
        }
    }];
    [task resume];
}

- (NSURLRequest *)requestWithMethod:(NSString *)method url:(NSURL *)url payload:(NSDictionary *)payload error:(NSError **)error {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = method;
    [request addValue:self.authorization forHTTPHeaderField:@"Authorization"];
    return [[AFJSONRequestSerializer serializer] requestBySerializingRequest:request
                                                              withParameters:payload
                                                                       error:error];
}

- (NSError *)errorFromCause:(NSError *)cause {
    if (!cause) {
        return nil;
    }

    NSHTTPURLResponse *response = cause.userInfo[@"com.alamofire.serialization.response.error.response"];
    return [NSError errorWithDomain:A0KeyUploaderErrorDomain
                               code:[response statusCode] == 401 ? A0KeyUploaderErrorCodeUnauthorized : A0KeyUploaderErrorCodeFailed
                           userInfo:@{
                                      @"com.auth0.touchid.uploader.cause": cause,
                                      NSLocalizedDescriptionKey: A0LocalizedString(@"Failed to register device for TouchID. Please try again later.")
                                      }];
}

- (NSString *)deviceName {
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSCharacterSet *setToFilter = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    deviceName = [[deviceName componentsSeparatedByCharactersInSet:setToFilter] componentsJoinedByString:@""];
    return deviceName;
}

+ (NSString *)authorizationWithUsername:(NSString *)username password:(NSString *)password connectionName:(NSString *)connectionName {
    NSString *token = [NSString stringWithFormat:@"%@\\%@:%@", connectionName, username, password];
    NSString *base64 = [[token dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return base64;
}
@end
