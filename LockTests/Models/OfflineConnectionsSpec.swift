// OfflineConnectionsSpec.swift
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

class OfflineConnectionsSpec: QuickSpec {

    override func spec() {

        it("should report if there are no conenctions") {
            let connections = OfflineConnections()
            expect(connections.isEmpty) == true
        }

        it("should add a database connection") {
            var connections = OfflineConnections()
            let usernameValidator = UsernameValidator()
            let passwordValidator = PasswordPolicyValidator(policy: .none)
            connections.database(name: connection, requiresUsername: false, usernameValidator: usernameValidator, passwordValidator: passwordValidator)
            expect(connections.isEmpty) == false
            expect(connections.database?.name) == connection
            expect(connections.database?.requiresUsername) == false
        }

        it("should add a social connection") {
            var connections = OfflineConnections()
            connections.social(name: connection, style: .Facebook)
            expect(connections.isEmpty) == false
            expect(connections.oauth2.first?.name) == connection
            expect(connections.oauth2.first?.style) == .Facebook
        }

        it("should add a oauth2 connection") {
            var connections = OfflineConnections()
            let style = AuthStyle(name: "Steam")
            connections.oauth2(name: connection, style: style)
            expect(connections.isEmpty) == false
            expect(connections.oauth2.first?.name) == connection
            expect(connections.oauth2.first?.style) == style
        }

        it("should add a passwordless connection") {
            var connections = OfflineConnections()
            connections.email(name: "custom-email")
            expect(connections.isEmpty) == false
            expect(connections.passwordless.first?.name) == "custom-email"
        }

        describe("select") {

            it("should do nothing with empty list") {
                var connections = OfflineConnections()
                connections.database(name: connection, requiresUsername: false)
                connections.social(name: "facebook", style: .Facebook)
                let filtered = connections.select(byNames: [])
                expect(filtered.database).toNot(beNil())
                expect(filtered.oauth2).toNot(beEmpty())
            }

            it("should select by name a social connection") {
                var connections = OfflineConnections()
                connections.database(name: connection, requiresUsername: false)
                connections.social(name: "facebook", style: .Facebook)
                let filtered = connections.select(byNames: ["facebook"])
                expect(filtered.database).to(beNil())
                expect(filtered.oauth2).toNot(beEmpty())
            }

            it("should select by name an oauth2 connection") {
                var connections = OfflineConnections()
                connections.database(name: connection, requiresUsername: false)
                connections.oauth2(name: "steam", style: AuthStyle(name: "Steam"))
                let filtered = connections.select(byNames: ["steam"])
                expect(filtered.database).to(beNil())
                expect(filtered.oauth2).toNot(beEmpty())
            }

            it("should select by name database connection") {
                var connections = OfflineConnections()
                connections.database(name: connection, requiresUsername: false)
                connections.social(name: "facebook", style: .Facebook)
                let filtered = connections.select(byNames: [connection])
                expect(filtered.database).toNot(beNil())
                expect(filtered.oauth2).to(beEmpty())
            }

            it("should select by name database connection") {
                var connections = OfflineConnections()
                connections.database(name: connection, requiresUsername: false)
                connections.database(name: "another-connection", requiresUsername: false)
                connections.social(name: "facebook", style: .Facebook)
                let filtered = connections.select(byNames: [connection])
                expect(filtered.database?.name) == connection
                expect(filtered.oauth2).to(beEmpty())
            }

            it("should select by name a passwordless connection") {
                var connections = OfflineConnections()
                connections.database(name: connection, requiresUsername: false)
                connections.database(name: "another-connection", requiresUsername: false)
                connections.social(name: "facebook", style: .Facebook)
                connections.email(name: "custom-email")
                connections.sms(name: "custom-sms")
                let filtered = connections.select(byNames: ["custom-email"])
                expect(filtered.database).to(beNil())
                expect(filtered.oauth2).to(beEmpty())
                expect(filtered.passwordless).to(haveCount(1))
            }

        }

    }

}
