// NativeAuthInteractorSpec.swift
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

class NativeAuthInteractorSpec: QuickSpec {

    override func spec() {

        var options: OptionBuildable!
        var dispatcher: ObserverStore!
        var interactor: NativeAuthInteractor!
        var authHandler: MockNativeAuthHandler!
        var dispatchError: Error?
        var credentials: Credentials?


        beforeEach {
            options = LockOptions()
            options.autoClose = false
            dispatcher = ObserverStore()
            dispatcher.onAuth = { credentials = $0 }
            dispatcher.onFailure = { dispatchError = $0 }
            interactor = NativeAuthInteractor(dispatcher: dispatcher, options: options)
            authHandler = MockNativeAuthHandler()
        }

        describe("login") {

            var error: NativeAuthenticatableError?

            beforeEach {
                error = nil
            }

            it("should not yield error on success") {
                authHandler.onLogin = {
                    authHandler.onAuth(mockCredentials())
                }
                interactor.login("facebook", nativeAuth: authHandler) { error = $0 }
                expect(error).toEventually(beNil())
            }

            it("should yield error on handler failure") {
                authHandler.onLogin = {
                    authHandler.onError(NativeAuthenticatableError.nativeIssue)
                }
                interactor.login("facebook", nativeAuth: authHandler) { error = $0 }
                expect(error).toEventually(equal(NativeAuthenticatableError.nativeIssue))
            }

            context("dispatch") {

                beforeEach {
                    credentials = nil
                    dispatchError = nil
                }

                it("should dispatch auth") {
                    let expected = mockCredentials()
                    authHandler.onLogin = {
                        authHandler.onAuth(expected)
                    }
                    interactor.login("facebook", nativeAuth: authHandler) { _ in }
                    expect(dispatchError).toEventually(beNil())
                    expect(credentials).toEventually(equal(expected))
                }

                it("should dispatch error") {
                    authHandler.onLogin = {
                        authHandler.onError(NativeAuthenticatableError.nativeIssue)
                    }
                    interactor.login("facebook", nativeAuth: authHandler) { _ in }
                    expect(dispatchError).toEventuallyNot(beNil())
                    expect(credentials).toEventually(beNil())
                }
                
            }
        }
    }
}
