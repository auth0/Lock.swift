//
//  A0Application.h
//  Pods
//
//  Created by Hernan Zalazar on 7/4/14.
//
//

#import <Foundation/Foundation.h>

@interface A0Application : NSObject

@property (strong, nonatomic, readonly) NSString *identifier;
@property (strong, nonatomic, readonly) NSString *tenant;
@property (strong, nonatomic, readonly) NSURL *authorizeURL;
@property (strong, nonatomic, readonly) NSURL *callbackURL;
@property (strong, nonatomic, readonly) NSArray *strategies;

- (instancetype)initWithJSONDictionary:(NSDictionary *)JSONDict;

- (BOOL)hasDatabaseConnection;

@end
