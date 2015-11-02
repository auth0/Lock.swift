//  A0SimpleConnectionDomainMatcher.m
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

#import "A0SimpleConnectionDomainMatcher.h"
#import "A0Strategy.h"
#import "A0Connection.h"

@interface A0SimpleConnectionDomainMatcher ()
@property (strong, nonatomic) NSDictionary *connections;
@property (strong, nonatomic) NSDictionary *domains;
@end

@implementation A0SimpleConnectionDomainMatcher

- (instancetype)initWithStrategies:(NSArray *)strategies {
    self = [super init];
    if (self) {
        NSMutableDictionary *connections = [@{} mutableCopy];
        NSMutableDictionary *domains = [@{} mutableCopy];
        for (A0Strategy *strategy in strategies) {
            NSArray *filtered = [strategy.connections filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(A0Connection *connection, NSDictionary *bindings) {
                return connection[A0ConnectionDomain] != nil && connection[A0ConnectionDomain] != [NSNull null];
            }]];
            [filtered enumerateObjectsUsingBlock:^(A0Connection *connection, NSUInteger idx, BOOL *stop) {
                connections[connection.name] = connection;
                NSMutableArray *connectionDomains = [@[] mutableCopy];
                [connectionDomains addObject:connection[A0ConnectionDomain]];
                NSArray *aliases = connection[A0ConnectionDomainAliases];
                if (aliases.count > 0) {
                    [connectionDomains addObjectsFromArray:aliases];
                }
                NSMutableArray *result = [@[] mutableCopy];
                [connectionDomains enumerateObjectsUsingBlock:^(NSString *domain, NSUInteger idx, BOOL *stop) {
                    [result addObject:[A0SimpleConnectionDomainMatcher emailDomainPartFromDomain:domain]];
                }];
                domains[connection.name] = result;
            }];
        }
        _connections = connections;
        _domains = domains;
    }
    return self;
}

- (A0Connection *)connectionForEmail:(NSString *)email {
    __block A0Connection *connection;
    if (email.length == 0) {
        return nil;
    }
    [self.domains enumerateKeysAndObjectsUsingBlock:^(NSString *connectionName, NSArray *connectionDomains, BOOL *foundConnection) {
        __block NSString *connectionNameMatch;
        [connectionDomains enumerateObjectsUsingBlock:^(NSString *domain, NSUInteger idx, BOOL *stop) {
            *stop = [email hasSuffix:domain];
            connectionNameMatch = *stop ? connectionName : nil;
        }];
        if (connectionNameMatch) {
            connection = self.connections[connectionNameMatch];
        }
        *foundConnection = connection != nil;
    }];
    return connection;
}

+ (NSString *)emailDomainPartFromDomain:(NSString *)domain {
    return [@"@" stringByAppendingString:domain];
}

@end
