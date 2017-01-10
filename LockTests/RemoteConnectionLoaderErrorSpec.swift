// RemoteConnectionLoaderErrorSpec.swift
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

class RemoteConnectionLoaderErrorSpec: QuickSpec {

    override func spec() {

        describe("localised message response") {

            it(".invalidClient should return relevant string") {
                let error = RemoteConnectionLoaderError.invalidClient
                expect(error.localizableMessage).to(contain("No client information found"))
            }

            it(".invalidClientInfo should return relevant string") {
                let error = RemoteConnectionLoaderError.invalidClientInfo
                expect(error.localizableMessage).to(contain("Unable to retrieve client information"))
            }

            it(".noConnections should return relevant string") {
                let error = RemoteConnectionLoaderError.noConnections
                expect(error.localizableMessage).to(contain("No connections available"))
            }

            it(".connectionTimeout should return default string") {
                let error = RemoteConnectionLoaderError.connectionTimeout
                expect(error.localizableMessage).to(contain("Could not connect to the server"))
            }

            it(".requestIssue should return default string") {
                let error = RemoteConnectionLoaderError.requestIssue
                expect(error.localizableMessage).to(contain("Could not connect to the server"))
            }

            it(".responseIssue should return default string") {
                let error = RemoteConnectionLoaderError.responseIssue
                expect(error.localizableMessage).to(contain("Could not connect to the server"))
            }

        }
        
    }
}
