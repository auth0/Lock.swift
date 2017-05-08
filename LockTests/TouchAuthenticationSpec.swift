// TouchAuthenticationSpec.swift
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

import Quick
import Nimble
import Auth0
import LocalAuthentication

@testable import Lock

class TouchAuthenticationSpec: QuickSpec {

    override func spec() {

        let authentication: Authentication = MockAuthentication(clientId: clientId, domain: domain)
        var storage: Storage!
        var options: OptionBuildable!
        var touchAuth: TouchAuthentication!
        var authContext: MockLAContext!

        beforeEach {
            options = LockOptions()
            storage = Storage()
            authContext = MockLAContext()
            touchAuth = TouchAuthentication(authentication: authentication, options: options, storage: storage, authContext: authContext)
        }

        describe("touchid availability") {

            it("should be available") {
                expect(touchAuth.available).to(beTrue())
            }

        }

        describe("remeber me storage of credentials") {

            var error: Error?

            beforeEach {
                error = nil
                authContext.error = nil
            }

            afterEach {
                storage.clearAll()
            }

            it("should silent error if no refreshToken set in credentials") {
                touchAuth.store(credentials: mockCredentials()) {
                    error = $0
                }
                expect(error).toEventually(beNil())
                let credentials = storage.unarchive(objectWithKey: touchAuth.storeKey) as? Credentials
                expect(credentials).to(beNil())
            }

            it("should silent error if no expiresIn set in credentials") {
                let mockCredentials = Credentials(accessToken: nil, tokenType: nil, idToken: nil, refreshToken: UUID().uuidString, expiresIn: nil)
                touchAuth.store(credentials: mockCredentials) {
                    error = $0
                }
                expect(error).toEventually(beNil())
                let credentials = storage.unarchive(objectWithKey: touchAuth.storeKey) as? Credentials
                expect(credentials).to(beNil())
            }

            it("should store credentials to keychain") {
                touchAuth.store(credentials: mockCredentialsAll()) {
                    error = $0
                }
                expect(error).toEventually(beNil())
                let credentials = storage.unarchive(objectWithKey: touchAuth.storeKey) as? Credentials
                expect(credentials).toEventuallyNot(beNil())
            }

            it("should return error and delete credentials keychain entry") {
                storage.setString("dummystring", forKey: touchAuth.storeKey)
                authContext.error = LAError(.userCancel)
                touchAuth.store(credentials: mockCredentialsAll()) {
                    error = $0
                }
                expect(error).toNot(beNil())
                expect(storage.hasValue(forKey: touchAuth.storeKey)).to(beFalse())
            }
        }

        describe("touch me retrieval and renewal of credentials") {

            var error: Error?
            var credentials: Credentials?

            beforeEach {
                error = nil
                credentials = nil
                authContext.error = nil
            }

            afterEach {
                storage.clearAll()
            }

            it("should silent error if no refreshToken set in credentials") {
                touchAuth.renewAuth { error = $0 ; credentials = $1 }
                expect(error).toEventually(beNil())
                expect(credentials).toEventually(beNil())
            }

            context("with stored keychain credentials") {

                beforeEach {
                    _ = storage.archive(object: mockCredentialsAll(), forKey: touchAuth.storeKey)
                }

                it("should return credentials") {
                    touchAuth.renewAuth { error = $0 ; credentials = $1 }
                    expect(error).toEventually(beNil())
                    expect(credentials).toEventuallyNot(beNil())
                }

                it("should return error and delete credentials keychain entry") {
                    authContext.error = LAError(.userCancel)
                    touchAuth.renewAuth { error = $0 ; credentials = $1 }
                    expect(error).toEventuallyNot(beNil())
                    expect(credentials).toEventually(beNil())
                    expect(storage.hasValue(forKey: touchAuth.storeKey)).to(beFalse())
                }
                
            }

        }

    }
}
