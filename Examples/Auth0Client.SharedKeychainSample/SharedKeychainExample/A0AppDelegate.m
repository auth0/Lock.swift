//
//  A0AppDelegate.m
//  SharedKeychainExample
//
//  Created by Hernan Zalazar on 8/20/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

#import "A0AppDelegate.h"
#import <UICKeyChainStore/UICKeyChainStore.h>

@implementation A0AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    UICKeyChainStore *store = [UICKeyChainStore keyChainStoreWithService:@"Auth0" accessGroup:kAuth0KeychainAccessGroup];
    if (![store stringForKey:@"refresh_token"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAuth0NoRefreshTokenNotificationName object:self];
    } else {
        [[NSNotificationCenter defaultCenter] postNotificationName:kAuth0RefreshTokenNotificationName object:self];
    }
}

@end
