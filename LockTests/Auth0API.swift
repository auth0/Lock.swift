// Auth0API.swift
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
import OHHTTPStubs

private func FixturePathInBundle(name: String, forClassInBundle clazz: AnyClass) -> String {
    let bundle = NSBundle(forClass: clazz)
    let url = NSURL(string: name)!
    return bundle.pathForResource(url.URLByDeletingPathExtension?.absoluteString, ofType: url.pathExtension!)!
}

class Auth0API : NSObject {

    enum Route : String {
        case Login = "/oauth/ro"
        case SocialLogin = "/oauth/access_token"
        case SignUp = "/dbconnections/signup"
        case ChangePassword = "/dbconnections/change_password"
        case TokenInfo = "/tokeninfo"
        case StartPasswordless = "/passwordless/start"
        case Delegation = "/delegation"

        var method: String {
            return "POST"
        }
    }

    func failForEveryRequest() {
        OHHTTPStubs.stubRequestsPassingTest({ _ in return true }, withStubResponse: { request in
            let error = NSError(domain: "com.auth0", code: -9999999, userInfo: [NSLocalizedDescriptionKey: "\(request.URL) shall not pass!"])
            return OHHTTPStubsResponse(error: error)
        }).name = "YOU SHALL NOT PASS!"
    }

    func failForRoute(route: Route, parameters: [String: String], message: String = "Kill it with fire!") {
        let matcher = requestMatcherForRoute(route, parameters: parameters)
        OHHTTPStubs.stubRequestsPassingTest(matcher) { request in
            let error = NSError(domain: "com.auth0", code: -9999999, userInfo: [NSLocalizedDescriptionKey: message])
            return OHHTTPStubsResponse(error: error)
        }.name = "Kill it with fire!"
    }

    func allowLoginWithUsername(username: String, password: String, clientId: String, database: String) {
        allowLoginWithParameters([
            "username": username,
            "password": password,
            "scope": "openid offline_access",
            "grant_type": "password",
            "client_id": clientId,
            "connection": database
            ])
    }

    func allowLoginWithParameters(parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.Login, parameters: parameters)
        OHHTTPStubs.stubRequestsPassingTest(matcher) { request in
            let path = FixturePathInBundle("POST-oauth-ro.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "Login with /ro"
    }

    func allowSocialLoginWithParameters(parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.SocialLogin, parameters: parameters)
        OHHTTPStubs.stubRequestsPassingTest(matcher) { request in
            let path = FixturePathInBundle("POST-oauth-ro.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
            }.name = "Login Social Token"
    }

    func allowTokenInfoForToken(token: String) {
        let matcher = requestMatcherForRoute(.TokenInfo, parameters: [
            "id_token": token
            ])
        OHHTTPStubs.stubRequestsPassingTest(matcher) { request in
            let path = FixturePathInBundle("POST-tokeninfo.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "Token information"
    }

    func allowSignUpWithParameters(parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.SignUp, parameters: parameters)
        OHHTTPStubs.stubRequestsPassingTest(matcher) { request in
            let path = FixturePathInBundle("POST-dbconnections-signup.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "SignUp"
    }

    func allowChangePasswordWithParameters(parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.ChangePassword, parameters: parameters)
        OHHTTPStubs.stubRequestsPassingTest(matcher) { request in
            let path = FixturePathInBundle("POST-dbconnections-change-password.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "Change Password"
    }

    func allowStartPasswordlessWithParameters(parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.StartPasswordless, parameters: parameters)
        OHHTTPStubs.stubRequestsPassingTest(matcher) { request in
            return OHHTTPStubsResponse(JSONObject: ["_id": NSUUID().UUIDString], statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "Passwordless Start"
    }

    func allowDelegationWithParameters(parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.Delegation, parameters: parameters)
        OHHTTPStubs.stubRequestsPassingTest(matcher) { request in
            let path = FixturePathInBundle("POST-delegation.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "Delegation"
    }

    func reset() {
        OHHTTPStubs.removeAllStubs()
    }

    private func requestMatcherForRoute(route: Route, parameters: [String: AnyObject]) -> (NSURLRequest -> Bool) {
        return { request in
            let requestParameters = NSURLProtocol.propertyForKey("parameters", inRequest: request) as! [String: String]
            let sameParameters = parameters.reduce(true, combine: { (matches, entry) in
                let requestValue = requestParameters[entry.0]
                return matches && requestValue != nil && requestValue! == entry.1 as! String
            })
            return request.HTTPMethod == route.method && request.URL?.path == route.rawValue && sameParameters
        }
    }
}