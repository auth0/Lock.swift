//
//  AppDelegate.m
//  TouchID
//
//  Created by Hernan Zalazar on 11/11/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

#import "AppDelegate.h"

#if RELEASE
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#endif

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
#if RELEASE
    [Fabric with:@[CrashlyticsKit]];
#endif
    return YES;
}

@end
