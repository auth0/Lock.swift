// A0JSONResponseSerializer.m
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

#import "A0JSONResponseSerializer.h"
#import "A0Errors.h"
#import "NSError+A0APIError.h"

@implementation A0JSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error {
    id responseObject = nil;
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        NSError *validateError = *error;
        if (validateError) {
            NSError *jsonError;
            NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (jsonError) {
                NSString *stringError = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                payload = @{
                            @"error_description": stringError,
                            @"error": stringError,
                            };
            }
            (*error) = [validateError a0_errorWithPayload:payload];
        }
    } else {
        responseObject = [super responseObjectForResponse:response data:data error:error];
        //FIXME: change password answer is not a valid JSON so we need this hack
        if (!responseObject && [response.URL.path isEqualToString:@"/dbconnections/change_password"]) {
            responseObject = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            if (error != NULL) {
                *error = nil;
            }
        }
    }
    return responseObject;
}

@end
