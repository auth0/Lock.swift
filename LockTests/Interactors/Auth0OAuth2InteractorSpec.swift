// Auth0OAuth2InteractorSpec.swift
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

import Quick
import Nimble

import Auth0
@testable import Lock

class Auth0OAuth2InteractorSpec: QuickSpec {

    override func spec() {

        var interactor: Auth0OAuth2Interactor!
        var webAuth: MockWebAuth!
        var credentials: Credentials?

        beforeEach {
            credentials = nil
            webAuth = MockWebAuth()
            interactor = Auth0OAuth2Interactor(webAuth: webAuth, onCredentials: {credentials = $0}, options: LockOptions())
        }

        describe("login") {

            var error: OAuth2AuthenticatableError?

            beforeEach {
                error = nil
            }

            it("should set connection") {
                interactor.login("facebook", callback: { _ in })
                expect(webAuth.connection) == "facebook"
            }

            it("should set scope") {
                interactor.login("facebook", callback: { _ in })
                expect(webAuth.scope) == "openid"
            }

            it("should set parameters") {
                let state = UUID().uuidString
                var options = LockOptions()
                options.parameters = ["state": state as AnyObject]
                interactor = Auth0OAuth2Interactor(webAuth: webAuth, onCredentials: {credentials = $0}, options: options)
                interactor.login("facebook", callback: { _ in })
                expect(webAuth.params["state"]) == state
            }

            it("should not yield error on success") {
                webAuth.result = { return .success(result: mockCredentials()) }
                interactor.login("facebook") { error = $0 }
                expect(error).toEventually(beNil())
            }

            it("should call credentials callback") {
                let expected = mockCredentials()
                webAuth.result = { return .success(result: expected) }
                interactor.login("facebook") { error = $0 }
                expect(credentials).toEventually(equal(expected))
            }

            it("should handle cancel error") {
                webAuth.result = { return .failure(error: WebAuthError.userCancelled) }
                interactor.login("facebook") { error = $0 }
                expect(error).toEventually(equal(OAuth2AuthenticatableError.cancelled))
            }

            it("should handle generic error") {
                webAuth.result = { return .failure(error: WebAuthError.noBundleIdentifierFound) }
                interactor.login("facebook") { error = $0 }
                expect(error).toEventually(equal(OAuth2AuthenticatableError.couldNotAuthenticate))
            }

        }
    }
}

func mockCredentials() -> Credentials {
    return Credentials(accessToken: UUID().uuidString, tokenType: "Bearer")
}
