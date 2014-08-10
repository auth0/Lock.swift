//
//  A0TwitterAuthentication.h
//  Pods
//
//  Created by Hernan Zalazar on 8/9/14.
//
//

#import <Foundation/Foundation.h>
#import "A0SocialProviderAuth.h"

@interface A0TwitterAuthentication : NSObject<A0SocialAuthenticationProvider>

+ (A0TwitterAuthentication *)newAuthenticationWithKey:(NSString *)key andSecret:(NSString *)secret callbackURL:(NSURL *)callbackURL;

@end
