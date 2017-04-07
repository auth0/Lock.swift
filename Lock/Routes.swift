// RouteHistory.swift
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

struct Routes {

    var current: Route {
        return self.history.first ?? .root
    }

    private(set) var history: [Route] = []

    mutating func back() -> Route {
        self.history.removeLast(1)
        return self.current
    }

    mutating func go(_ route: Route) {
        self.history.append(route)
    }

    mutating func reset() {
        self.history = []
    }
}

enum Route: Equatable {
    case root
    case forgotPassword
    case multifactor
    case enterpriseActiveAuth(connection: EnterpriseConnection, domain: String)
    case unrecoverableError(error: UnrecoverableError)
    case passwordless(screen: PasswordlessScreen, connection: PasswordlessConnection)

    func title(withStyle style: Style) -> String? {
        switch self {
        case .forgotPassword:
            return "Reset Password".i18n(key: "com.auth0.lock.forgot.title", comment: "Forgot Password title")
        case .multifactor:
            return "Two Step Verification".i18n(key: "com.auth0.lock.multifactor.title", comment: "Multifactor title")
        case .root, .unrecoverableError, .enterpriseActiveAuth, .passwordless:
            return style.hideTitle ? nil : style.title
        }
    }
}

func == (lhs: Route, rhs: Route) -> Bool {
    switch((lhs, rhs)) {
    case (.root, .root), (.forgotPassword, .forgotPassword), (.multifactor, .multifactor):
        return true
    case (.enterpriseActiveAuth(let lhsConnection, let lhsDomain), .enterpriseActiveAuth(let rhsConnection, let rhsDomain)):
        return lhsConnection.name == rhsConnection.name && lhsDomain == rhsDomain
    case (.unrecoverableError(let lhsError), .unrecoverableError(let rhsError)):
        return lhsError == rhsError
    case (.passwordless(let lhsScreen, let lhsConnection), .passwordless(let rhsScreen, let rhsConnection)):
        return lhsScreen == rhsScreen && lhsConnection.name == rhsConnection.name
    default:
        return false
    }
}
