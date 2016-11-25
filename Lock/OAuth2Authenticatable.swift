// OAuth2Authenticatable.swift
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

protocol OAuth2Authenticatable {
    func login(_ connection: String, callback: @escaping (OAuth2AuthenticatableError?) -> ())
}

enum OAuth2AuthenticatableError: Error, LocalizableError {
    case noConnectionAvailable
    case couldNotAuthenticate
    case cancelled

    var localizableMessage: String {
        switch self {
        case .noConnectionAvailable:
            return "We're sorry, we could not find a valid connection for this user.".i18n(key: "com.auth0.lock.error.authentication.noconnection", comment: "No valid connection")
        case .couldNotAuthenticate:
            return "We're sorry, something went wrong when attempting to log in.".i18n(key: "com.auth0.lock.error.authentication.fallback", comment: "Generic login error")
        default:
            return "Something went wrong.\nPlease contact technical support.".i18n(key: "com.auth0.lock.error.fallback", comment: "Generic error")
        }
    }

    var userVisible: Bool {
        switch self {
        case .couldNotAuthenticate:
            return true
        default:
            return false
        }
    }
}
