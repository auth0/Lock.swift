//
//  A0BasicValidator.m
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

#import "A0BasicValidator.h"

@interface A0BasicValidator ()

@property (strong, nonatomic) NSPredicate *emailPredicate;
@property (assign, nonatomic) BOOL usesEmail;

@end

@implementation A0BasicValidator

- (instancetype)initWithUsesEmail:(BOOL)usesEmail {
    self = [super init];
    if (self) {
        NSString *emailRegex = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
        _emailPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        _usesEmail = usesEmail;
    }
    return self;
}

- (BOOL)validateUsername:(NSString *)username {
    if (self.usesEmail) {
        return [self.emailPredicate evaluateWithObject:username];
    } else {
        return username.length > 0;
    }
}

- (BOOL)validatePassword:(NSString *)password {
    return password.length > 0;
}

@end
