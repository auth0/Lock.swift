// UnrecoverableErrorSpec.swift
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

class UnrecoverableErrorSpec: QuickSpec {

    override func spec() {

        describe("localised message response") {

            it(".invalidClientOrDomain should return relevant string") {
                let error = UnrecoverableError.invalidClientOrDomain
                expect(error.localizableMessage).to(contain("No client information found"))
            }

            it(".clientWithNoConnections should return relevant string") {
                let error = UnrecoverableError.clientWithNoConnections
                expect(error.localizableMessage).to(contain("No connections available"))
            }

            it(".connectionTimeout should return default string") {
                let error = UnrecoverableError.connectionTimeout
                expect(error.localizableMessage).to(contain("problem with your request"))
            }

            it(".requestIssue should return default string") {
                let error = UnrecoverableError.requestIssue
                expect(error.localizableMessage).to(contain("problem with your request"))
            }

            it(".missingDatabaseConnection should return relevant string") {
                let error = UnrecoverableError.missingDatabaseConnection
                expect(error.localizableMessage).to(contain("No database connection was found"))
            }

            it(".invalidOptions should return relevant string") {
                let error = UnrecoverableError.invalidOptions(cause: "bad options")
                expect(error.localizableMessage).to(contain("bad options"))
            }

        }

        describe("equatable") {

            it("invalidClientOrDomain should should be equatable with itself") {
                let match = UnrecoverableError.invalidClientOrDomain == UnrecoverableError.invalidClientOrDomain
                expect(match).to(beTrue())
            }

            it("clientWithNoConnections should should be equatable with itself") {
                let match = UnrecoverableError.clientWithNoConnections == UnrecoverableError.clientWithNoConnections
                expect(match).to(beTrue())
            }

            it("connectionTimeout should should be equatable with itself") {
                let match = UnrecoverableError.connectionTimeout == UnrecoverableError.connectionTimeout
                expect(match).to(beTrue())
            }

            it("requestIssue should should be equatable with itself") {
                let match = UnrecoverableError.requestIssue == UnrecoverableError.requestIssue
                expect(match).to(beTrue())
            }

            it("missingDatabaseConnection should should be equatable with itself") {
                let match = UnrecoverableError.missingDatabaseConnection == UnrecoverableError.missingDatabaseConnection
                expect(match).to(beTrue())
            }

            it("invalidOptions should should be equatable with itself") {
                let match = UnrecoverableError.invalidOptions(cause: "bad options") == UnrecoverableError.invalidOptions(cause: "bad options")
                expect(match).to(beTrue())
            }
        }
        
    }
}
