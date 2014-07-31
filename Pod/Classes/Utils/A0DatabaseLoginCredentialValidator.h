//
//  A0DatabaseLoginCredentialValidator.h
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

#import "A0CredentialValidator.h"
#import "A0BasicValidator.h"

@interface A0DatabaseLoginCredentialValidator : A0BasicValidator<A0CredentialValidator>

- (void)setUsername:(NSString *)username password:(NSString *)password;

@end
