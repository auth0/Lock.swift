//
//  A0ProgressDisplay.h
//  Pods
//
//  Created by Hernan Zalazar on 7/23/14.
//
//

#import <Foundation/Foundation.h>

@protocol A0ProgressDisplay <NSObject>

@required

- (void)showInProgress;

- (void)hideInProgress;

@end
