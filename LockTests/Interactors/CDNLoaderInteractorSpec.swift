// CDNLoaderInteractorSpec.swift
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
import OHHTTPStubs

@testable import Lock

class CDNLoaderInteractorSpec: QuickSpec {

    override func spec() {

        afterEach {
            Auth0Stubs.cleanAll()
            Auth0Stubs.failUnknown()
        }

        describe("init") {

            it("should build url from non-auth0 domain") {
                let loader = CDNLoaderInteractor(baseURL: NSURL(string: "https://somewhere.far.beyond")!, clientId: clientId)
                expect(loader.url.absoluteString) == "https://somewhere.far.beyond/client/\(clientId).js"
            }

            it("should build url from auth0 domain") {
                let loader = CDNLoaderInteractor(baseURL: NSURL(string: "https://samples.auth0.com")!, clientId: clientId)
                expect(loader.url.absoluteString) == "https://cdn.auth0.com/client/\(clientId).js"
            }

            it("should build url from auth0 domain for eu region") {
                let loader = CDNLoaderInteractor(baseURL: NSURL(string: "https://samples.eu.auth0.com")!, clientId: clientId)
                expect(loader.url.absoluteString) == "https://cdn.eu.auth0.com/client/\(clientId).js"
            }

            it("should build url from auth0 domain for au region") {
                let loader = CDNLoaderInteractor(baseURL: NSURL(string: "https://samples.au.auth0.com")!, clientId: clientId)
                expect(loader.url.absoluteString) == "https://cdn.au.auth0.com/client/\(clientId).js"
            }

        }

        describe("load") {

            var loader: CDNLoaderInteractor!
            var connections: Connections?
            var callback: (Connections? -> ())!

            beforeEach {
                loader = CDNLoaderInteractor(baseURL: NSURL(string: "https://overmind.auth0.com")!, clientId: clientId)
                callback = { connections = $0 }
                connections = nil
            }

            context("failure") {

                beforeEach {
                    connections = OfflineConnections()
                }

                it("should fail") {
                    loader.load(callback)
                    expect(connections).toEventually(beNil())
                }

                it("should fail for status code not in range 200...299") {
                    stub(isCDN(forClientId: clientId)) { _ in OHHTTPStubsResponse(data: NSData(), statusCode: 400, headers: [:]) }
                    loader.load(callback)
                    expect(connections).toEventually(beNil())
                }

                it("should fail when there is no body") {
                    stub(isCDN(forClientId: clientId)) { _ in OHHTTPStubsResponse(data: NSData(), statusCode: 200, headers: [:]) }
                    loader.load(callback)
                    expect(connections).toEventually(beNil())
                }

                it("should fail for invalid json") {
                    stub(isCDN(forClientId: clientId)) { _ in OHHTTPStubsResponse(data: "not a json object".dataUsingEncoding(NSUTF8StringEncoding)!, statusCode: 200, headers: [:]) }
                    loader.load(callback)
                    expect(connections).toEventually(beNil())
                }
            }

            let databaseConnection = "DB Connection"

            it("should load empty strategies") {
                stub(isCDN(forClientId: clientId)) { _ in Auth0Stubs.strategiesFromCDN([]) }
                loader.load(callback)
                expect(connections).toEventuallyNot(beNil())
                expect(connections?.database).toEventually(beNil())
                expect(connections?.oauth2).toEventually(beEmpty())
            }

            it("should load single database connection") {
                stub(isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabaseConnection(databaseConnection)])]) }
                loader.load(callback)
                expect(connections?.database).toEventuallyNot(beNil())
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
                expect(connections?.database?.requiresUsername).toEventually(beFalsy())
            }

            it("should load multiple database connections but pick the first") {
                stub(isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabaseConnection(databaseConnection), mockDatabaseConnection("another one")])]) }
                loader.load(callback)
                expect(connections?.database).toEventuallyNot(beNil())
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
            }

            it("should load single database connection with requires_username") {
                stub(isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabaseConnection(databaseConnection, requiresUsername: true)])]) }
                loader.load(callback)
                expect(connections?.database).toEventuallyNot(beNil())
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
                expect(connections?.database?.requiresUsername).toEventually(beTruthy())
            }

        }

    }

}

private func mockStrategy(name: String, connections: [JSONObject]) -> JSONObject {
    return ["name": name, "connections": connections]
}

private func mockDatabaseConnection(name: String, requiresUsername: Bool? = nil) -> JSONObject {
    var json: JSONObject = ["name": name ]
    if let requiresUsername = requiresUsername {
        json["requires_username"] = requiresUsername
    }
    return json
}