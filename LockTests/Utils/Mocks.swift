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

    var presenting: UIViewController?
    var presented: UIViewController?
    var presentable: Presentable?

    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        completion?()
    }

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        completion?()
        self.presented = viewControllerToPresent
    }

    override func present(_ presentable: Presentable?, title: String?) {
        self.presentable = presentable
        self.headerView.title = title
    }

    override var presentingViewController: UIViewController? {
        return self.presenting
    }
}


class MockAuthPresenter: AuthPresenter {

    var authView = AuthCollectionView(connections: [], mode: .compact, insets: UIEdgeInsets.zero, customStyle: [:])  { _ in }

    override func newViewToEmbed(withInsets insets: UIEdgeInsets, isLogin: Bool) -> AuthCollectionView {
        return self.authView
    }

}

class MockNavigator: Navigable {
    var route: Route?
    var resetted: Bool = false
    var presented: UIViewController? = nil
    var connections: Connections? = nil
    var unrecoverableError: Error? = nil
    var headerTitle: String? = "Auth0"
    var root: Presentable? = nil

    func navigate(_ route: Route) {
        self.route = route
    }

    func resetScroll(_ animated: Bool) {
        self.resetted = true
    }

    func scroll(toPosition: CGPoint, animated: Bool) {
    }


    func present(_ controller: UIViewController) {
        self.presented = controller
    }

    func reload(with connections: Connections) {
        self.connections = connections
    }

    func exit(withError error: Error) {
        self.unrecoverableError = error
    }

    func header(withTitle title: String, animated: Bool) {
        self.headerTitle = title
    }

    func onBack() -> () {
    }
}

func mockInput(_ type: InputField.InputType, value: String? = nil) -> MockInputField {
    let input = MockInputField()
    input.type = type
    input.text = value
    return input
}

class MockMessagePresenter: MessagePresenter {
    var message: String? = nil
    var error: LocalizableError? = nil

    func showSuccess(_ message: String) {
        self.message = message
    }

    func showError(_ error: LocalizableError) {
        self.error = error
    }

    func hideCurrent() {
        self.error = nil
        self.message = nil
    }
}

class MockInputField: InputField {
    var valid: Bool? = nil

    override func showError(_ error: String?, noDelay: Bool) {
        self.valid = false
    }

    override func showValid() {
        self.valid = true
    }
}

class MockMultifactorInteractor: MultifactorAuthenticatable {

    let dispatcher: Dispatcher = ObserverStore()
    let logger = Logger()

    var code: String? = nil

    var onLogin: () -> CredentialAuthError? = { return nil }

    func login(_ callback: @escaping (CredentialAuthError?) -> ()) {
        callback(onLogin())
    }

    func setMultifactorCode(_ code: String?) throws {
        guard code != "invalid" else { throw NSError(domain: "", code: 0, userInfo: nil) }
        self.code = code
    }
}

class MockAuthInteractor: OAuth2Authenticatable {
    func login(_ connection: String, callback: @escaping (OAuth2AuthenticatableError?) -> ()) {
    }
    func socialIdPAuth(connection: String, accessToken: String, callback: @escaping (OAuth2AuthenticatableError?) -> ()) {
    }
}

class MockDBInteractor: DatabaseAuthenticatable, DatabaseUserCreator {

    let dispatcher: Dispatcher = ObserverStore()
    let logger = Logger()

    var identifier: String? = nil
    var email: String? = nil
    var password: String? = nil
    var username: String? = nil
    var custom: [String: String] = [:]

    var validEmail: Bool = false
    var validUsername: Bool = false

    var onLogin: () -> CredentialAuthError? = { return nil }
    var onSignUp: () -> DatabaseUserCreatorError? = { return nil }

    func login(_ callback: @escaping (CredentialAuthError?) -> ()) {
        callback(onLogin())
    }

    func create(_ callback: @escaping (DatabaseUserCreatorError?, CredentialAuthError?) -> ()) {
        callback(onSignUp(), onLogin())
    }

