// A0HTTPStubber.m
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

#import "A0HTTPStubber.h"
#import "A0Application.h"
#import "A0Connection.h"
#import "A0Strategy.h"

@implementation A0HTTPStubber

- (instancetype)initWithApplication:(A0Application *)application {
    self = [super init];
    if (self) {
        _application = application;
    }
    return self;
}

- (HTTPFilter)filterForResourceOwnerWithUsername:(NSString *)username password:(NSString *)password {
    return [self filterForResourceOwnerWithParameters:@{
                                                        @"username": username,
                                                        @"password": password,
                                                        @"scope": @"openid offline_access",
                                                        @"grant_type": @"password",
                                                        @"client_id": self.application.identifier,
                                                        @"connection": [self.application.databaseStrategy.connections.firstObject name]
                                                        }];
}

- (HTTPFilter)filterForResourceOwnerWithParameters:(NSDictionary *)parameters {
    return [self filterWithPath:@"/oauth/ro" method: @"POST" parameters: parameters];
}

- (HTTPFilter)filterForTokenInfoWithJWT:(NSString *)jwt {
    return [self filterWithPath:@"/tokeninfo" method: @"POST" parameters: @{@"id_token": jwt}];
}

- (HTTPFilter)filterForSignUpWithParameters:(NSDictionary *)parameters {
    return [self filterWithPath:@"/dbconnections/signup" method: @"POST" parameters: parameters];
}

-(HTTPFilter)filterForChangePasswordWithParameters:(NSDictionary *)parameters {
    return [self filterWithPath:@"/dbconnections/change_password" method: @"POST" parameters: parameters];
}

- (HTTPFilter)filterForSocialAuthenticationWithParameters:(NSDictionary *)parameters {
    return [self filterWithPath:@"/oauth/access_token" method: @"POST" parameters: parameters];
}

- (HTTPFilter)filterForDelegationWithParameters:(NSDictionary *)parameters {
    return [self filterWithPath:@"/delegation" method: @"POST" parameters: parameters];
}

- (HTTPFilter)filterForUnlinkWithParameters:(NSDictionary *)parameters {
    return [self filterWithPath:@"/unlink" method:@"POST" parameters:parameters];
}

- (HTTPFilter)filterForPasswordlessStartWithPhoneNumber:(NSString *)phoneNumber {
    return [self filterWithPath:@"/passwordless/start"
                         method:@"POST"
                     parameters:@{
                                  @"phone_number": phoneNumber,
                                  @"connection": @"sms"
                                  }];
}

- (HTTPFilter)filterWithPath:(NSString *)path method:(NSString *)method parameters:(NSDictionary *)parameters {
    return ^BOOL(NSURLRequest *request) {
        NSDictionary *dictionary = [NSURLProtocol propertyForKey:@"parameters" inRequest:request];
        NSArray *keys = parameters.allKeys;
        NSMutableDictionary *filtered = [@{} mutableCopy];
        [keys enumerateObjectsUsingBlock:^(id key, NSUInteger idx, BOOL *stop) {
            id value = dictionary[key];
            if (value) {
                filtered[key] = value;
            }
        }];
        return [request.HTTPMethod isEqualToString:method]
        && [request.URL.path isEqualToString:path]
        && [parameters isEqualToDictionary:filtered];
    };
}

@end
