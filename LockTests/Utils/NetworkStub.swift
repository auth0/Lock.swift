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
import Auth0
import OHHTTPStubs
#if SWIFT_PACKAGE
import OHHTTPStubsSwift
#endif

// MARK: - Request Matchers

func += <K, V> (left: inout [K:V], right: [K:V]) {
    for (k, v) in right {
        left[k] = v
    }
}

func realmLogin(identifier: String, password: String, realm: String) -> HTTPStubsTestBlock {
    var parameters = ["username": identifier, "password": password]
    parameters["realm"] = realm
    return isHost(domain) && isMethodPOST() && isPath("/oauth/token") && hasAtLeast(parameters)
}

func databaseLogin(identifier: String, password: String, code: String? = nil, connection: String) -> HTTPStubsTestBlock {
    var parameters = ["username": identifier, "password": password]
    if let code = code {
        parameters["mfa_code"] = code
    }
    parameters["connection"] = connection
    return isHost(domain) && isMethodPOST() && isPath("/oauth/ro") && hasAtLeast(parameters)
}

func passwordlessLogin(username: String, otp: String, realm: String) -> HTTPStubsTestBlock {
    let parameters = ["username": username, "otp": otp, "realm": realm, "grant_type": "http://auth0.com/oauth/grant-type/passwordless/otp"]
    return isHost(domain) && isMethodPOST() && isPath("/oauth/token") && hasAtLeast(parameters)
}

func otpLogin(otp: String, mfaToken: String) -> HTTPStubsTestBlock {
    let parameters = ["otp": otp, "mfa_token": mfaToken]
    return isHost(domain) && isMethodPOST() && isPath("/oauth/token") && hasAtLeast(parameters)
}

func oobLogin(oob: String, mfaToken: String, bindingCode: String? = nil) -> HTTPStubsTestBlock {
    var parameters = ["oob_code": oob, "mfa_token": mfaToken]
    if let bindingCode = bindingCode {
        parameters["binding_code"] = bindingCode
    }
    return isHost(domain) && isMethodPOST() && isPath("/oauth/token") && hasAtLeast(parameters)
}

func databaseSignUp(email: String, username: String? = nil, password: String, connection: String) -> HTTPStubsTestBlock {
    var parameters = ["email": email, "password": password, "connection": connection]
    if let username = username { parameters["username"] = username }
    return isHost(domain) && isMethodPOST() && isPath("/dbconnections/signup") && hasAtLeast(parameters)
}

func databaseForgotPassword(email: String, connection: String) -> HTTPStubsTestBlock {
    return isHost(domain) && isMethodPOST() && isPath("/dbconnections/change_password") && hasAtLeast(["email": email, "connection": connection])
}

func passwordlessStart(email: String, connection: String) -> HTTPStubsTestBlock {
    return isHost(domain) && isMethodPOST() && isPath("/passwordless/start") && hasAtLeast(["email": email, "connection": connection])
}

func passwordlessStart(phone: String, connection: String) -> HTTPStubsTestBlock {
    return isHost(domain) && isMethodPOST() && isPath("/passwordless/start") && hasAtLeast(["phone_number": phone, "connection": connection])
}

func mfaChallengeStart(mfaToken: String) -> HTTPStubsTestBlock {
    return isHost(domain) && isMethodPOST() && isPath("/mfa/challenge") && hasAtLeast(["mfa_token": mfaToken])
}

// MARK: - Internal Matchers

extension URLRequest {
    var a0_payload: [String: Any]? {
        guard
            let data = (self as NSURLRequest).ohhttpStubs_HTTPBody(),
            let payload = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            else { return nil }
        return payload
    }
}

func hasEntry(key: String, value: String) -> HTTPStubsTestBlock {
    return { request in
        guard let payload = request.a0_payload else { return false }
        return payload[key] as? String == value
    }
}

