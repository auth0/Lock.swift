//
//  A0CredentialValidator.h
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

#import <Foundation/Foundation.h>

@protocol A0CredentialValidator <NSObject>

@required

- (BOOL)validateCredential:(NSError **)error;

@end
