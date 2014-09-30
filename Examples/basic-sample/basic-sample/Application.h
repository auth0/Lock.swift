//
//  Application.h
//  basic-sample
//
//  Created by Martin Gontovnikas on 30/09/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

#import <foundation/Foundation.h>
#import <Auth0.iOS/Auth0.h>

@interface Application : NSObject {
    A0Session *session;
}

@property (nonatomic, retain) A0Session *session;

+ (Application*)sharedInstance;

@end