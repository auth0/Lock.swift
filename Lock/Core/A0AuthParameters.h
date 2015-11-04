//  A0AuthParameters.h
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

///----------------------------------------
/// @name Auth0 API basic option keys
///----------------------------------------

/**
 *  'scope' option key
 */
FOUNDATION_EXPORT NSString * const A0ParameterScope;

/**
 *  'device' option key. Used only when scope has 'offline_access'.
 */
FOUNDATION_EXPORT NSString * const A0ParameterDevice;

/**
 *  'protocol' option key
 */
FOUNDATION_EXPORT NSString * const A0ParameterProtocol;

/**
 *  'state' option key
 */
FOUNDATION_EXPORT NSString * const A0ParameterState;

/**
 *  'nonce' option key
 */
FOUNDATION_EXPORT NSString * const A0ParameterNonce;

/**
 *  'offline_mode' option key
 */
FOUNDATION_EXPORT NSString * const A0ParameterOfflineMode;

/**
 *  'connection_scopes' option key
 */
FOUNDATION_EXPORT NSString * const A0ParameterConnectionScopes;

/**
 *  'access_token' option key
 */
FOUNDATION_EXPORT NSString * const A0ParameterAccessToken;

/**
 *  'main_access_token' option key
 */
FOUNDATION_EXPORT NSString * const A0ParameterMainAccessToken;

/**
 *  'connection' option key
 */
FOUNDATION_EXPORT NSString * const A0ParameterConnection;

///----------------------------------------
/// @name Auth0 API Scope values
///----------------------------------------

/**
 'openid' scope
 */
FOUNDATION_EXPORT NSString * const A0ScopeOpenId;
/**
 'offline_access' scope
 */
FOUNDATION_EXPORT NSString * const A0ScopeOfflineAccess;
/**
 'openid profile' scope
 */
FOUNDATION_EXPORT NSString * const A0ScopeProfile;

///----------------------------------------
/// @name Delegation API option keys
///----------------------------------------

/**
 'api_type' delegation API parameter
 */
FOUNDATION_EXTERN NSString * const A0ParameterAPIType;
/**
 'target' delegation API parameter
 */
FOUNDATION_EXTERN NSString * const A0ParameterTarget;

/**
 *  `A0AuthParameters` handles optional parameters for all Auth0 API calls and it's default values. It can be used with `A0APIClient` methods or as global parameters when using `A0AuthenticationViewController` to handle the authentication UI for you.
 */
@interface A0AuthParameters : NSObject<NSCopying>

/**
 *  Scope values to send to the API, it can't be nil so if nil it's stored it will reset to default values.
 *  Default are 'openid' and 'offline_access'.
 */
@property (copy, nonatomic) NSArray *scopes;

/**
 *  Device name, it will only be set when 'offline_access' is one of the scopes. By default is the name returned by [[UIDevice currentDevice] name]
 */
@property (copy, nullable, nonatomic) NSString *device;

/**
 *  Access token used when linking an account with an existing one. By default is nil
 */
@property (copy, nullable, nonatomic) NSString *accessToken;

/**
 *  Protocol used for authentication. By default is nil (the same as using `oauth2`).
 */
@property (copy, nullable, nonatomic) NSString *protocol;

/**
 *  Value used to avoid a replay attack that is part of _OpenID_ protocol. By default is nil
 */
@property (copy, nullable, nonatomic) NSString *nonce;

/**
 *  Offline mode for authentication. By default is nil
 */
@property (copy, nullable, nonatomic) NSString *offlineMode;

/**
 *  Value that will be received with the authentication response. By default is nil
 */
@property (copy, nullable, nonatomic) NSString *state;

/**
 *  Specify scopes for connections. e.g. ask facebook for user's email. By default is nil
 */
@property (copy, nullable, nonatomic) NSDictionary *connectionScopes;

/**
 *  Initialise the parameters with default values.
 *
 *  @return instance with default values for 'scope' and 'device'
 */
- (instancetype)init;

/**
 *  Initialise the parameter with the given scopes. If 'offline_access' is in the array, it will set 'device' value too.
 *
 *  @param scopes list of scopes to use.
 *
 *  @return initialised instance
 */
- (instancetype)initWithScopes:(NSArray *)scopes;

/**
 *  Initialise the parameters with the values from the dictionary. Keys thar aren't 'scope' and 'device' are stored in extraParams property.
 *
 *  @param dictionary parameter values and keys.
 *
 *  @return initialised instance.
 */
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/**
 *  Creates new parameters with default values.
 *
 *  @return a new instance.
 */
+ (instancetype)newDefaultParams;

/**
 *  Create new parameters with a defined scope.
 *
 *  @param scopes list of scopes
 *
 *  @return a new instance
 */
+ (instancetype)newWithScopes:(NSArray *)scopes;

/**
 *  Create new parameters from a dictionary
 *
 *  @param dictionary parameter values
 *
 *  @return a new instance
 */
+ (instancetype)newWithDictionary:(NSDictionary *)dictionary;

/**
 *  Returns a dictionary containing all values stored in the instance.
 *
 *  @return a dictionary with all values using valid key names to send to Auth0 API.
 */
- (NSDictionary *)asAPIPayload;

/**
 *  Add the values from the dictionary to the parameters.
 *
 *  @param dictionary values to add as parameters.
 */
- (void)addValuesFromDictionary:(NSDictionary *)dictionary;

/**
 *  Add the values from another parameter object
 *
 *  @param parameters values to add as parameters.
 */
- (void)addValuesFromParameters:(A0AuthParameters *)parameters;

- (nullable id)objectForKeyedSubscript:(NSString *)key;
- (void)setObject:(nullable id)obj forKeyedSubscript:(NSString *)key;

@end

@interface A0AuthParameters (Deprecated)

/**
 *  Adds a new value to the parameters list.
 *
 *  @param value a value to add
 *  @param key   key for the value.
 *  @deprecated 1.12.0
 */
- (void)setValue:(NSString *)value forKey:(NSString *)key DEPRECATED_ATTRIBUTE;

/**
 *  Returns a value stored using the given key
 *
 *  @param key a key to retrieve it's value
 *  @deprecated 1.12.0
 *
 *  @return a value or nil if it's not stored.
 */
- (nullable NSString *)valueForKey:(NSString *)key DEPRECATED_ATTRIBUTE;

@end
NS_ASSUME_NONNULL_END
