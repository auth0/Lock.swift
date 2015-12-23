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
            _social = [self selectFromArray:application.socialStrategies passingTest:^BOOL(A0Strategy *strategy) {
                A0Connection *connection = strategy.connections.firstObject;
                return [connectionNames containsObject:connection.name];
            }];

            NSMutableArray *filtered = [@[] mutableCopy];
            [application.enterpriseStrategies enumerateObjectsUsingBlock:^(A0Strategy *strategy, NSUInteger idx, BOOL *stop) {
                NSArray *connections = [self selectFromArray:strategy.connections passingTest:^BOOL(A0Connection *connection) {
                    return [connectionNames containsObject:connection.name];
                }];
                if (connections.count > 0) {
                    A0Strategy *newStrategy = [A0Strategy newEnterpriseStrategyWithName:strategy.name connections:connections];
                    [filtered addObject:newStrategy];
                }
            }];
            _enterprise = [NSArray arrayWithArray:filtered];
            _activeDirectory = [_enterprise filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", A0StrategyNameActiveDirectory]].firstObject;
            NSArray *dbConnections = [self selectFromArray:application.databaseStrategy.connections passingTest:^BOOL(A0Connection *connection) {
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

- (NSArray *)selectFromArray:(NSArray *)array passingTest:(BOOL(^)(id element))test {
    __block NSMutableArray *result = [@[] mutableCopy];
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (test(obj)) {
            [result addObject:obj];
        }
    }];
    return [NSArray arrayWithArray:result];
}

- (BOOL)shouldDisableSignUp:(BOOL)disableSignUp {
    A0Connection *database = self.defaultDatabaseConnection;
    return ![database[A0ConnectionShowSignUp] boolValue] || disableSignUp;
}

- (BOOL)shouldDisableResetPassword:(BOOL)disableResetPassword {
    A0Connection *database = self.defaultDatabaseConnection;
    return ![database[A0ConnectionShowForgot] boolValue] || disableResetPassword;
}

- (BOOL)shouldUseWebAuthenticationForConnection:(A0Connection *)connection {
    A0Strategy *strategy = [self.application enterpriseStrategyWithConnection:connection.name];
    return [self.enterpriseConnectionsUsingWebForm containsObject:connection.name] || !strategy.useResourceOwnerEndpoint;
}
@end
