// A0GenericAPIErrorHandlerSpec.m
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

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import "A0GenericAPIErrorHandler.h"
#import "A0GlobalHelperFunctions.h"

static NSString *ErrorCode = @"invalid";
static NSString *ErrorString = @"something_invalid";
static NSString *Message = @"An error has ocurred";

QuickSpecBegin(A0GenericAPIErrorHandlerSpec)

__block A0GenericAPIErrorHandler *handler;

describe(@"show message for error code", ^{

    beforeEach(^{
        handler = [A0GenericAPIErrorHandler handlerForCode:ErrorCode returnMessage:Message];
    });

    it(@"should return constant message for code", ^{
        NSError *error = createError(@{@"code": ErrorCode});
        expect([handler localizedMessageFromError:error]).to(equal(Message));
    });

    it(@"should return nil for uknown code", ^{
        NSError *error = createError(@{@"code": [[NSUUID UUID] UUIDString]});
        expect([handler localizedMessageFromError:error]).to(beNil());
    });

});

describe(@"show message for multiple error codes", ^{

    beforeEach(^{
        handler = [A0GenericAPIErrorHandler handlerForCodes:@[@"code1", @"code2"] returnMessage:Message];
    });

    it(@"should return constant message for both codes", ^{
        NSError *error = createError(@{@"code": @"code1"});
        expect([handler localizedMessageFromError:error]).to(equal(Message));
        error = createError(@{@"code": @"code2"});
        expect([handler localizedMessageFromError:error]).to(equal(Message));
    });

    it(@"should return nil for uknown code", ^{
        NSError *error = createError(@{@"code": [[NSUUID UUID] UUIDString]});
        expect([handler localizedMessageFromError:error]).to(beNil());
    });
    
});


describe(@"show message for error", ^{

    beforeEach(^{
        handler = [A0GenericAPIErrorHandler handlerForErrorString:ErrorString returnMessage:Message];
    });

    it(@"should return constant message for code", ^{
        NSError *error = createError(@{@"error": ErrorString});
        expect([handler localizedMessageFromError:error]).to(equal(Message));
    });

    it(@"should return nil for uknown code", ^{
        NSError *error = createError(@{@"error": [[NSUUID UUID] UUIDString]});
        expect([handler localizedMessageFromError:error]).to(beNil());
    });
    
});


QuickSpecEnd
