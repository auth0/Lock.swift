// Mocks.swift
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

@testable import Lock

class MockNavigator: Navigable {
    var route: Route?

    func navigate(route: Route) {
        self.route = route
    }
}

func mockInput(type: InputField.InputType, value: String? = nil) -> MockInputField {
    let input = MockInputField()
    input.type = type
    input.text = value
    return input
}

class MockMessagePresenter: MessagePresenter {
    var success: Bool? = nil
    var message: String? = nil
    var alert: UIAlertController? = nil

    func showSuccess(message: String) {
        self.success = true
        self.message = message
    }

    func showError(message: String) {
        self.success = false
        self.message = message
    }

    func hideCurrent() {
        self.message = nil
        self.success = nil
    }

    func present(alert: UIAlertController) {
        self.alert = alert
    }
}

class MockInputField: InputField {
    var valid: Bool? = nil

    override func showError(error: String?, noDelay: Bool) {
        self.valid = false
    }

    override func showValid() {
        self.valid = true
    }
}

class MockMultifactorInteractor: MultifactorAuthenticatable {
    var code: String? = nil

    var onLogin: () -> DatabaseAuthenticatableError? = { return nil }

    func login(callback: (DatabaseAuthenticatableError?) -> ()) {
        callback(onLogin())
    }

    func setMultifactorCode(code: String?) throws {
        guard code != "invalid" else { throw NSError(domain: "", code: 0, userInfo: nil) }
        self.code = code
    }
}

class MockDBInteractor: DatabaseAuthenticatable {

    var identifier: String? = nil
    var email: String? = nil
    var password: String? = nil
    var username: String? = nil

    var validEmail: Bool = false
    var validUsername: Bool = false

    var onLogin: () -> DatabaseAuthenticatableError? = { return nil }
    var onSignUp: () -> DatabaseAuthenticatableError? = { return nil }

    func login(callback: (DatabaseAuthenticatableError?) -> ()) {
        callback(onLogin())
    }

    func create(callback: (DatabaseAuthenticatableError?) -> ()) {
        callback(onSignUp())
    }

    func update(attribute: CredentialAttribute, value: String?) throws {
        guard value != "invalid" else {
            if case .Email = attribute {
                self.validEmail = false
            }
            if case .Username = attribute {
                self.validUsername = false
            }
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        switch attribute {
        case .Email:
            self.email = value
        case .Username:
            self.username = value
        case .Password:
            self.password = value
        case .EmailOrUsername:
            self.email = value
            self.username = value
        }
    }
}