//
//  A0JSONResponseSerializerSpec.m
//  Auth0Client
//
//  Created by Hernan Zalazar on 8/29/14.
//  Copyright 2014 Auth0. All rights reserved.
//

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
