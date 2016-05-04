// A0PasswordStrengthErrorHandler.m
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

#import "A0PasswordStrengthErrorHandler.h"
#import "NSError+A0APIError.h"
#import "Constants.h"

static NSString *A0RuleMessage(NSDictionary *rule) {
    return rule[@"message"];
}

static id A0RuleFormat(NSDictionary *rule, NSInteger index) {
    return rule[@"format"][index];
}

@implementation A0PasswordStrengthErrorHandler

- (NSString *)localizedMessageFromError:(NSError *)error {
    NSString *actual = [error a0_error];
    if (![actual isEqualToString:@"invalid_password"]) {
        return nil;
    }
    NSDictionary *description = [error a0_payload][@"description"];
    NSArray *rules = description[@"rules"];
    NSString *title = A0LocalizedString(@"Password failed to meet the requirements: ");
    NSMutableArray *errors = [@[] mutableCopy];
    for (NSDictionary *rule in rules) {
        NSString *ruleCode = rule[@"code"];
        if (![rule[@"verified"] boolValue]) {
            if ([ruleCode isEqualToString:@"lengthAtLeast"]) {
                [errors addObject:[self lengthMessageFromRule:rule]];
            } else if ([ruleCode isEqualToString:@"containsAtLeast"] || [ruleCode isEqualToString:@"shouldContain"]) {
                [errors addObject:[self characterSetMessageFromRule:rule]];
            } else if ([ruleCode isEqualToString:@"identicalChars"]) {
                [errors addObject:[self identicalCharacterMessageFromRule:rule]];
            }
        }
    }
    return [title stringByAppendingString:[errors componentsJoinedByString:@" "]];
}

- (NSString *)lengthMessageFromRule:(NSDictionary *)rule {
    return [[NSString localizedStringWithFormat:A0RuleMessage(rule), [A0RuleFormat(rule, 0) intValue]] stringByAppendingString:@"."];
}

- (NSString *)identicalCharacterMessageFromRule:(NSDictionary *)rule {
    NSString *format = [A0RuleMessage(rule) stringByReplacingOccurrencesOfString:@"%s" withString:@"%@"];
    return [[NSString localizedStringWithFormat:format, [A0RuleFormat(rule, 0) intValue], A0RuleFormat(rule, 1)] stringByAppendingString:@"."];
}

- (NSString *)characterSetMessageFromRule:(NSDictionary *)rule {
    NSString *messageStart = [NSString localizedStringWithFormat:A0RuleMessage(rule), [A0RuleFormat(rule, 0) intValue], [A0RuleFormat(rule, 1) intValue]];
    __block NSMutableArray *sets = [@[] mutableCopy];
    [rule[@"items"] enumerateObjectsUsingBlock:^(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        [sets addObject:A0LocalizedString(item[@"message"])];
    }];
    return [[[messageStart stringByAppendingString:@" "] stringByAppendingString:[sets componentsJoinedByString:@", "]] stringByAppendingString:@"."];
}
@end