func hasAtLeast(_ parameters: [String: String]) -> HTTPStubsTestBlock {
    return { request in
        guard let payload = request.a0_payload else { return false }
        let entries = parameters.filter { (key, _) in payload.contains { (name, _) in  key == name } }
        return entries.count == parameters.count && entries.reduce(true, { (initial, entry) -> Bool in
            return initial && payload[entry.0] as? String == entry.1
        })
    }
}

func isResourceOwner(_ domain: String) -> HTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/oauth/ro")
}

func isToken(_ domain: String) -> HTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/oauth/token")
}

func isSignUp(_ domain: String) -> HTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/dbconnections/signup")
}

func isResetPassword(_ domain: String) -> HTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/dbconnections/change_password")
}

func isTokenInfo(_ domain: String) -> HTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/tokeninfo")
}

func isUserInfo(_ domain: String) -> HTTPStubsTestBlock {
    return isMethodGET() && isHost(domain) && isPath("/userinfo")
}

func isOAuthAccessToken(_ domain: String) -> HTTPStubsTestBlock {
    return isMethodPOST() && isHost(domain) && isPath("/oauth/access_token")
}

func isCDN(forClientId clientId: String) -> HTTPStubsTestBlock {
    return isMethodGET() && isHost("overmind.auth0.com") && isPath("/client/\(clientId).js")
}

// MARK: - Response Stubs

struct Auth0Stubs {
    static func cleanAll() { HTTPStubs.removeAllStubs() }

    static func failUnknown() {
        stub(condition: { _ in return true }) { _ in
            return HTTPStubsResponse.init(error: NSError(domain: "com.auth0.lock", code: -99999, userInfo: nil))
            }.name = "YOU SHALL NOT PASS!"
    }

    static func failure(_ code: String = "random_error", description: String = "FAILURE", name: String? = nil, jsonExtra: [String: String] = [:]) -> HTTPStubsResponse {
        var json = ["error": code, "error_description": description]
        json["name"] = name
        json += jsonExtra
        return HTTPStubsResponse(jsonObject: json, statusCode: 400, headers: ["Content-Type": "application/json"])
    }

    static func createdUser(_ email: String) -> HTTPStubsResponse {
        let json = [
            "email": email,
            ]
        return HTTPStubsResponse(jsonObject: json, statusCode: 200, headers: ["Content-Type": "application/json"])
    }

    static func forgotEmailSent() -> HTTPStubsResponse {
        return HTTPStubsResponse(data: "Sent".data(using: String.Encoding.utf8)!, statusCode: 200, headers: ["Content-Type": "application/json"])
    }

    static func authentication() -> HTTPStubsResponse {
        let json = [
            "access_token": "token",
            "token_type": "bearer",
            ]
        return HTTPStubsResponse(jsonObject: json, statusCode: 200, headers: ["Content-Type": "application/json"])
    }

    static func passwordlessSent(_ email: String) -> HTTPStubsResponse {
        let json = [
            "email": email,
            ]
        return HTTPStubsResponse(jsonObject: json, statusCode: 200, headers: ["Content-Type": "application/json"])
    }

    static func strategiesFromCDN(_ strategies: [[String: Any]]) -> HTTPStubsResponse {
        let json = [
            "strategies": strategies
        ]
        let data = try! JSONSerialization.data(withJSONObject: json, options: [])
        let string = String(data: data, encoding: String.Encoding.utf8)!
        let jsonp = "Auth0.setClient(\(string));"
        return HTTPStubsResponse(data: jsonp.data(using: String.Encoding.utf8)!, statusCode: 200, headers: ["Content-Type": "application/x-javascript"])
    }

    static func multifactorChallenge(challengeType: String, oobCode: String? = nil, bindingMethod: String? = nil) -> HTTPStubsResponse {
         return HTTPStubsResponse(jsonObject: ["challenge_type": challengeType, "oob_code": oobCode, "binding_method": bindingMethod], statusCode: 200, headers: nil)
     }
}
