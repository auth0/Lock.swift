//
//  A0JSONResponseSerializer.m
//  Pods
//
//  Created by Hernan Zalazar on 7/22/14.
//
//

#import "A0JSONResponseSerializer.h"
#import "A0Errors.h"

@implementation A0JSONResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response data:(NSData *)data error:(NSError **)error {
    id responseObject = nil;
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        NSError *validateError = *error;
        if (validateError) {
            NSMutableDictionary *userInfo = [validateError.userInfo mutableCopy];
            NSError *jsonError;
            id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            if (!jsonError) {
                userInfo[A0JSONResponseSerializerErrorDataKey] = json;
            } else {
                NSString *stringError = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                userInfo[A0JSONResponseSerializerErrorDataKey] = @{
                                                                   @"error_description": stringError,
                                                                   @"error": stringError,
                                                                   };
            }
            NSError *newError = [NSError errorWithDomain:validateError.domain code:validateError.code userInfo:userInfo];
            (*error) = newError;
        }
    } else {
        responseObject = [super responseObjectForResponse:response data:data error:error];
        //FIXME: change password answer is not a valid JSON so we need this hack
        if (!responseObject && [response.URL.path isEqualToString:@"/dbconnections/change_password"]) {
            responseObject = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            *error = nil;
        }
    }
    return responseObject;
}

@end
