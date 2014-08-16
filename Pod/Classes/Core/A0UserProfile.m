// A0UserProfile.m
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

#import "A0UserProfile.h"

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@implementation A0UserProfile

- initWithUserId:(NSString *)userId
            name:(NSString *)name
        nickname:(NSString *)nickname
           email:(NSString *)email
         picture:(NSURL *)picture
       createdAt:(NSDate *)createdAt {
    self = [super init];
    if (self) {
        NSAssert(userId.length > 0, @"Should have a non empty user id");
        _userId = [userId copy];
        _name = [name copy];
        _nickname = [nickname copy];
        _email = [email copy];
        _picture = picture;
        _createdAt = createdAt;
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
                      createdAt:[formatter dateFromString:dictionary[@"created_at"]]];
}

@end
