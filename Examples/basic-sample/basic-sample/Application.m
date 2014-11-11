//
//  Application.m
//  basic-sample
//
//  Created by Martin Gontovnikas on 30/09/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

#import "Application.h"

#import <Lock/Lock.h>
#import <SimpleKeychain/A0SimpleKeychain.h>

@implementation Application

#pragma mark Singleton Method

+ (Application*)sharedInstance {
    static Application *sharedApplication = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedApplication = [[self alloc] init];
    });
    return sharedApplication;
}

- (id)init {
    self = [super init];
    if (self) {
        _store = [A0SimpleKeychain keychainWithService:@"Auth0"];
    }
    return self;
}

@end
