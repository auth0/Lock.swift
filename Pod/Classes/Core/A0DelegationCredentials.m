//
//  A0DelegationCredentials.m
//  Pods
//
//  Created by Ike Ellis on 10/21/14.
//
//

#import "A0DelegationCredentials.h"


@implementation A0DelegationCredentials

- (instancetype)initWithAccessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey
                       sessionKey:(NSString *)sessionKey
                       expiration:(NSDate *)expiration {
    
    self = [super init];
    if (self != nil) {
        
        _accessKey = accessKey;
        _secretKey = secretKey;
        _sessionKey = sessionKey;
        _expiration = expiration;
    }
    
    return self;
}


- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
        
    return [self initWithAccessKey:dictionary[@"AccessKeyId"] secretKey:dictionary[@"SecretAccessKey"] sessionKey:dictionary[@"SessionToken"] expiration:dictionary[@"Expiration"]];
}



- (NSString *)description {
    return [NSString stringWithFormat:@"<A0DelegationCredentials accessKey = '%@'; secretKey = '%@' sessionKey = %@; expiration = '%@'>", self.accessKey, self.secretKey, self.sessionKey, self.expiration];
}

@end
