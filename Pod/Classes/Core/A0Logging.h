//
//  A0Logging.h
//  Pods
//
//  Created by Hernan Zalazar on 8/11/14.
//
//

#import <CocoaLumberjack/DDLog.h>

static const int auth0LogLevel = LOG_LEVEL_ALL;

#define AUTH0_LOG_CONTEXT 58205

#define Auth0LogError(frmt, ...)     SYNC_LOG_OBJC_MAYBE(auth0LogLevel, LOG_FLAG_ERROR,   AUTH0_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define Auth0LogWarn(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(auth0LogLevel, LOG_FLAG_WARN,    AUTH0_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define Auth0LogInfo(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(auth0LogLevel, LOG_FLAG_INFO,    AUTH0_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define Auth0LogDebug(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(auth0LogLevel, LOG_FLAG_DEBUG,  AUTH0_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define Auth0LogVerbose(frmt, ...)  ASYNC_LOG_OBJC_MAYBE(auth0LogLevel, LOG_FLAG_VERBOSE, AUTH0_LOG_CONTEXT, frmt, ##__VA_ARGS__)
