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
import Auth0
@testable import Lock

class MockLockController: LockViewController {

    var presented: UIViewController?
    var presentable: Presentable?

    override func dismissViewControllerAnimated(flag: Bool, completion: (() -> Void)?) {
        completion?()
    }

    override func presentViewController(viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        completion?()
        self.presented = viewControllerToPresent
    }

    override func present(presentable: Presentable?) {
        self.presentable = presentable
    }
}

class MockAuthPresenter: AuthPresenter {

    var authView = AuthCollectionView(connections: [], mode: .Compact, insets: UIEdgeInsetsZero)  { _ in }

    override func newViewToEmbed(withInsets insets: UIEdgeInsets, isLogin: Bool) -> AuthCollectionView {
        return self.authView
    }

}

class MockNavigator: Navigable {
    var route: Route?
    var resetted: Bool = false
    var presented: UIViewController? = nil


    func navigate(route: Route) {
        self.route = route
    }

    func resetScroll(animated: Bool) {
        self.resetted = true
    }

    func present(controller: UIViewController) {
        self.presented = controller
    }
}

func mockInput(type: InputField.InputType, value: String? = nil) -> MockInputField {
    let input = MockInputField()
    input.type = type
    input.text = value
    return input
}

class MockMessagePresenter: MessagePresenter {
    var message: String? = nil
    var error: LocalizableError? = nil

    func showSuccess(message: String) {
        self.message = message
    }

    func showError(error: LocalizableError) {
        self.error = error
    }

    func hideCurrent() {
        self.error = nil
        self.message = nil
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

class MockAuthInteractor: OAuth2Authenticatable {
    func login(connection: String, callback: (OAuth2AuthenticatableError?) -> ()) {
    }
}

class MockDBInteractor: DatabaseAuthenticatable, DatabaseUserCreator {

    var identifier: String? = nil
    var email: String? = nil
    var password: String? = nil
    var username: String? = nil

    var validEmail: Bool = false
    var validUsername: Bool = false

    var onLogin: () -> DatabaseAuthenticatableError? = { return nil }
    var onSignUp: () -> DatabaseUserCreatorError? = { return nil }

    func login(callback: (DatabaseAuthenticatableError?) -> ()) {
        callback(onLogin())
    }

    func create(callback: (DatabaseUserCreatorError?, DatabaseAuthenticatableError?) -> ()) {
        callback(onSignUp(), onLogin())
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

class MockWebAuth: WebAuth {

    var clientId: String = "CLIENT_ID"
    var url: NSURL = .a0_url(domain)

    var connection: String? = nil
    var scope: String? = nil
    var result: () -> Auth0.Result<Credentials> = { _ in return Auth0.Result.Failure(error: AuthenticationError(string: "FAILED", statusCode: 500)) }
    var telemetry: Telemetry = Telemetry()

    func connection(connection: String) -> Self {
        self.connection = connection
        return self
    }

    func useUniversalLink() -> Self {
        return self
    }

    func state(state: String) -> Self {
        return self
    }

    func parameters(parameters: [String : String]) -> Self {
        return self
    }

    func usingImplicitGrant() -> Self {
        return self
    }

    func scope(scope: String) -> Self {
        self.scope = scope
        return self
    }

    func start(callback: Auth0.Result<Credentials> -> ()) {
        callback(self.result())
    }
}

class MockOAuth2: OAuth2Authenticatable {
    var connection: String? = nil
    var onLogin: () -> OAuth2AuthenticatableError? = { _ in return nil }
    func login(connection: String, callback: (OAuth2AuthenticatableError?) -> ()) {
        self.connection = connection
        callback(self.onLogin())
    }
}