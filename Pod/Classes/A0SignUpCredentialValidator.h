//
//  A0SignUpCredentialValidator.h
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

#import "A0BasicValidator.h"
#import "A0CredentialValidator.h"

@interface A0SignUpCredentialValidator : A0BasicValidator<A0CredentialValidator>

- (void)setUsername:(NSString *)username password:(NSString *)password;

@end
