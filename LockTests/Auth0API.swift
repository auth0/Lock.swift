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

private func FixturePathInBundle(_ name: String, forClassInBundle clazz: AnyClass) -> String {
    let bundle = Bundle(for: clazz)
    let url = URL(string: name)!
    return bundle.path(forResource: url.deletingPathExtension().absoluteString, ofType: url.pathExtension)!
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
        OHHTTPStubs.stubRequests(passingTest: { _ in return true }, withStubResponse: { request in
            let error = NSError(domain: "com.auth0", code: -9999999, userInfo: [NSLocalizedDescriptionKey: "\(request.url) shall not pass!"])
            return OHHTTPStubsResponse(error: error)
        }).name = "YOU SHALL NOT PASS!"
    }

    func failForRoute(_ route: Route, parameters: [String: String], message: String = "Kill it with fire!") {
        let matcher = requestMatcherForRoute(route, parameters: parameters as [String : AnyObject])
        OHHTTPStubs.stubRequests(passingTest: matcher) { request in
            let error = NSError(domain: "com.auth0", code: -9999999, userInfo: [NSLocalizedDescriptionKey: message])
            return OHHTTPStubsResponse(error: error)
        }.name = "Kill it with fire!"
    }

    func allowLoginWithUsername(_ username: String, password: String, clientId: String, database: String) {
        allowLoginWithParameters([
            "username": username,
            "password": password,
            "scope": "openid offline_access",
            "grant_type": "password",
            "client_id": clientId,
            "connection": database
            ])
    }

    func allowLoginWithParameters(_ parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.Login, parameters: parameters as [String : AnyObject])
        OHHTTPStubs.stubRequests(passingTest: matcher) { request in
            let path = FixturePathInBundle("POST-oauth-ro.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "Login with /ro"
    }

    func allowSocialLoginWithParameters(_ parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.SocialLogin, parameters: parameters as [String : AnyObject])
        OHHTTPStubs.stubRequests(passingTest: matcher) { request in
            let path = FixturePathInBundle("POST-oauth-ro.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
            }.name = "Login Social Token"
    }

    func allowTokenInfoForToken(_ token: String) {
        let matcher = requestMatcherForRoute(.TokenInfo, parameters: [
            "id_token": token as AnyObject
            ])
        OHHTTPStubs.stubRequests(passingTest: matcher) { request in
            let path = FixturePathInBundle("POST-tokeninfo.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "Token information"
    }

    func allowSignUpWithParameters(_ parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.SignUp, parameters: parameters as [String : AnyObject])
        OHHTTPStubs.stubRequests(passingTest: matcher) { request in
            let path = FixturePathInBundle("POST-dbconnections-signup.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "SignUp"
    }

    func allowChangePasswordWithParameters(_ parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.ChangePassword, parameters: parameters as [String : AnyObject])
        OHHTTPStubs.stubRequests(passingTest: matcher) { request in
            let path = FixturePathInBundle("POST-dbconnections-change-password.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "Change Password"
    }

    func allowStartPasswordlessWithParameters(_ parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.StartPasswordless, parameters: parameters)
        OHHTTPStubs.stubRequests(passingTest: matcher) { request in
            return OHHTTPStubsResponse(jsonObject: ["_id": UUID().uuidString], statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "Passwordless Start"
    }

    func allowDelegationWithParameters(_ parameters: [String: String]) {
        let matcher = requestMatcherForRoute(.Delegation, parameters: parameters as [String : AnyObject])
        OHHTTPStubs.stubRequests(passingTest: matcher) { request in
            let path = FixturePathInBundle("POST-delegation.response", forClassInBundle: Auth0API.classForCoder())
            return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
        }.name = "Delegation"
    }

    func reset() {
        OHHTTPStubs.removeAllStubs()
    }

    fileprivate func requestMatcherForRoute(_ route: Route, parameters: [String: Any]) -> ((URLRequest) -> Bool) {
        return { request in
            let requestParameters = URLProtocol.property(forKey: "parameters", in: request) as! [String: String]
            let sameParameters = parameters.reduce(true, { (matches, entry) in
                let requestValue = requestParameters[entry.0]
                return matches && requestValue != nil && requestValue! == entry.1 as! String
            })
            return request.httpMethod == route.method && request.url?.path == route.rawValue && sameParameters
        }
    }
}
