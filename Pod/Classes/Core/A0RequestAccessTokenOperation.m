// A0RequestAccessTokenOperation.m
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

#import "A0RequestAccessTokenOperation.h"
#import "A0Errors.h"

@implementation A0RequestAccessTokenOperation

- (instancetype)initWithBaseURL:(NSURL *)baseURL clientId:(NSString *)clientId clientSecret:(NSString *)clientSecret {
    NSURL *accessTokenURL = [NSURL URLWithString:@"/oauth/token" relativeToURL:baseURL];
    NSDictionary *parameters = @{
                                 @"client_id": clientId,
                                 @"client_secret": clientSecret,
                                 @"grant_type": @"client_credentials",
                                 };
    NSError *error;
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST"
                                                                          URLString:accessTokenURL.absoluteString 
                                                                         parameters:parameters
                                                                              error:&error];
    if (error) {
        Auth0LogError(@"Failed to create Request Access Token operation with error %@", error);
        return nil;
    }
    self = [super initWithRequest:request];
    if (self) {
        self.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    return self;
}

- (void)setSuccess:(void (^)(NSString *))success failure:(void (^)(NSError *))failure {
    [self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        Auth0LogDebug(@"Obtained access token %@", responseObject);
        if (success) {
            success(responseObject[@"access_token"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        Auth0LogError(@"Failed to fetch access token with error %@", error);
        NSError *operationError = error.code == NSURLErrorNotConnectedToInternet ? [A0Errors notConnectedToInternetError] : error;
        if (failure) {
            failure(operationError);
        }
    }];
}
@end
