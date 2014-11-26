// A0SendSMSOperation.m
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

#import "A0SendSMSOperation.h"
#import "A0JSONResponseSerializer.h"
#import "A0Errors.h"

@implementation A0SendSMSOperation

- (instancetype)initWithURL:(NSURL *)url authorizationHeader:(NSString *)authorizationHeader phoneNumber:(NSString *)phoneNumber {
    NSDictionary *parameters = @{
                                 @"phone_number": phoneNumber,
                                 @"connection": @"sms",
                                 @"email_verified": @NO,
                                 };
    NSError *error;
    Auth0LogDebug(@"Requesting SMS code with parameters %@", parameters);
    NSMutableURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"POST" URLString:url.absoluteString parameters:parameters error:&error];
    if (error) {
        Auth0LogError(@"Failed to create operation with error %@", error);
        return nil;
    }
    [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
    self = [super initWithRequest:request];
    if (self) {
        self.responseSerializer = [A0JSONResponseSerializer serializer];
    }
    return self;
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL accessToken:(NSString *)accessToken phoneNumber:(NSString *)phoneNumber {
    NSURL *sendSMSURL = [NSURL URLWithString:@"/api/users/" relativeToURL:baseURL];
    return [self initWithURL:sendSMSURL authorizationHeader:[@"Bearer " stringByAppendingString:accessToken] phoneNumber:phoneNumber];
}

- (instancetype)initWithBaseURL:(NSURL *)baseURL jwt:(NSString *)jwt phoneNumber:(NSString *)phoneNumber {
    NSURL *sendSMSURL = [NSURL URLWithString:@"/api/v2/users" relativeToURL:baseURL];
    return [self initWithURL:sendSMSURL authorizationHeader:[@"Bearer " stringByAppendingString:jwt] phoneNumber:phoneNumber];
}

- (void)setSuccess:(void (^)())success failure:(void (^)(NSError *))failure {
    [self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success();
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSError *operationError = error.code == NSURLErrorNotConnectedToInternet ? [A0Errors notConnectedToInternetError] : error;
        if (failure) {
            failure(operationError);
        }
    }];
}
@end
