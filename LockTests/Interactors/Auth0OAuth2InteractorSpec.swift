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
import OHHTTPStubs

import Auth0
@testable import Lock

private let DomainURL = URL(fileURLWithPath: domain)
private let Timeout = 2.0
private let AccessToken = UUID().uuidString.replacingOccurrences(of: "-", with: "")
private let IdToken = UUID().uuidString.replacingOccurrences(of: "-", with: "")
private let FacebookToken = UUID().uuidString.replacingOccurrences(of: "-", with: "")

class Auth0OAuth2InteractorSpec: QuickSpec {

    override func spec() {

        let authentication = Auth0.authentication(clientId: clientId, domain: domain)

        var webAuth: MockWebAuth!
        var options: LockOptions!
        var credentials: Credentials?
        var nativeHandlers: [NativeHandler] = []
        var authHandler: MockNativeAuthHandler!
        var interactor: OAuth2Authenticatable!
        var dispatcher: ObserverStore!

        beforeEach {
            credentials = nil
            webAuth = MockWebAuth()
            options = LockOptions()
            authHandler = MockNativeAuthHandler()
            authHandler.authentication = authentication
            dispatcher = ObserverStore()
            dispatcher.onAuth = { credentials = $0 }
            interactor = Auth0OAuth2Interactor(webAuth: webAuth, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
        }

        afterEach {
            Auth0Stubs.cleanAll()
        }

        describe("web auth login") {

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

            it("should not set audience if nil") {
                options.audience = nil
                interactor.login("facebook", callback: { _ in })
                expect(webAuth.audience).to(beNil())
            }

            it("should set audience") {
                options.audience = "https://myapi.com/v1"
                interactor = Auth0OAuth2Interactor(webAuth: webAuth, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
                interactor.login("facebook", callback: { _ in })
                expect(webAuth.audience) == "https://myapi.com/v1"
            }

            it("should set parameters") {
                let state = UUID().uuidString
                options.parameters = ["state": state as Any]
                interactor = Auth0OAuth2Interactor(webAuth: webAuth, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
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

        describe("native auth login") {

            beforeEach {
                nativeHandlers.removeAll()
                nativeHandlers.append(NativeHandler(name: ["facebook"], handler: authHandler))
                interactor = Auth0OAuth2Interactor(webAuth: webAuth, dispatcher: dispatcher, options: options, nativeHandlers: nativeHandlers)
            }

            afterEach {
                _ = Auth0.resumeAuth(DomainURL, options: [:])
            }

            it("should yield no error on success") {
                stub(condition: isOAuthAccessToken(domain) && hasAtLeast(["access_token": "SocialToken", "connection": "facebook"])) { _ in return Auth0Stubs.authentication() }.name = "Social Auth"
                waitUntil(timeout: Timeout) { done in
                    interactor.login("facebook") { error in
                        expect(error).to(beNil())
                        done()
                    }
                    _ = authHandler.transaction.resume(DomainURL, options: [:])
                }
            }

            it("should yield error on failure") {
                stub(condition: isOAuthAccessToken(domain) && hasAtLeast(["access_token": "SocialToken", "connection": "facebook"])) { _ in return Auth0Stubs.failure() }.name = "Social Auth Fail"
                waitUntil(timeout: Timeout) { done in
                    interactor.login("facebook") { error in
                        expect(error).toNot(beNil())
                        done()
                    }
                    _ = authHandler.transaction.resume(DomainURL, options: [:])
                }
            }
            
        }
    }
}

