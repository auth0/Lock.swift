// StorageSpec.swift
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

@testable import Lock

class StorageSpec: QuickSpec {

    override func spec() {

        var storage: Storage!

        it("should init storage") {
            storage = Storage()
            expect(storage).toNot(beNil())
        }

        describe("archive to keychain") {

            beforeEach {
                storage = Storage()
            }

            afterEach {
                storage?.clearAll()
            }

            it("should archive credentials and write to keychain") {
                expect(storage.archive(object: mockCredentials(), forKey: "credential_test")).to(beTrue())
            }

        }

        describe("unarchive from keychain") {

            beforeEach {
                storage = Storage()
                _ = storage.archive(object: mockCredentials(), forKey: "credential_test")
            }

            afterEach {
                storage?.clearAll()
            }

            it("should fail to unarchive invalid keychain entry") {
                expect(storage.unarchive(objectWithKey: "invalidkey")).to(beNil())
            }

            it("should fail to unarchive string keychain entry") {
                storage.setString("mystring", forKey: "test_string")
                expect(storage.unarchive(objectWithKey: "test_string")).to(beNil())
            }

            it("should fail to unarchive invalid data keychain entry") {
                storage.setData(Data(base64Encoded: "asdfasdfsadf" )!, forKey: "test_data")
                expect(storage.unarchive(objectWithKey: "test_data")).to(beNil())
            }

            it("should unarchive credentials from keychain") {
                expect(storage.unarchive(objectWithKey: "credential_test") as? Credentials).toNot(beNil())
            }
            
        }
    }
}
