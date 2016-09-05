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
            connections.database(name: connection, requiresUsername: false)
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

        describe("filter") {

            it("should not filter by default") {
                var connections = OfflineConnections()
                connections.database(name: connection, requiresUsername: false)
                connections.social(name: "facebook", style: .Facebook)
                expect(connections.database).toNot(beNil())
                expect(connections.oauth2).toNot(beEmpty())
            }

            it("should not filter with empty list") {
                var connections = OfflineConnections(allowedConnections: [])
                connections.database(name: connection, requiresUsername: false)
                connections.social(name: "facebook", style: .Facebook)
                expect(connections.database).toNot(beNil())
                expect(connections.oauth2).toNot(beEmpty())
            }

            it("should filter by name social") {
                var connections = OfflineConnections(allowedConnections: ["facebook"])
                connections.database(name: connection, requiresUsername: false)
                connections.social(name: "facebook", style: .Facebook)
                expect(connections.database).toNot(beNil())
                expect(connections.oauth2).to(beEmpty())
            }

            it("should filter by name oauth2") {
                var connections = OfflineConnections(allowedConnections: ["steam"])
                connections.database(name: connection, requiresUsername: false)
                connections.oauth2(name: "steam", style: AuthStyle(name: "Steam"))
                expect(connections.database).toNot(beNil())
                expect(connections.oauth2).to(beEmpty())
            }

            it("should filter by name database connection") {
                var connections = OfflineConnections(allowedConnections: [connection])
                connections.database(name: connection, requiresUsername: false)
                connections.social(name: "facebook", style: .Facebook)
                expect(connections.database).to(beNil())
                expect(connections.oauth2).toNot(beEmpty())
            }

        }

    }

}