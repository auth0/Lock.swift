//
//  A0TokenInfo.m
//  Pods
//
//  Created by Hernan Zalazar on 8/10/14.
//
//

#import "A0TokenInfo.h"

@implementation A0TokenInfo

- (instancetype)initWithAccessToken:(NSString *)accessToken
                            idToken:(NSString *)idToken
                          tokenType:(NSString *)tokenType {
    self = [super init];
    if (self) {
        NSAssert(accessToken.length > 0, @"Must have a valid access token");
        NSAssert(idToken.length > 0, @"Must have a valid id token");
        NSAssert(tokenType.length > 0, @"Must have a valid token type");
        _accessToken = [accessToken copy];
        _idToken = [idToken copy];
        _tokenType = [tokenType copy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    return [self initWithAccessToken:dictionary[@"access_token"]
                             idToken:dictionary[@"id_token"]
                           tokenType:dictionary[@"token_type"]];
}

@end
