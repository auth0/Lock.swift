//
//  A0BasicValidator.h
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

#import <Foundation/Foundation.h>

@interface A0BasicValidator : NSObject

@property (readonly, nonatomic) BOOL usesEmail;

- (instancetype)initWithUsesEmail:(BOOL)usesEmail;

- (BOOL)validateUsername:(NSString *)username;
- (BOOL)validatePassword:(NSString *)password;

@end
