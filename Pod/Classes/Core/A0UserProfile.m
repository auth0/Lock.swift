//
//  A0UserProfile.m
//  Pods
//
//  Created by Hernan Zalazar on 8/10/14.
//
//

#import "A0UserProfile.h"
#import "A0TokenInfo.h"

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@implementation A0UserProfile

- initWithUserId:(NSString *)userId
            name:(NSString *)name
        nickname:(NSString *)nickname
           email:(NSString *)email
         picture:(NSURL *)picture
       createdAt:(NSDate *)createdAt
       tokenInfo:(A0TokenInfo *)tokenInfo {
    self = [super init];
    if (self) {
        NSAssert(userId.length > 0, @"Should have a non empty user id");
        NSAssert(tokenInfo, @"Should have a token info");
        _userId = [userId copy];
        _name = [name copy];
        _nickname = [nickname copy];
        _email = [email copy];
        _picture = picture;
        _createdAt = createdAt;
        _tokenInfo = tokenInfo;
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    ISO8601DateFormatter *formatter = [[ISO8601DateFormatter alloc] init];
    return [self initWithUserId:dictionary[@"user_id"]
                           name:dictionary[@"name"]
                       nickname:dictionary[@"nickname"]
                          email:dictionary[@"email"]
                        picture:[NSURL URLWithString:dictionary[@"picture"]]
                      createdAt:[formatter dateFromString:dictionary[@"created_at"]]
                      tokenInfo:[[A0TokenInfo alloc] initWithDictionary:dictionary[@"token_info"]]];
}

@end