    func update(_ attribute: UserAttribute, value: String?) throws {
        guard value != "invalid" else {
            if case .email = attribute {
                self.validEmail = false
            }
            if case .username = attribute {
                self.validUsername = false
            }
            throw NSError(domain: "", code: 0, userInfo: nil)
        }
        switch attribute {
        case .email:
            self.email = value
        case .username:
            self.username = value
        case .password:
            self.password = value
        case .emailOrUsername:
            self.email = value
            self.username = value
        case .custom(let name):
            self.custom[name] = value
        }
    }
}

class MockConnectionsLoader: RemoteConnectionLoader {

    var connections: Connections? = nil
    var error: UnrecoverableError? = nil

    func load(_ callback: @escaping (UnrecoverableError?, Connections?) -> ()) {
        callback(error, connections)
    }
}

class MockAuthentication: Authentication {

    private var authentication: Authentication

    public var clientId: String

    public var url: URL

    var logger: Auth0.Logger?

    var telemetry: Telemetry

    var webAuth: MockWebAuth!
    var webAuthResult: () -> Auth0.Result<Credentials> = { _ in return Auth0.Result.failure(error: AuthenticationError(string: "FAILED", statusCode: 500)) }

    required init(clientId: String, domain: String) {
        self.authentication = Auth0.authentication(clientId: clientId, domain: domain)
        self.url = self.authentication.url
        self.clientId = self.authentication.clientId
        self.telemetry = self.authentication.telemetry
    }

    func webAuth(withConnection connection: String) -> WebAuth {
        let mockWebAuth = MockWebAuth().connection(connection)
        self.webAuth = mockWebAuth.connection(connection)
        self.webAuth.result = self.webAuthResult
        return self.webAuth
    }

    func tokenInfo(token: String) -> Request<Profile, AuthenticationError> {
        return self.userInfo(token: token)
    }

    func resetPassword(email: String, connection: String) -> Request<Void, AuthenticationError> {
        return self.authentication.resetPassword(email: email, connection: connection)
    }

    func userInfo(token: String) -> Request<Profile, AuthenticationError> {
        return self.authentication.userInfo(token: token)
    }

    func tokenExchange(withParameters parameters: [String : Any]) -> Request<Credentials, AuthenticationError> {
        return self.authentication.tokenExchange(withParameters: parameters)
    }


    func tokenExchange(withCode code: String, codeVerifier: String, redirectURI: String) -> Request<Credentials, AuthenticationError> {
        return self.authentication.tokenExchange(withCode: code, codeVerifier: codeVerifier, redirectURI: redirectURI)
    }

    func renew(withRefreshToken refreshToken: String) -> Request<Credentials, AuthenticationError> {
        return self.renew(withRefreshToken: refreshToken)
    }

    func login(usernameOrEmail username: String, password: String, multifactorCode: String?, connection: String, scope: String, parameters: [String : Any]) -> Request<Credentials, AuthenticationError> {
        return self.authentication.login(usernameOrEmail: username, password: password, multifactorCode: multifactorCode, connection: connection, scope: scope, parameters: parameters)
    }

    func delegation(withParameters parameters: [String : Any]) -> Request<[String : Any], AuthenticationError> {
        return self.authentication.delegation(withParameters: parameters)
    }

    func loginSocial(token: String, connection: String, scope: String, parameters: [String : Any]) -> Request<Credentials, AuthenticationError> {
        return self.authentication.loginSocial(token: token, connection: connection, scope: scope, parameters: parameters)
    }
}

class MockWebAuth: WebAuth {

    var clientId: String = "CLIENT_ID"
    var url: URL = .a0_url(domain)

    var connection: String? = nil
    var parameters: [String: String] = [:]
    var scope: String? = nil
    var audience: String? = nil

    var result: () -> Auth0.Result<Credentials> = { _ in return Auth0.Result.failure(error: AuthenticationError(string: "FAILED", statusCode: 500)) }
    var telemetry: Telemetry = Telemetry()

    func connection(_ connection: String) -> Self {
        self.connection = connection
        return self
    }

    func useUniversalLink() -> Self {
        return self
    }

    func state(_ state: String) -> Self {
        return self
    }

    func connectionScope(_ connectionScope: String) -> Self {
        self.parameters["connection_scope"] = connectionScope
        return self
    }

