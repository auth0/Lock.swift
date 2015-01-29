// A0HttpKeeper.swift
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

import Foundation

class A0HttpKeeper: NSObject {

    func returnSuccessfulLoginWithFilter(filter: (NSURLRequest!) -> Bool) {
        OHHTTPStubs.stubRequestsPassingTest(filter) { (request) -> OHHTTPStubsResponse! in
            return OHHTTPStubsResponse(named: "POST-oauth-ro", inBundle: nil)
        }.name = "OAuth RO Endpoint Success"
    }

    func returnProfileWithFilter(filter: (NSURLRequest!) -> Bool) {
        OHHTTPStubs.stubRequestsPassingTest(filter) { (request) -> OHHTTPStubsResponse! in
            return OHHTTPStubsResponse(named: "POST-tokeninfo", inBundle: nil)
        }.name = "JWT token info Success"
    }

    func failWithFilter(filter: (NSURLRequest!) -> Bool, message: String) {
        OHHTTPStubs.stubRequestsPassingTest(filter, withStubResponse: { (request) -> OHHTTPStubsResponse! in
            let error = NSError(domain: "com.auth0", code: -9999999, userInfo: [NSLocalizedDescriptionKey: message])
            return OHHTTPStubsResponse(error: error)
        })
    }

    func failForAllRequests() {
        OHHTTPStubs.stubRequestsPassingTest({ (request) -> Bool in
            return true;
        }, withStubResponse: { (request) -> OHHTTPStubsResponse! in
            let error = NSError(domain: "com.auth0", code: -9999999, userInfo: [NSLocalizedDescriptionKey: "\(request.URL) You shall not pass!"])
            return OHHTTPStubsResponse(error: error)
        }).name = "YOU SHALL NOT PASS!"
    }

    func returnSignUpWithFilter(filter: (NSURLRequest!) -> Bool) {
        OHHTTPStubs.stubRequestsPassingTest(filter, withStubResponse: { (request) -> OHHTTPStubsResponse! in
            return OHHTTPStubsResponse(named: "POST-dbconnections-signup", inBundle: nil)
        }).name = "DB SignUp"
    }

    func returnChangePasswordWithFilter(filter: (NSURLRequest!) -> Bool) {
        OHHTTPStubs.stubRequestsPassingTest(filter, withStubResponse: { (request) -> OHHTTPStubsResponse! in
            return OHHTTPStubsResponse(named: "POST-dbconnections-change-password", inBundle: nil)
        }).name = "DB Change Password"
    }
}
