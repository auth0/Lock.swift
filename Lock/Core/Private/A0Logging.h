// A0Logging.h
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

#import <CocoaLumberjack/CocoaLumberjack.h>

#ifndef Auth0_Logging_h
#define Auth0_Logging_h

static DDLogLevel auth0LogLevel = DDLogLevelOff;

#define AUTH0_LOG_CONTEXT 28840 //Auth0

#define A0LogError(frmt, ...)    LOG_MAYBE(NO, auth0LogLevel, DDLogFlagError, AUTH0_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define A0LogWarn(frmt, ...)     LOG_MAYBE(LOG_ASYNC_ENABLED, auth0LogLevel, DDLogFlagWarning, AUTH0_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define A0LogInfo(frmt, ...)     LOG_MAYBE(LOG_ASYNC_ENABLED, auth0LogLevel, DDLogFlagInfo, AUTH0_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define A0LogDebug(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, auth0LogLevel, DDLogFlagDebug, AUTH0_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)
#define A0LogVerbose(frmt, ...)  LOG_MAYBE(LOG_ASYNC_ENABLED, auth0LogLevel, DDLogFlagVerbose, AUTH0_LOG_CONTEXT, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define AUTH0_DYNAMIC_LOGGER_METHODS                \
    + (DDLogLevel)ddLogLevel {                      \
        return auth0LogLevel;                       \
    }                                               \
                                                    \
    + (void)ddSetLogLevel:(DDLogLevel)logLevel {    \
        auth0LogLevel = logLevel;                   \
    }
#endif