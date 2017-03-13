// OptionsSpec.swift
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

@testable import Lock

class OptionsSpec: QuickSpec {

    override func spec() {

        var options: LockOptions!

        beforeEach {
            options = LockOptions()
        }

        describe("defaults") {

            it("should not be closable") {
                expect(options.closable) == false
            }

            it("should have Auth0 tos as String") {
                expect(options.termsOfService) == "https://auth0.com/terms"
            }

            it("should have Auth0 tos as NSURL") {
                expect(options.termsOfServiceURL.absoluteString) == "https://auth0.com/terms"
            }

            it("should have Auth0 privacy policy as String") {
                expect(options.privacyPolicy) == "https://auth0.com/privacy"
            }

            it("should have Auth0 privacy policy as NSURL") {
                expect(options.privacyPolicyURL.absoluteString) == "https://auth0.com/privacy"
            }

            it("should have openid as scope") {
                expect(options.scope) == "openid"
            }

            it("should have empty default parameters") {
                expect(options.parameters).to(beEmpty())
            }

            it("should have all db modes allowed") {
                expect(options.allow) == [.Login, .Signup, .ResetPassword]
            }

            it("should have login as the default db screen") {
                expect(options.initialScreen) == DatabaseScreen.login
            }

            it("should accept both styles for identifier") {
                expect(options.usernameStyle) == [.Email, .Username]
            }

            it("should have no custom fields") {
                expect(options.customSignupFields).to(beEmpty())
            }

            it("should not be OIDC conformant") {
                expect(options.oidcConformant) == false
            }

            it("should have no audience") {
                expect(options.audience).to(beNil())
            }

            it("should be auto closeable") {
                expect(options.autoClose) == true
            }


            it("should be passwordless emailCode method by default") {
                expect(options.passwordlessMethod).to(equal(PasswordlessMethod.emailCode))
            }

        }

        describe("validation") {

            it("should consider the default values as valid") {
                expect(options.validate()).to(beNil())
            }

            it("should fail when allow is empty") {
                options.allow = []
                expect(options.validate()).toNot(beNil())
            }

            it("should fail when login is initial screen and not allowed") {
                options.allow = []
                options.initialScreen = .login
                expect(options.validate()).toNot(beNil())
            }

            it("should fail when signup is initial screen and not allowed") {
                options.allow = []
                options.initialScreen = .signup
                expect(options.validate()).toNot(beNil())
            }

            it("should fail when reset password is initial screen and not allowed") {
                options.allow = []
                options.initialScreen = .resetPassword
                expect(options.validate()).toNot(beNil())
            }

            it("should fail when username style is empty") {
                options.usernameStyle = []
                expect(options.validate()).toNot(beNil())
            }

            it("should fail setting audience in non OIDC mode") {
                options.oidcConformant = false
                options.audience = "https://myapi.com"
                expect(options.validate()).toNot(beNil())
            }

            it("should allow no audience in OIDC mode") {
                options.oidcConformant = true
                options.audience = nil
                expect(options.validate()).to(beNil())
            }

            it("should allow audience in OIDC mode") {
                options.oidcConformant = true
                options.audience = "https://myapi.com"
                expect(options.validate()).to(beNil())
            }

            context("passwordless") {

                it("should fail setting audience in passwordless mode") {
                    options.passwordlessMethod = .emailCode
                    options.audience = "https://myapi.com"
                    expect(options.validate(classic: false)).toNot(beNil())
                }
            }

            context("auto close") {

                it("should fail when autoclose is empty and no .Login allowed") {
                    options.autoClose = false
                    options.allow = [.Signup, .ResetPassword]
                    expect(options.validate()).toNot(beNil())
                }

                it("should fail autoclose disabled and single screen") {
                    options.autoClose = false
                    options.allow = [.ResetPassword]
                    expect(options.validate()).toNot(beNil())
                }

                it("should pass when autoclose empty, no login, but closeable set") {
                    options.closable = true
                    options.autoClose = false
                    options.allow = [.Signup, .ResetPassword]
                    expect(options.validate()).to(beNil())
                }

            }


        }

        describe("builder") {

            it("should set closable") {
                options.closable = true
                expect(options.closable) == true
            }

            it("should set OIDC Conformant") {
                options.oidcConformant = true
                expect(options.oidcConformant) == true
            }

            it("should set audience") {
                options.audience = "http://myapi.com/"
                expect(options.audience) == "http://myapi.com/"
            }

            it("should set tos") {
                options.termsOfService = "https://mysite.com"
                expect(options.termsOfServiceURL.absoluteString) == "https://mysite.com"
            }

            it("should ignore invalid tos") {
                options.termsOfService = "not a url"
                expect(options.termsOfServiceURL.absoluteString) == "https://auth0.com/terms"
            }

            it("should set privacy policy") {
                options.privacyPolicy = "https://mysite.com"
                expect(options.privacyPolicyURL.absoluteString) == "https://mysite.com"
            }

            it("should ignore invalid privacy policy") {
                options.privacyPolicy = "not a url"
                expect(options.privacyPolicyURL.absoluteString) == "https://auth0.com/privacy"
            }
        }
    }
}
