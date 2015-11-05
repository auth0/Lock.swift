// A0ServiceViewModel.m
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

#import "A0ServiceViewModel.h"
#import "A0Connection.h"
#import "A0Strategy.h"
#import "A0Theme.h"
#import "A0ServiceTheme.h"
#import "Constants.h"

@implementation A0ServiceViewModel

- (instancetype)initWithStrategy:(A0Strategy *)strategy connection:(A0Connection *)connection {
    self = [super init];
    if (self) {
        _name = strategy.name;
        _connection = connection;
    }
    return self;
}

- (A0ServiceTheme *)theme {
    return [[A0Theme sharedInstance] themeForStrategyName:self.name andConnectionName:self.connection.name];
}

@end

@implementation A0ServiceViewModel (Builder)

+ (NSArray *)servicesFromStrategy:(A0Strategy *)strategy {
    NSMutableArray *services = [NSMutableArray arrayWithCapacity:strategy.connections.count];
    for (A0Connection *connection in strategy.connections) {
        [services addObject:[[A0ServiceViewModel alloc] initWithStrategy:strategy connection:connection]];
    }
    return [NSArray arrayWithArray:services];
}

+ (NSArray *)servicesFromStrategies:(NSArray *)strategies {
    NSMutableArray *services = [NSMutableArray arrayWithCapacity:strategies.count];
    for (A0Strategy *strategy in strategies) {
        [services addObjectsFromArray:[self servicesFromStrategy:strategy]];
    }
    return [NSArray arrayWithArray:services];
}

@end