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

#import <CocoaLumberjack/DDLog.h>

static const int auth0LogLevel = LOG_LEVEL_ALL;

#define AUTH0_LOG_CONTEXT 58205

#define Auth0LogError(frmt, ...)     SYNC_LOG_OBJC_MAYBE(auth0LogLevel, LOG_FLAG_ERROR,   AUTH0_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define Auth0LogWarn(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(auth0LogLevel, LOG_FLAG_WARN,    AUTH0_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define Auth0LogInfo(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(auth0LogLevel, LOG_FLAG_INFO,    AUTH0_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define Auth0LogDebug(frmt, ...)     ASYNC_LOG_OBJC_MAYBE(auth0LogLevel, LOG_FLAG_DEBUG,  AUTH0_LOG_CONTEXT, frmt, ##__VA_ARGS__)
#define Auth0LogVerbose(frmt, ...)  ASYNC_LOG_OBJC_MAYBE(auth0LogLevel, LOG_FLAG_VERBOSE, AUTH0_LOG_CONTEXT, frmt, ##__VA_ARGS__)
