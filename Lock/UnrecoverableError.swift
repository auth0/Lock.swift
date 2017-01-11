// ConnectionLoadingError.swift
//
// Copyright (c) 2017 Auth0 (http://auth0.com)
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

enum UnrecoverableError: Equatable, Error, LocalizableError {
    case connectionTimeout
    case invalidClientOrDomain
    case clientWithNoConnections
    case requestIssue
    case missingDatabaseConnection
    case invalidOptions(cause: String)

    var localizableMessage: String {
        switch self {
        case .invalidClientOrDomain:
            return "No client information found, please check your Auth0 client credentials.".i18n(key: "com.auth0.lock.error.invalidclient", comment: "Invalid client")
        case .clientWithNoConnections:
            return "No connections available for this client, please check your Auth0 client setup.".i18n(key: "com.auth0.lock.error.noconnections", comment: "No client connections")
        case .connectionTimeout, .requestIssue:
            return "There was a problem with your request, please try again later.".i18n(key: "com.auth0.lock.error.requestfailed", comment: "Generic request failure")
        case .missingDatabaseConnection:
            return "No database connection was found, please check your Auth0 client setup".i18n(key: "com.auth0.lock.error.missingdatabase", comment: "No database connection")
        case .invalidOptions(let cause):
            return "Option configuration issue: \(cause)".i18n(key: "com.auth0.lock.error.options", comment: "Option configuration issue.")
        }
    }

    var userVisible: Bool {
        switch self {
        case .missingDatabaseConnection, .invalidOptions:
            return false
        default:
            return true
        }
    }
}

func == (lhs: UnrecoverableError, rhs: UnrecoverableError) -> Bool {
    switch((lhs, rhs)) {
    case (.connectionTimeout, .connectionTimeout), (.invalidClientOrDomain, .invalidClientOrDomain), (.clientWithNoConnections, .clientWithNoConnections),
         (.requestIssue, .requestIssue), (.missingDatabaseConnection, .missingDatabaseConnection):
        return true
    case (.invalidOptions(let lhsCause), .invalidOptions(let rhsCause)):
        return lhsCause == rhsCause
    default:
        return false
    }
}
