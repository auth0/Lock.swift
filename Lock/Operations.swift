// Operations.swift
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
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

import Foundation

typealias DebounceAction = () -> ()

func debounce(delay: NSTimeInterval, queue: dispatch_queue_t, action: DebounceAction) -> DebounceAction {
    let delayTime = Int64(delay * Double(NSEC_PER_SEC))

    var last: dispatch_time_t = 0
    return {
        last = dispatch_time(DISPATCH_TIME_NOW, 0)
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, delayTime)
        dispatch_after(dispatchTime, queue) {
            let now = dispatch_time(DISPATCH_TIME_NOW, 0)
            let when = dispatch_time(last, delayTime)
            guard now >= when else { return }
            action()
        }
    }
}