    func parameters(_ parameters: [String : String]) -> Self {
        parameters.forEach { self.parameters[$0] = $1 }
        return self
    }

    func usingImplicitGrant() -> Self {
        return self
    }

    func scope(_ scope: String) -> Self {
        self.scope = scope
        return self
    }

    func start(_ callback: @escaping (Auth0.Result<Credentials>) -> ()) {
        callback(self.result())
    }

    func responseType(_ response: [ResponseType]) -> Self {
        return self
    }

    func nonce(_ nonce: String) -> Self {
        return self
    }

    func audience(_ audience: String) -> Self {
        self.audience = audience
        return self
    }
    
    var logger: Auth0.Logger? = nil
}

class MockOAuth2: OAuth2Authenticatable {
    var connection: String? = nil
    var onLogin: () -> OAuth2AuthenticatableError? = { _ in return nil }
    func login(_ connection: String, callback: @escaping (OAuth2AuthenticatableError?) -> ()) {
        self.connection = connection
        callback(self.onLogin())
    }
}

class MockController: UIViewController {

    var presented: UIViewController?

    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {
        self.presented = viewControllerToPresent
    }

    override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        self.presented = nil
        completion?()
    }
}

class MockNativeAuthHandler: AuthProvider {

    var transaction: MockNativeAuthTransaction!
    var authentication: Authentication!

    func login(withConnection connection: String, scope: String, parameters: [String : Any]) -> NativeAuthTransaction {
        let transaction = MockNativeAuthTransaction(connection: connection, scope: scope, parameters: parameters, authentication: self.authentication)
        self.transaction = transaction
        return transaction
    }
}

class MockNativeAuthTransaction: NativeAuthTransaction {
    var connection: String
    var scope: String
    var parameters: [String : Any]
    var authentication: Authentication

    init(connection: String, scope: String, parameters: [String: Any], authentication: Authentication) {
        self.connection = connection
        self.scope = scope
        self.parameters = parameters
        self.authentication = authentication
    }

    var delayed: NativeAuthTransaction.Callback = { _ in }

    func auth(callback: @escaping NativeAuthTransaction.Callback) {
        self.delayed = callback
    }

    func cancel() {
        self.delayed(.failure(error: WebAuthError.userCancelled))
        self.delayed = { _ in }
    }

    func resume(_ url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        self.delayed(self.onNativeAuth())
        self.delayed = { _ in }
        return true
    }

    /// Test Hooks
    var onNativeAuth: () -> Auth0.Result<NativeAuthCredentials> = {
        return .success(result: NativeAuthCredentials(token: "SocialToken", extras: [:]))
    }
}

func mockCredentials() -> Credentials {
    return Credentials(accessToken: UUID().uuidString, tokenType: "Bearer")
}

class MockPasswordlessActivity: PasswordlessUserActivity {

    var messagePresenter: MessagePresenter?
    var onActivity: (String, inout MessagePresenter?) -> () = { _ in }
    var code: String = "123456"

    func withMessagePresenter(_ messagePresenter: MessagePresenter?) -> Self {
        self.messagePresenter = messagePresenter
        return self
    }

    func onActivity(callback: @escaping (String, inout MessagePresenter?) -> ()) {
        self.onActivity = callback
    }

    func continueAuth(withActivity userActivity: NSUserActivity) -> Bool {
        self.onActivity(code, &messagePresenter)
        return true
    }
}

class MockPasswordlessInteractor: PasswordlessAuthenticatable {

    let dispatcher: Dispatcher = ObserverStore()
    let logger = Logger()

    var identifier: String? = nil
    var validIdentifier: Bool = false
    var code: String? = nil
    var validCode: Bool = false

    var onLogin: () -> CredentialAuthError? = { return nil }
    var onRequest: () -> PasswordlessAuthenticatableError? = { return nil }

    func update(_ type: InputField.InputType, value: String?) throws {
    }

    func request(_ connection: String, callback: @escaping (PasswordlessAuthenticatableError?) -> ()) {
        callback(onRequest())
    }

    func login(_ connection: String, callback: @escaping (CredentialAuthError?) -> ()) {
        callback(onLogin())
    }
}
