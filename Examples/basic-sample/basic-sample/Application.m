//
//  Application.m
//  basic-sample
//
//  Created by Martin Gontovnikas on 30/09/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

#import "Application.h"
#import <Auth0.iOS/Auth0.h>

@implementation Application

@synthesize session;

#pragma mark Singleton Methods

+ (Application*)sharedInstance {
    static Application *sharedApplication = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedApplication = [[self alloc] init];
    });
    return sharedApplication;
}

- (id)init {
    if (self = [super init]) {
        session = [A0Session newDefaultSession];
    }
    return self;
}

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
