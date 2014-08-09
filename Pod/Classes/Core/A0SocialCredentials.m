//
//  A0SocialCredentials.m
//  Pods
//
//  Created by Hernan Zalazar on 8/9/14.
//
//

#import "A0SocialCredentials.h"

@implementation A0SocialCredentials

- (instancetype)initWithAccessToken:(NSString *)accessToken extraInfo:(NSDictionary *)extraInfo {
    self = [super init];
    if (self) {
        _accessToken = [accessToken copy];
        _extraInfo = [extraInfo copy];
    }
    return self;
}

- (instancetype)initWithAccessToken:(NSString *)accessToken {
    return [self initWithAccessToken:accessToken extraInfo:nil];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@ accessToken=%@; extraInfo=%@;>", NSStringFromClass(self.class), _accessToken, _extraInfo];
}
@end
