//
//  A0AppDelegate.m
//  Auth0Client
//
//  Created by CocoaPods on 06/26/2014.
//  Copyright (c) 2014 Hernan Zalazar. All rights reserved.
//

#import "A0AppDelegate.h"
#import <Auth0Client/A0SocialAuthenticator.h>
#import <CocoaLumberjack/DDASLLogger.h>
#import <CocoaLumberjack/DDTTYLogger.h>
#import <CocoaLumberjack/DDLog.h>
#import <Auth0Client/A0Logging.h>

@implementation A0AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
#if DEBUG
    [[DDTTYLogger sharedInstance] setColorsEnabled:YES];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:0.400 green:0.800 blue:1.000 alpha:1.000] backgroundColor:nil forFlag:LOG_FLAG_INFO];
    [[DDTTYLogger sharedInstance] setForegroundColor:[UIColor colorWithRed:0.400 green:1.000 blue:0.400 alpha:1.000] backgroundColor:nil forFlag:LOG_FLAG_DEBUG];
#endif
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[A0SocialAuthenticator sharedInstance] handleURL:url sourceApplication:sourceApplication];
}
@end
