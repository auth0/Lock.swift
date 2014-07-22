//
//  A0ChangePasswordCredentialValidator.h
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

#import "A0BasicValidator.h"
#import "A0CredentialValidator.h"

@interface A0ChangePasswordCredentialValidator : A0BasicValidator<A0CredentialValidator>

- (void)setUsername:(NSString *)username password:(NSString *)password repeatPassword:(NSString *)repeatPassword;

@end
