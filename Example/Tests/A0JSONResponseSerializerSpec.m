//  A0JSONResponseSerializerSpec.m
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

#import "Specta.h"
#import "A0JSONResponseSerializer.h"
#import "A0Errors.h"

#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>

#define MOCKITO_SHORTHAND
#import <OCMockito/OCMockito.h>

SpecBegin(A0JSONResponseSerializer)

describe(@"A0JSONResponseSerializer", ^{

    __block A0JSONResponseSerializer *serializer;
    __block NSHTTPURLResponse *response;
    __block NSDictionary *jsonDict;
    __block NSError *error;

    beforeEach(^{
        response = mock(NSHTTPURLResponse.class);
        [given([response MIMEType]) willReturn:@"application/json"];
        serializer = [A0JSONResponseSerializer serializer];
    });

    afterEach(^{
        jsonDict = nil;
        error = nil;
    });

    describe(@"successful JSON response parsing", ^{

        beforeEach(^{
            [given([response statusCode]) willReturnInteger:200];
            NSData *jsonData = [@"{\"key\": \"value\"}" dataUsingEncoding:NSUTF8StringEncoding];
            jsonDict = [serializer responseObjectForResponse:response data:jsonData error:&error];
        });

        specify(@"no error", ^{
            expect(error).to.beNil();
        });

        specify(@"valid parsed json NSDictionary", ^{
            expect(jsonDict[@"key"]).to.equal(@"value");
        });

    });

    describe(@"successful non-JSON response parsing for change password", ^{

        __block NSString *message;

        beforeEach(^{
            [given([response statusCode]) willReturnInteger:200];
            [given([response URL]) willReturn:[NSURL URLWithString:@"https://auth0.com/dbconnections/change_password"]];
            NSData *data = [@"a non-JSON value" dataUsingEncoding:NSUTF8StringEncoding];
            message = [serializer responseObjectForResponse:response data:data error:&error];
        });

        specify(@"no error", ^{
            expect(error).to.beNil();
        });

        specify(@"valid parsed json NSDictionary", ^{
            expect(message).to.equal(@"a non-JSON value");
        });
        
    });
});

SpecEnd
