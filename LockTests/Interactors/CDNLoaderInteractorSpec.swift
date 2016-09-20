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

            it("should not load strategies without name") {
                stub(isCDN(forClientId: clientId)) { _ in Auth0Stubs.strategiesFromCDN([[:]]) }
                loader.load(callback)
                expect(connections).toEventuallyNot(beNil())
                expect(connections?.database).toEventually(beNil())
                expect(connections?.oauth2).toEventually(beEmpty())
            }

            it("should not load connection without name") {
                stub(isCDN(forClientId: clientId)) { _ in Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [[:]])]) }
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

            it("should load single database connection with custom username validation") {
                stub(isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabaseConnection(databaseConnection, validation: ["username": ["min": 10, "max": 200]])])]) }
                loader.load(callback)
                expect(connections?.database).toEventuallyNot(beNil())
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
                expect(connections?.database?.requiresUsername).toEventually(beFalsy())
                let validator = connections?.database?.usernameValidator as? UsernameValidator
                expect(validator?.range.startIndex) == 10
                expect(validator?.range.endIndex) == 201
            }

            it("should load single database connection with custom username validation with strings") {
                stub(isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabaseConnection(databaseConnection, validation: ["username": ["min": "9", "max": "100"]])])]) }
                loader.load(callback)
                expect(connections?.database).toEventuallyNot(beNil())
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
                expect(connections?.database?.requiresUsername).toEventually(beFalsy())
                let validator = connections?.database?.usernameValidator as? UsernameValidator
                expect(validator?.range.startIndex) == 9
                expect(validator?.range.endIndex) == 101
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

            it("should load oauth2 connections") {
                stub(isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("oauth2", connections: [mockOAuth2("steam")])]) }
                loader.load(callback)
                expect(connections?.oauth2).toEventuallyNot(beNil())
                let oauth2 = connections?.oauth2.first
                expect(oauth2?.name) == "steam"
                expect(oauth2?.style.name) == "steam"
                expect(oauth2?.style.normalColor) == .a0_orange
            }

            it("should load first class social connections") {
                stub(isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("github", connections: [mockOAuth2("random")])]) }
                loader.load(callback)
                expect(connections?.oauth2).toEventuallyNot(beNil())
                let oauth2 = connections?.oauth2.first
                expect(oauth2?.name) == "random"
                expect(oauth2?.style) == .Github
            }

            it("should load multiple oauth2 connections") {
                stub(isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("facebook", connections: [mockOAuth2("facebook1"), mockOAuth2("facebook2")])]) }
                loader.load(callback)
                expect(connections?.oauth2).toEventuallyNot(beNil())
                expect(connections?.oauth2.count).toEventually(be(2))
                expect(connections?.oauth2[0].name) == "facebook1"
                expect(connections?.oauth2[1].name) == "facebook2"
            }

            it("should load database & oauth2 connection") {
                stub(isCDN(forClientId: clientId)) { _ in
                    return Auth0Stubs.strategiesFromCDN([
                        mockStrategy("auth0", connections: [mockDatabaseConnection(databaseConnection)]),
                        mockStrategy("facebook", connections: [mockOAuth2("facebook")])
                    ])
                }
                loader.load(callback)
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
                expect(connections?.oauth2).toEventually(haveCount(1))
            }

        }

    }

}

private func mockStrategy(name: String, connections: [JSONObject]) -> JSONObject {
    return ["name": name, "connections": connections]
}

private func mockOAuth2(name: String) -> JSONObject {
    let json: JSONObject = ["name": name ]
    return json
}

private func mockDatabaseConnection(name: String, requiresUsername: Bool? = nil, validation: JSONObject = [:]) -> JSONObject {
    var json: JSONObject = ["name": name ]
    if let requiresUsername = requiresUsername {
        json["requires_username"] = requiresUsername
    }
    json["validation"] = validation
    return json
}
