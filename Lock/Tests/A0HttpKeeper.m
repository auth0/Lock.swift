// A0HttpKeeper.m
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

#import "A0HttpKeeper.h"
#import <OHHTTPStubs/OHHTTPStubs.h>

@implementation A0HttpKeeper

- (void)returnSuccessfulLoginWithFilter:(HTTPFilter)filter {
    [OHHTTPStubs stubRequestsPassingTest:filter withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [[OHHTTPStubsResponse alloc] initWithFileAtPath:OHPathForFile(@"POST-oauth-ro.response", self.class) statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }].name = @"OAuth RO Endpoint Success";
}

- (void)returnProfileWithFilter:(HTTPFilter)filter {
    [OHHTTPStubs stubRequestsPassingTest:filter withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [[OHHTTPStubsResponse alloc] initWithFileAtPath:OHPathForFile(@"POST-tokeninfo.response", self.class) statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }].name = @"JWT token info Success";
}

- (void)failWithFilter:(HTTPFilter)filter message:(NSString *)message {
    [OHHTTPStubs stubRequestsPassingTest:filter withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSError *error = [NSError errorWithDomain: @"com.auth0" code: -9999999 userInfo: @{NSLocalizedDescriptionKey: message}];
        return [[OHHTTPStubsResponse alloc] initWithError:error];
    }].name = @"Kill it with fire!";
}

- (void)failForAllRequests {
    [OHHTTPStubs stubRequestsPassingTest:^BOOL(NSURLRequest *request) { return YES; } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSError *error = [NSError errorWithDomain: @"com.auth0" code: -9999999 userInfo: @{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"%@ You shall not pass!", request.URL]}];
        return [[OHHTTPStubsResponse alloc] initWithError:error];
    }].name = @"YOU SHALL NOT PASS!";
}

- (void)returnSignUpWithFilter:(HTTPFilter)filter {
    [OHHTTPStubs stubRequestsPassingTest:filter withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [[OHHTTPStubsResponse alloc] initWithFileAtPath:OHPathForFile(@"POST-dbconnections-signup.response", self.class) statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }].name = @"DB SignUp";
}

- (void)returnChangePasswordWithFilter:(HTTPFilter)filter {
    [OHHTTPStubs stubRequestsPassingTest:filter withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [[OHHTTPStubsResponse alloc] initWithFileAtPath:OHPathForFile(@"POST-dbconnections-change-password.response", self.class) statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }].name = @"DB Change Password";
}

- (void)returnDelegationInfoWithFilter:(HTTPFilter)filter {
    [OHHTTPStubs stubRequestsPassingTest:filter withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [[OHHTTPStubsResponse alloc] initWithFileAtPath:OHPathForFile(@"POST-delegation.response", self.class) statusCode:200 headers:@{@"Content-Type":@"application/json"}];
    }].name = @"Delegation";
}

- (void)unlinkUserWithFilter:(HTTPFilter)filter {
    [OHHTTPStubs stubRequestsPassingTest:filter withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        return [[OHHTTPStubsResponse alloc] initWithData:[@"OK" dataUsingEncoding:NSUTF8StringEncoding] statusCode:200 headers:@{@"Content-Type":@"test/plain"}];
    }].name = @"Unlink account";
}

@end
