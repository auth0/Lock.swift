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
#if SWIFT_PACKAGE
import OHHTTPStubsSwift
#endif

@testable import Lock

class CDNLoaderInteractorSpec: QuickSpec {

    override func spec() {

        afterEach {
            Auth0Stubs.cleanAll()
            Auth0Stubs.failUnknown()
        }

        describe("init") {

            it("should build url from non-auth0 domain") {
                let loader = CDNLoaderInteractor(baseURL: URL(string: "https://somewhere.far.beyond")!, clientId: clientId)
                expect(loader.url.absoluteString) == "https://somewhere.far.beyond/client/\(clientId).js"
            }

            it("should build url from auth0 domain") {
                let loader = CDNLoaderInteractor(baseURL: URL(string: "https://samples.auth0.com")!, clientId: clientId)
                expect(loader.url.absoluteString) == "https://cdn.auth0.com/client/\(clientId).js"
            }

            it("should build url from auth0 domain for eu region") {
                let loader = CDNLoaderInteractor(baseURL: URL(string: "https://samples.eu.auth0.com")!, clientId: clientId)
                expect(loader.url.absoluteString) == "https://cdn.eu.auth0.com/client/\(clientId).js"
            }

            it("should build url from auth0 domain for au region") {
                let loader = CDNLoaderInteractor(baseURL: URL(string: "https://samples.au.auth0.com")!, clientId: clientId)
                expect(loader.url.absoluteString) == "https://cdn.au.auth0.com/client/\(clientId).js"
            }

        }

        describe("load") {

            var loader: CDNLoaderInteractor!
            var connections: Connections?
            var error: UnrecoverableError?
            var callback: ((UnrecoverableError?, Connections?) -> ())!

            beforeEach {
                loader = CDNLoaderInteractor(baseURL: URL(string: "https://overmind.auth0.com")!, clientId: clientId)
                callback = { error = $0
                             connections = $1 }
                connections = nil
                error = nil
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
                    stub(condition: isCDN(forClientId: clientId)) { _ in HTTPStubsResponse(data: Data(), statusCode: 400, headers: [:]) }
                    loader.load(callback)
                    expect(connections).toEventually(beNil())
                }

                it("should fail when there is no body") {
                    stub(condition: isCDN(forClientId: clientId)) { _ in HTTPStubsResponse(data: Data(), statusCode: 200, headers: [:]) }
                    loader.load(callback)
                    expect(connections).toEventually(beNil())
                }

                it("should fail for invalid json") {
                    stub(condition: isCDN(forClientId: clientId)) { _ in HTTPStubsResponse(data: "not a json object".data(using: String.Encoding.utf8)!, statusCode: 200, headers: [:]) }
                    loader.load(callback)
                    expect(connections).toEventually(beNil())
                }
            }

            context("remote connection errors") {

                it("should return invalid client error") {
                    stub(condition: isCDN(forClientId: clientId)) { _ in HTTPStubsResponse(data: Data(), statusCode: 403, headers: [:]) }
                    loader.load(callback)
                    expect(error).toEventually(equal(UnrecoverableError.invalidClientOrDomain))
                }

                it("should return invalid client info error") {
                    stub(condition: isCDN(forClientId: clientId)) { _ in HTTPStubsResponse(data: "not a json object".data(using: String.Encoding.utf8)!, statusCode: 200, headers: [:]) }
                    loader.load(callback)
                    expect(error).toEventually(equal(UnrecoverableError.invalidClientOrDomain))
                }

                it("should return request issue") {
                    loader.load(callback)
                    expect(error).toEventually(equal(UnrecoverableError.requestIssue))
                }

                it("should return no connections error") {
                    stub(condition: isCDN(forClientId: clientId)) { _ in Auth0Stubs.strategiesFromCDN([[:]]) }
                    loader.load(callback)
                    expect(error).toEventually(equal(UnrecoverableError.clientWithNoConnections))
                }

            }

            let databaseConnection = "DB Connection"

            it("should load empty strategies") {
                stub(condition: isCDN(forClientId: clientId)) { _ in Auth0Stubs.strategiesFromCDN([]) }
                loader.load(callback)
                expect(connections).toEventuallyNot(beNil())
                expect(connections?.database).toEventually(beNil())
                expect(connections?.oauth2).toEventually(beEmpty())
                expect(connections?.enterprise).toEventually(beEmpty())
            }

            it("should not load strategies without name") {
                stub(condition: isCDN(forClientId: clientId)) { _ in Auth0Stubs.strategiesFromCDN([[:]]) }
                loader.load(callback)
                expect(connections).toEventuallyNot(beNil())
                expect(connections?.database).toEventually(beNil())
                expect(connections?.oauth2).toEventually(beEmpty())
                expect(connections?.enterprise).toEventually(beEmpty())
            }

            it("should not load connection without name") {
                stub(condition: isCDN(forClientId: clientId)) { _ in Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [[:]])]) }
                loader.load(callback)
                expect(connections).toEventuallyNot(beNil())
                expect(connections?.database).toEventually(beNil())
                expect(connections?.oauth2).toEventually(beEmpty())
                expect(connections?.enterprise).toEventually(beEmpty())
            }

            it("should load single database connection") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabase(name: databaseConnection)])]) }
                loader.load(callback)
                expect(connections?.database).toEventuallyNot(beNil())
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
                expect(connections?.database?.requiresUsername).toEventually(beFalsy())
            }

            it("should load single database connection with no pwd policy") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabase(name: databaseConnection)])]) }
                loader.load(callback)
                expect(connections?.database?.passwordValidator.policy.name).toEventually(equal("none"))
            }

            it("should load single database connection with unknown pwd policy") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabase(name: databaseConnection, passwordPolicy: "random")])]) }
                loader.load(callback)
                expect(connections?.database?.passwordValidator.policy.name).toEventually(equal("none"))
            }

            ["none", "low", "fair", "good", "excellent"].forEach { name in
                it("should load single database connection with policy \(name))") {
                    stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabase(name: databaseConnection, passwordPolicy: name)])]) }
                    loader.load(callback)
                    expect(connections?.database?.passwordValidator.policy.name).toEventually(equal(name))
                }
            }

            it("should load single database connection with custom username validation") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabase(name: databaseConnection, validation: (["username": ["min": 10, "max": 200]] as Any) as! JSONObject )])]) }
                loader.load(callback)
                expect(connections?.database).toEventuallyNot(beNil())
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
                expect(connections?.database?.requiresUsername).toEventually(beFalsy())
                let validator = connections?.database?.usernameValidator
                expect(validator?.range.lowerBound) == 10
                expect(validator?.range.upperBound) == 200
            }

            it("should load single database connection with custom username validation with strings") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabase(name: databaseConnection, validation: (["username": ["min": "9", "max": "100"]] as Any) as! JSONObject)])]) }
                loader.load(callback)
                expect(connections?.database).toEventuallyNot(beNil())
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
                expect(connections?.database?.requiresUsername).toEventually(beFalsy())
                let validator = connections?.database?.usernameValidator
                expect(validator?.range.lowerBound) == 9
                expect(validator?.range.upperBound) == 100
            }

            it("should load multiple database connections but pick the first") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabase(name: databaseConnection), mockDatabase(name: "another one")])]) }
                loader.load(callback)
                expect(connections?.database).toEventuallyNot(beNil())
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
            }

            it("should load single database connection with requires_username") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("auth0", connections: [mockDatabase(name: databaseConnection, requiresUsername: true)])]) }
                loader.load(callback)
                expect(connections?.database).toEventuallyNot(beNil())
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
                expect(connections?.database?.requiresUsername).toEventually(beTruthy())
            }

            // MARK: OAuth2

            it("should load oauth2 connections") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("oauth2", connections: [mockOAuth2("steam")])]) }
                loader.load(callback)
                expect(connections?.oauth2).toEventuallyNot(beNil())
                let oauth2 = connections?.oauth2.first
                expect(oauth2?.name) == "steam"
                expect(oauth2?.style.name) == "steam"
                expect(oauth2?.style.normalColor) == .a0_orange
            }

            it("should load first class social connections") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("github", connections: [mockOAuth2("random")])]) }
                loader.load(callback)
                expect(connections?.oauth2).toEventuallyNot(beNil())
                let oauth2 = connections?.oauth2.first
                expect(oauth2?.name) == "random"
                expect(oauth2?.style) == .Github
            }

            it("should load multiple oauth2 connections") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([mockStrategy("facebook", connections: [mockOAuth2("facebook1"), mockOAuth2("facebook2")])]) }
                loader.load(callback)
                expect(connections?.oauth2).toEventuallyNot(beNil())
                expect(connections?.oauth2.count).toEventually(equal(2))
                expect(connections?.oauth2[0].name) == "facebook1"
                expect(connections?.oauth2[1].name) == "facebook2"
            }

            it("should load database & oauth2 connection") {
                stub(condition: isCDN(forClientId: clientId)) { _ in
                    return Auth0Stubs.strategiesFromCDN([
                        mockStrategy("auth0", connections: [mockDatabase(name: databaseConnection)]),
                        mockStrategy("facebook", connections: [mockOAuth2("facebook")])
                        ])
                }
                loader.load(callback)
                expect(connections?.database?.name).toEventually(equal(databaseConnection))
                expect(connections?.oauth2).toEventually(haveCount(1))
            }

            // MARK: Enterprise

            it("should load single enterprise connection") {
                stub(condition: isCDN(forClientId: clientId)) { _ in
                    return Auth0Stubs.strategiesFromCDN([
                    mockStrategy("ad", connections: [mockEnterprise(name: "TestAD", domains: ["test.com"]) ])
                    ])
                }
                loader.load(callback)
                expect(connections?.enterprise).toEventually(haveCount(1))
                expect(connections?.enterprise.first?.name) == "TestAD"
                expect(connections?.enterprise.first?.domains) == ["test.com"]
                expect(connections?.enterprise.first?.style.name) == "test.com"
            }

            it("should load single enterprise connection with no domain") {
                stub(condition: isCDN(forClientId: clientId)) { _ in
                    return Auth0Stubs.strategiesFromCDN([
                            mockStrategy("ad", connections: [mockEnterprise(name: "TestAD", domains: []) ])
                    ])
                }
                loader.load(callback)
                expect(connections?.enterprise).toEventually(haveCount(1))
                expect(connections?.enterprise.first?.name) == "TestAD"
                expect(connections?.enterprise.first?.domains).toEventually(beEmpty())
                expect(connections?.enterprise.first?.style.name) == "ad"
            }

            it("should load multiple ad enterprise connections") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([
                        mockStrategy("ad", connections: [
                                mockEnterprise(name: "TestAD", domains: ["test.com"]),
                                mockEnterprise(name: "fakeAD", domains: ["fake.com"])]
                        )]) }
                loader.load(callback)
                expect(connections?.enterprise).toEventually(haveCount(2))
                expect(connections?.enterprise[0].name) == "TestAD"
                expect(connections?.enterprise[1].name) == "fakeAD"
            }

            it("should load multiple enterprise connections") {
                stub(condition: isCDN(forClientId: clientId)) { _ in
                    return Auth0Stubs.strategiesFromCDN([
                        mockStrategy("ad", connections: [
                                mockEnterprise(name: "fakeAD", domains: ["fake.com"])]
                        ),
                        mockStrategy("samlp", connections: [
                                mockEnterprise(name: "fakeSAML", domains: ["false.com"])]
                        )
                    ])
                }
                loader.load(callback)
                expect(connections?.enterprise).toEventually(haveCount(2))
                expect(connections?.enterprise[0].name) == "fakeAD"
                expect(connections?.enterprise[1].name) == "fakeSAML"
            }

            it("should load database & enterprise connections") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([
                    mockStrategy("auth0", connections: [mockDatabase(name: databaseConnection)]),
                    mockStrategy("ad", connections: [
                            mockEnterprise(name: "TestAD", domains: ["test.com"]),
                            mockEnterprise(name: "fakeAD", domains: ["fake.com"])]
                    )]) }
                loader.load(callback)
                expect(connections?.database?.name).toEventually(equal(databaseConnection))

                expect(connections?.enterprise).toEventuallyNot(beNil())
                expect(connections?.enterprise.count).toEventually(equal(2))
                expect(connections?.enterprise[0].name) == "TestAD"
                expect(connections?.enterprise[1].name) == "fakeAD"
            }

            it("should load enterprise & social connections") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([
                    mockStrategy("facebook", connections: [
                        mockOAuth2("facebook1"),
                        mockOAuth2("facebook2")]),
                    mockStrategy("ad", connections: [
                            mockEnterprise(name: "TestAD", domains: ["test.com"]),
                            mockEnterprise(name: "fakeAD", domains: ["fake.com"])]
                    )]) }
                loader.load(callback)
                expect(connections?.oauth2).toEventuallyNot(beNil())
                expect(connections?.oauth2.count).toEventually(equal(2))
                expect(connections?.oauth2[0].name) == "facebook1"
                expect(connections?.oauth2[1].name) == "facebook2"

                expect(connections?.enterprise).toEventuallyNot(beNil())
                expect(connections?.enterprise.count).toEventually(equal(2))
                expect(connections?.enterprise[0].name) == "TestAD"
                expect(connections?.enterprise[1].name) == "fakeAD"
            }

            it("should load enterprise, database & social connections") {
                stub(condition: isCDN(forClientId: clientId)) { _ in return Auth0Stubs.strategiesFromCDN([
                    mockStrategy("auth0", connections: [mockDatabase(name: databaseConnection)]),
                    mockStrategy("facebook", connections: [
                        mockOAuth2("facebook1"),
                        mockOAuth2("facebook2")]),
                    mockStrategy("ad", connections: [
                            mockEnterprise(name: "TestAD", domains: ["test.com"]),
                            mockEnterprise(name: "fakeAD", domains: ["fake.com"])]
                    )]) }
                loader.load(callback)
                expect(connections?.database?.name).toEventually(equal(databaseConnection))

                expect(connections?.oauth2).toEventuallyNot(beNil())
                expect(connections?.oauth2.count).toEventually(equal(2))
                expect(connections?.oauth2[0].name) == "facebook1"
                expect(connections?.oauth2[1].name) == "facebook2"

                expect(connections?.enterprise).toEventuallyNot(beNil())
                expect(connections?.enterprise.count).toEventually(equal(2))
                expect(connections?.enterprise[0].name) == "TestAD"
                expect(connections?.enterprise[1].name) == "fakeAD"
            }

        }

    }

}

private func mockStrategy(_ name: String, connections: [JSONObject]) -> JSONObject {
    return ["name": name as Any, "connections": connections as Any]
}

private func mockOAuth2(_ name: String) -> JSONObject {
    let json: JSONObject = ["name": name as Any ]
    return json
}

private func mockDatabase(name: String, requiresUsername: Bool? = nil, validation: JSONObject = [:], passwordPolicy: String? = nil) -> JSONObject {
    var json: JSONObject = ["name": name ]
    if let requiresUsername = requiresUsername {
        json["requires_username"] = requiresUsername
    }
    json["validation"] = validation
    if let passwordPolicy = passwordPolicy {
        json["passwordPolicy"] = passwordPolicy
    }
    return json
}

private func mockEnterprise(name: String, domains: [String] ) -> JSONObject {
    var json: JSONObject = ["name": name, "domain_aliases": domains]
    if let domain = domains.first {
        json["domain"] = domain
    }
    return json
}
