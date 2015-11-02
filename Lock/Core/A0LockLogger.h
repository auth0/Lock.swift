// A0LockLogger.h
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

/**
 *  Helper class to enable/disable logging of `Lock`.
 *  By default log is disabled but it can be enabled to log all types of messages or only error messages.
 *  Lock uses [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack) as the logging framework, 
 *  but you dont need to initialise it because `A0LockLogger` will do it for you if you enable logging. 
 *  However, if you already use `CocoaLumberjack` please enable `Lock`'s logs after initialising it in your App.
 */
@interface A0LockLogger : NSObject

/**
 *  Enable all Lock's messages
 */
+ (void)logAll;

/**
 *  Enable only Lock's error messages
 */
+ (void)logError;

/**
 *  Disables all Lock's messages
 */
+ (void)logOff;

@end
