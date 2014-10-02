//
//  Application.h
//  basic-sample
//
//  Created by Martin Gontovnikas on 30/09/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

#import <foundation/Foundation.h>

@class UICKeyChainStore;

@interface Application : NSObject

@property (strong, nonatomic) UICKeyChainStore *store;

+ (Application *)sharedInstance;

@end