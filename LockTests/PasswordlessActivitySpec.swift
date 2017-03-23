// PasswordlessActivitySpec.swift
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
import OHHTTPStubs

@testable import Lock

class PasswordlessActivitySpec: QuickSpec {

    override func spec() {

        let authentication = Auth0.authentication(clientId: clientId, domain: domain)

        var messagePresenter: MockMessagePresenter!
        let passwordlessActivity: PasswordlessActivity = PasswordlessActivity.shared
        var passwordlessTransaction: PasswordlessAuthTransaction!
        var dispatcher: ObserverStore!
        var options: OptionBuildable!
        var identifier: String!
        var errorCode: Error?
        var credentials: Credentials?

        beforeEach {
            errorCode = nil
            credentials = nil
            dispatcher = ObserverStore()
            dispatcher.onFailure = { errorCode = $0 }
            dispatcher.onAuth = { credentials = $0 }
            identifier = email
            options = LockOptions()
            messagePresenter = MockMessagePresenter()
            passwordlessActivity.messagePresenter = messagePresenter
            passwordlessActivity.dispatcher = dispatcher
            passwordlessTransaction = PasswordlessLinkTransaction(connection: "customsms", options: options, identifier: identifier, authentication: authentication, dispatcher: dispatcher)
        }

        afterEach {
            Auth0Stubs.cleanAll()
        }

        describe("user activity validator") {

            var activity: NSUserActivity!

            beforeEach {
                activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
            }

            it("should fail validation no url") {
                expect(passwordlessActivity.continueAuth(withActivity: activity)) == false
            }

            it("should fail validation no callback in url") {
                activity.webpageURL = URL(string: "http://testdomain.auth0.com/")
                expect(passwordlessActivity.continueAuth(withActivity: activity)) == false
            }

            it("should fail validation with no code in callback") {
                activity.webpageURL = URL(string: "http://testdomain.auth0.com/" + Bundle.main.bundleIdentifier!.lowercased() + "/")
                expect(passwordlessActivity.continueAuth(withActivity: activity)) == false
            }

            it("should pass validation with numeric code") {
                activity.webpageURL = URL(string: "http://testdomain.auth0.com/" + Bundle.main.bundleIdentifier!.lowercased() + "/?code=123456")
                expect(passwordlessActivity.continueAuth(withActivity: activity)) == true
            }

            it("should fail validation with invalid code") {
                activity.webpageURL = URL(string: "http://testdomain.auth0.com/" + Bundle.main.bundleIdentifier!.lowercased() + "/?code=PASSCODE")
                expect(passwordlessActivity.continueAuth(withActivity: activity)) == false
                expect(errorCode).toEventuallyNot(beNil())
            }
        }

        describe("auth") {

            var activity: NSUserActivity!

            beforeEach {
                activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
            }

            it("should use passcode in transaction auth and yield credentials") {
                stub(condition: databaseLogin(identifier: identifier, password: "12345678", connection: "customsms")) { _ in return Auth0Stubs.authentication() }
                passwordlessActivity.store(passwordlessTransaction)
                activity.webpageURL = URL(string: "http://testdomain.auth0.com/" + Bundle.main.bundleIdentifier!.lowercased() + "/?code=12345678")
                expect(passwordlessActivity.continueAuth(withActivity: activity)) == true
                expect(credentials).toEventuallyNot(beNil())
                expect(errorCode).toEventually(beNil())
            }

            it("should use passcode in transaction auth and fail") {
                stub(condition: databaseLogin(identifier: identifier, password: "12345678", connection: "customsms")) { _ in return Auth0Stubs.failure("invalid_user_password")}
                passwordlessActivity.store(passwordlessTransaction)
                activity.webpageURL = URL(string: "http://testdomain.auth0.com/" + Bundle.main.bundleIdentifier!.lowercased() + "/?code=12345678")
                expect(passwordlessActivity.continueAuth(withActivity: activity)) == true
                expect(credentials).toEventually(beNil())
                expect(errorCode).toEventuallyNot(beNil())
            }

        }

    }
}
