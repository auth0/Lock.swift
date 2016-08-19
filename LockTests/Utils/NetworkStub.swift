// NetworkStub.swift
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
import OHHTTPStubs

// MARK:- Request Matchers

func databaseLogin(identifier identifier: String, password: String, code: String? = nil, connection: String) -> OHHTTPStubsTestBlock {
    var parameters = ["username": identifier, "password": password, "connection": connection]
    if let code = code {
        parameters["mfa_code"] = code
    }
    return isHost("samples.auth0.com") && isMethodPOST() && isPath("/oauth/ro") && hasAtLeast(parameters)
}

func databaseSignUp(email email: String, username: String? = nil, password: String, connection: String) -> OHHTTPStubsTestBlock {
    var parameters = ["email": email, "password": password, "connection": connection]
    if let username = username { parameters["username"] = username }
    return isHost("samples.auth0.com") && isMethodPOST() && isPath("/dbconnections/signup") && hasAtLeast(parameters)
}

func databaseForgotPassword(email email: String, connection: String) -> OHHTTPStubsTestBlock {
    return isHost("samples.auth0.com") && isMethodPOST() && isPath("/dbconnections/change_password") && hasAtLeast(["email": email, "connection": connection])
}

// MARK:- Internal Matchers

extension NSURLRequest {
    var a0_payload: [String: AnyObject]? {
        guard
            let data = self.OHHTTPStubs_HTTPBody(),
            let payload = try? NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
            else { return nil }
        return payload
    }
}

func hasEntry(key key: String, value: String) -> OHHTTPStubsTestBlock {
    return { request in
        guard let payload = request.a0_payload else { return false }
        return payload[key] as? String == value
    }
}

func hasAtLeast(parameters: [String: String]) -> OHHTTPStubsTestBlock {
    return { request in
        guard let payload = request.a0_payload else { return false }
        let entries = parameters.filter { (key, _) in payload.contains { (name, _) in  key == name } }
        return entries.count == parameters.count && entries.reduce(true, combine: { (initial, entry) -> Bool in
            return initial && payload[entry.0] as? String == entry.1
        })
    }
}

func isResourceOwner(domain: String) -> OHHTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/oauth/ro")
}

func isToken(domain: String) -> OHHTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/oauth/token")
}

func isSignUp(domain: String) -> OHHTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/dbconnections/signup")
}

func isResetPassword(domain: String) -> OHHTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/dbconnections/change_password")
}

func isPasswordless(domain: String) -> OHHTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/passwordless/start")
}

func isTokenInfo(domain: String) -> OHHTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/tokeninfo")
}

func isUserInfo(domain: String) -> OHHTTPStubsTestBlock {
    return isMethodGET() && isHost(domain) && isPath("/userinfo")
}

func isOAuthAccessToken(domain: String) -> OHHTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/oauth/access_token")
}

// MARK:- Response Stubs

struct Auth0Stubs {
    static func cleanAll() { OHHTTPStubs.removeAllStubs() }

    static func failUnknown() {
        stub({ _ in return true }) { _ in
            return OHHTTPStubsResponse.init(error: NSError(domain: "com.auth0.lock", code: -99999, userInfo: nil))
            }.name = "YOU SHALL NOT PASS!"
    }

    static func failure(code: String = "random_error", description: String = "FAILURE", name: String? = nil) -> OHHTTPStubsResponse {
        var json = ["error": code, "error_description": description]
        json["name"] = name
        return OHHTTPStubsResponse(JSONObject: json, statusCode: 400, headers: ["Content-Type": "application/json"])
    }

    static func createdUser(email: String) -> OHHTTPStubsResponse {
        let json = [
            "email": email,
            ]
        return OHHTTPStubsResponse(JSONObject: json, statusCode: 200, headers: ["Content-Type": "application/json"])
    }

    static func forgotEmailSent() -> OHHTTPStubsResponse {
        return OHHTTPStubsResponse(data: "Sent".dataUsingEncoding(NSUTF8StringEncoding)!, statusCode: 200, headers: ["Content-Type": "application/json"])
    }

    static func authentication() -> OHHTTPStubsResponse {
        let json = [
            "access_token": "token",
            "token_type": "bearer",
            ]
        return OHHTTPStubsResponse(JSONObject: json, statusCode: 200, headers: ["Content-Type": "application/json"])
    }
}