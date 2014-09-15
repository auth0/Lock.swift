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

- (NSDate *)expiresAt {
    NSDate *expiresAt = nil;
    NSArray *parts = [self.idToken componentsSeparatedByString:@"."];
    if (parts.count == 3) {
        NSString *claimsBase64 = parts[1];
        NSInteger claimsLength = claimsBase64.length;
        NSInteger requiredLength = (4 * ceil((double)claimsLength / 4.0));
        NSInteger paddingCount = requiredLength - claimsLength;

        if (paddingCount > 0) {
            NSString *padding =
            [[NSString string] stringByPaddingToLength:paddingCount
                                            withString:@"=" startingAtIndex:0];
            claimsBase64 = [claimsBase64 stringByAppendingString:padding];
        }

        NSData *claimsData = [[NSData alloc] initWithBase64EncodedString:claimsBase64 options:NSDataBase64DecodingIgnoreUnknownCharacters];
        NSError *error;
        if (claimsData) {
            NSDictionary *claimsJSON = [NSJSONSerialization JSONObjectWithData:claimsData options:0 error:&error];
            if (!error && claimsJSON[@"exp"] && [claimsJSON[@"exp"] isKindOfClass:NSNumber.class]) {
                NSNumber *expireFromEpoch = claimsJSON[@"exp"];
                expiresAt = [NSDate dateWithTimeIntervalSince1970:expireFromEpoch.doubleValue];
            } else {
                Auth0LogWarn(@"Invalid id_token claims part. Not valid json or missing exp attr");
            }
        } else {
            Auth0LogWarn(@"Invalid id_token claims part. Failed to decode base64");
        }
    } else {
        Auth0LogWarn(@"Invalid id_token. Not enough parts (Required 3 parts obtained %lu)", (unsigned long)parts.count);
    }
    return expiresAt;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<A0Token access_token = '%@'; id_token = '%@' token_type = %@; refresh_token = '%@'>", self.accessToken, self.idToken, self.tokenType, self.refreshToken];
}
@end
