//  A0UserIdentity.m
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

#import "A0UserIdentity.h"

@implementation A0UserIdentity

- (instancetype)initWithUserId:(NSString *)userId
                      provider:(NSString *)provider
                    connection:(NSString *)connection
                        social:(NSNumber *)social
                   accessToken:(NSString *)accessToken
             accessTokenSecret:(NSString *)accessTokenSecret
                   profileData:(NSDictionary *)profileData {
    self = [super init];
    if (self) {
        _userId = userId;
        _provider = provider;
        _connection = connection;
        _social = social.boolValue;
        _accessToken = accessToken;
        _accessTokenSecret = accessTokenSecret;
        _profileData = profileData;
    }
    return self;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDict {
    return [self initWithUserId:JSONDict[@"user_id"]
                       provider:JSONDict[@"provider"]
                     connection:JSONDict[@"connection"]
                         social:JSONDict[@"isSocial"]
                    accessToken:JSONDict[@"access_token"]
              accessTokenSecret:JSONDict[@"access_token_secret"]
                    profileData:JSONDict[@"profileData"]];
}

- (NSString *)identityId {
    return [NSString stringWithFormat:@"%@|%@", self.provider, self.userId];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithUserId:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(userId))]
                       provider:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(provider))]
                     connection:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(connection))]
                         social:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(isSocial))]
                    accessToken:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(accessToken))]
              accessTokenSecret:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(accessTokenSecret))]
                    profileData:[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(profileData))]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (self.userId) {
        [aCoder encodeObject:self.userId forKey:NSStringFromSelector(@selector(userId))];
    }
    if (self.provider) {
        [aCoder encodeObject:self.provider forKey:NSStringFromSelector(@selector(provider))];
    }
    if (self.connection) {
        [aCoder encodeObject:self.connection forKey:NSStringFromSelector(@selector(connection))];
    }
    if (self.accessToken) {
        [aCoder encodeObject:self.accessToken forKey:NSStringFromSelector(@selector(accessToken))];
    }
    if (self.accessTokenSecret) {
        [aCoder encodeObject:self.accessTokenSecret forKey:NSStringFromSelector(@selector(accessTokenSecret))];
    }
    if (self.profileData) {
        [aCoder encodeObject:self.profileData forKey:NSStringFromSelector(@selector(profileData))];
    }
    [aCoder encodeObject:@(self.isSocial) forKey:NSStringFromSelector(@selector(isSocial))];
}

@end
