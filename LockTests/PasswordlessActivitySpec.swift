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

@testable import Lock

class PasswordlessActivitySpec: QuickSpec {

    override func spec() {

        var messagePresenter: MessagePresenter?
        var mockMessagePresenter: MockMessagePresenter!
        let passwordlessActivity: PasswordlessActivity = PasswordlessActivity.shared
        var newCode: String?

        beforeEach {
            newCode = nil
            mockMessagePresenter = MockMessagePresenter()
            messagePresenter = MockMessagePresenter()
        }

        describe("setters") {

            it("should set message presenter") {
                let passwordless = passwordlessActivity.withMessagePresenter(mockMessagePresenter)
                expect(passwordless).toNot(beNil())
                expect(passwordless.messagePresenter).toNot(beNil())
            }


            it("should set activity callback") {
                passwordlessActivity.onActivity() { code, messagePresenter in
                    newCode = code
                }
                passwordlessActivity.onActivity("1234", &messagePresenter)
                expect(newCode) == "1234"
            }
        }

        describe("user activity validator") {

            var activity: NSUserActivity!

            beforeEach {
                activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)
                passwordlessActivity.onActivity() { code, messagePresenter in
                    newCode = code
                }
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

            it("should pass validation with code") {
                activity.webpageURL = URL(string: "http://testdomain.auth0.com/" + Bundle.main.bundleIdentifier!.lowercased() + "/?code=PASSCODE")
                expect(passwordlessActivity.continueAuth(withActivity: activity)) == true
            }

            it("should use code from url in activity") {
                activity.webpageURL = URL(string: "http://testdomain.auth0.com/" + Bundle.main.bundleIdentifier!.lowercased() + "/?code=OTPASSCODE")
                expect(passwordlessActivity.continueAuth(withActivity: activity)) == true
                expect(newCode) == "OTPASSCODE"
            }
        }
        
    }
}
