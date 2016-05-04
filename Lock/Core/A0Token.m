// A0Token.m
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

#import "A0Token.h"

@implementation A0Token

- (instancetype)initWithAccessToken:(NSString *)accessToken
                            idToken:(NSString *)idToken
                          tokenType:(NSString *)tokenType
                       refreshToken:(NSString *)refreshToken {
    self = [super init];
    if (self) {
        NSAssert(idToken.length > 0, @"Must have a valid id token");
        NSAssert(tokenType.length > 0, @"Must have a valid token type");
        _accessToken = [accessToken copy];
        _idToken = [idToken copy];
        _tokenType = [tokenType copy];
        _refreshToken = [refreshToken copy];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    return [self initWithAccessToken:dictionary[@"access_token"]
                             idToken:dictionary[@"id_token"]
                           tokenType:dictionary[@"token_type"]
                        refreshToken:dictionary[@"refresh_token"]];
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<A0Token access_token = '%@'; id_token = '%@' token_type = %@; refresh_token = '%@'>", self.accessToken, self.idToken, self.tokenType, self.refreshToken];
}

#pragma mark - NSSecureCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [self initWithAccessToken:[aDecoder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(accessToken))]
                             idToken:[aDecoder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(idToken))]
                           tokenType:[aDecoder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(tokenType))]
                        refreshToken:[aDecoder decodeObjectOfClass:NSString.class forKey:NSStringFromSelector(@selector(refreshToken))]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    if (self.accessToken) {
        [aCoder encodeObject:self.accessToken forKey:NSStringFromSelector(@selector(accessToken))];
    }
    if (self.refreshToken) {
        [aCoder encodeObject:self.refreshToken forKey:NSStringFromSelector(@selector(refreshToken))];
    }
    [aCoder encodeObject:self.idToken forKey:NSStringFromSelector(@selector(idToken))];
    [aCoder encodeObject:self.tokenType forKey:NSStringFromSelector(@selector(tokenType))];
}

+ (BOOL)supportsSecureCoding {
    return YES;
}
@end
