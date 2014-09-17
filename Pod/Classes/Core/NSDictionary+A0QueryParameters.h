//
//  NSDictionary+A0QueryParameters.h
//  Pods
//
//  Created by Hernan Zalazar on 9/17/14.
//
//

#import <Foundation/Foundation.h>

@interface NSDictionary (A0QueryParameters)

- (NSString *)queryString;

+ (NSDictionary *)fromQueryString:(NSString *)queryString;

@end
