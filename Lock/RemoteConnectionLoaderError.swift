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

enum RemoteConnectionLoaderError: Error, LocalizableError {
    case connectionTimeout
    case invalidClient
    case invalidClientInfo
    case noConnections
    case requestIssue
    case responseIssue

    var localizableMessage: String {
        switch self {
        case .invalidClient:
            return "No client information found, please check your Auth0 client credentials.".i18n(key: "com.auth0.lock.critical.credentials", comment: "Invalid client credentials")
        case .invalidClientInfo:
            return "Unable to retrieve client information, please try again later.".i18n(key: "com.auth0.lock.critical.clientinfo", comment: "Invalid client info")
        case .noConnections:
            return "No connections available for this client, please check your Auth0 client setup.".i18n(key: "com.auth0.lock.critical.noconnections", comment: "No connections available.")
        default:
            return "Could not connect to the server, please try again later.".i18n(key: "com.auth0.lock.critical.timeout", comment: "Connection timeout")
        }
    }

    var userVisible: Bool {
        return true
    }
}
