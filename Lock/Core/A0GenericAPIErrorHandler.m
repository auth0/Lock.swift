// A0GenericAPIErrorHandler.m
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

#import "A0GenericAPIErrorHandler.h"
#import "NSError+A0APIError.h"

typedef BOOL(^ErrorPredicateBlock)(NSError *error);

@interface A0GenericAPIErrorHandler ()

@property (copy, nonatomic) ErrorPredicateBlock shouldHandle;
@property (copy, nonatomic) NSString *message;

@end

@implementation A0GenericAPIErrorHandler

- (instancetype)initWithPredicateBlock:(ErrorPredicateBlock)block message:(NSString *)message {
    self = [super init];
    if (self) {
        _shouldHandle = [block copy];
        _message = [message copy];
    }
    return self;
}

- (NSString *)localizedMessageFromError:(NSError *)error {
    return self.shouldHandle(error) ? self.message : nil;
}

+ (A0GenericAPIErrorHandler *)handlerForCode:(NSString *)code returnMessage:(NSString *)message {
    return [[A0GenericAPIErrorHandler alloc] initWithPredicateBlock:^BOOL(NSError *error) {
        NSString *actual = [error a0_error];
        return [code isEqualToString:actual];
    } message:message];
}

+ (A0GenericAPIErrorHandler *)handlerForCodes:(NSArray *)codes returnMessage:(NSString *)message {
    return [[A0GenericAPIErrorHandler alloc] initWithPredicateBlock:^BOOL(NSError *error) {
        NSString *actual = [error a0_error];
        __block BOOL matches = NO;
        [codes enumerateObjectsUsingBlock:^(NSString *code, NSUInteger idx, BOOL *stop) {
            matches = [code isEqualToString:actual];
            *stop = matches;
        }];
        return matches;
    } message:message];
}

+ (A0GenericAPIErrorHandler *)handlerForErrorString:(NSString *)errorString returnMessage:(NSString *)message {
    return [[A0GenericAPIErrorHandler alloc] initWithPredicateBlock:^BOOL(NSError *error) {
        NSString *actual = [error a0_error];
        return [errorString isEqualToString:actual];
    } message:message];
}
@end
