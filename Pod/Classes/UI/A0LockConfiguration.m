// A0LockConfiguration.m
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

#import "A0LockConfiguration.h"
#import "A0Application.h"
#import <ObjectiveSugar/ObjectiveSugar.h>
#import "A0Strategy.h"
#import "A0Connection.h"

@interface A0LockConfiguration ()
@property (strong, nonatomic) A0Application *application;
@property (strong, nonatomic) NSArray *enterprise;
@property (strong, nonatomic) NSArray *social;
@property (strong, nonatomic) A0Strategy *activeDirectory;
@property (strong, nonatomic) A0Strategy *database;
@end

@implementation A0LockConfiguration

- (instancetype)initWithApplication:(A0Application *)application filter:(NSArray *)connectionNames {
    self = [super init];
    NSAssert(application != nil, @"Must supply a non-nil application");
    if (self) {
        _application = application;
        if (connectionNames.count == 0) {
            _social = application.socialStrategies;
            _enterprise = application.enterpriseStrategies;
            _activeDirectory = application.activeDirectoryStrategy;
            _database = application.databaseStrategy;
        } else {
            _social = [application.socialStrategies select:^BOOL(A0Strategy *strategy) {
                A0Connection *connection = [strategy.connections detect:^BOOL(A0Connection *connection) {
                    return [connectionNames containsObject:connection.name];
                }];
                return connection != nil;
            }];

            _enterprise = [[application.enterpriseStrategies map:^id(A0Strategy *strategy) {
                NSArray *connections = [strategy.connections select:^BOOL(A0Connection *connection) {
                    return [connectionNames containsObject:connection.name];
                }];
                if (connections.count == 0) {
                    return [NSNull null];
                }
                return [A0Strategy newEnterpriseStrategyWithName:strategy.name connections:connections];
            }] select:^BOOL(id object) {
                return object != [NSNull null];
            }];
            _activeDirectory = [_enterprise detect:^BOOL(A0Strategy *strategy) {
                return [strategy.name isEqualToString:A0StrategyNameActiveDirectory];
            }];
            NSArray *dbConnections = [application.databaseStrategy.connections select:^BOOL(A0Connection *connection) {
                return [connectionNames containsObject:connection.name];
            }];
            _database = [A0Strategy newDatabaseStrategyWithConnections:dbConnections];
        }
    }
    return self;
}

- (NSArray *)socialStrategies {
    return self.social;
}

- (NSArray *)enterpriseStrategies {
    return self.enterprise;
}

- (A0Strategy *)activeDirectoryStrategy {
    return self.activeDirectory;
}

- (A0Connection *)defaultDatabaseConnection {
    NSArray *connections =  self.database.connections;
    __block A0Connection *defaultConnection = connections.firstObject;
    if (self.defaultDatabaseConnectionName) {
        [connections enumerateObjectsUsingBlock:^(A0Connection *connection, NSUInteger idx, BOOL *stop) {
            if ([connection.name isEqualToString:self.defaultDatabaseConnectionName]) {
                defaultConnection = connection;
                *stop = YES;
            }
        }];
    }
    return defaultConnection;
}

- (A0Connection *)defaultActiveDirectoryConnection {
    return self.activeDirectory.connections.firstObject;
}
@end
