//
//  A0DelegationCredentials.h
//  Pods
//
//  Created by Ike Ellis on 10/21/14.
//
//

#import <Foundation/Foundation.h>

@interface A0DelegationCredentials : NSObject


@property (readonly, nonatomic) NSString *accessKey;

@property (readonly, nonatomic) NSString *secretKey;

@property (readonly, nonatomic) NSString *sessionKey;

@property (readonly, nonatomic) NSDate *expiration;

/**
 *  Initialise credentials
 *
 *  @param accessKey
 *  @param secretKey
 *  @param sessionKey
 *  @param expiration
 *
 *  @return new instance
 */
- (instancetype)initWithAccessKey:(NSString *)accessKey
                        secretKey:(NSString *)secretKey
                       sessionKey:(NSString *)sessionKey
                       expiration:(NSString *)expiration;


/**
 *  Initialise credentials from a JSON dictionary
 *
 *  @param dictionary JSON dictionary
 *
 *  @return a new instance
 *
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;


@end
