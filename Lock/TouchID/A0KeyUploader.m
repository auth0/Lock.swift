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
#import "A0UserAPIClient.h"
#import <AFNetworking/AFNetworking.h>

@interface A0KeyUploader ()
@property (strong, nonatomic) NSString *authorization;
@property (strong, nonatomic) NSURL *domainURL;
@property (copy, nonatomic) NSString *token;
@property (strong, nonatomic) A0UserAPIClient *client;
@end

@implementation A0KeyUploader

- (instancetype)initWithDomainURL:(NSURL *)domainURL authorization:(NSString *)authorization client:(A0UserAPIClient *)client {
    self = [super init];
    if (self) {
        _authorization = [NSString stringWithFormat:@"Basic %@", authorization];
        _domainURL = domainURL;
        _client = client;
    }
    return self;
}

- (void)uploadKey:(NSData *)key forUserWithIdentifier:(NSString *)identifier callback:(nonnull void (^)(NSError * _Nullable))callback {
    NSString *path = [[NSString stringWithFormat:@"api/users/%@/publickey", identifier] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:path relativeToURL:self.domainURL];
    [self performRequestWithMethod:@"DELETE"
                               url:url
                           payload:@{
                                     @"device": [self deviceName],
                                     }
                          callback:^(NSError * _Nullable error) {
                              [self.client registerPublicKey:key device:[self deviceName] user:identifier success:^{
                                  callback(nil);
                              } failure:^(NSError * _Nonnull error) {
                                  callback(error);
                              }];
//                              [self performRequestWithMethod:@"POST" url:url
//                                                     payload:@{
//                                                               @"public_key": [[NSString alloc] initWithData:key encoding:NSUTF8StringEncoding],
//                                                               @"device": [self deviceName],
//                                                               }
//                                                    callback:callback];
                          }];
}


- (void)performRequestWithMethod:(NSString *)method url:(NSURL *)url payload:(NSDictionary *)payload callback:(nonnull void (^)(NSError * _Nullable))callback {
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    NSError *error;
    NSURLRequest *request = [self requestWithMethod:method
                                                url:url
                                            payload:payload
                                              error:&error];

    if (error) {
        callback([self errorFromCause:error]);
        return;
    }

    NSURLSessionTask *task = [manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        if (error) {
            callback([self errorFromCause:error]);
        } else {
            callback(nil);
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
    return [NSError errorWithDomain:@"com.auth0.touchid.uploader"
                               code:0
                           userInfo:@{
                                      @"com.auth0.cause": cause,
                                      NSLocalizedDescriptionKey: @"Failed to upload public key"
                                      }];
}

- (NSString *)deviceName {
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSCharacterSet *setToFilter = [[NSCharacterSet alphanumericCharacterSet] invertedSet];
    deviceName = [[deviceName componentsSeparatedByCharactersInSet:setToFilter] componentsJoinedByString:@""];
    return deviceName;
}

+ (NSString *)authenticationWithUsername:(NSString *)username password:(NSString *)password connectionName:(NSString *)connectionName {
    NSString *token = [NSString stringWithFormat:@"%@%@:%@", connectionName, username, password];
    NSString *base64 = [[token dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"=" withString:@""];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    base64 = [base64 stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
    return base64;
}
@end
