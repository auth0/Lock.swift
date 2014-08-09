//
//  A0TwitterAuthentication.h
//  Pods
//
//  Created by Hernan Zalazar on 8/9/14.
//
//

#import <Foundation/Foundation.h>
#import "A0SocialProviderAuth.h"

@interface A0TwitterAuthentication : NSObject<A0SocialProviderAuth>

+ (A0TwitterAuthentication *)newTwitterAuthentication;

@end
