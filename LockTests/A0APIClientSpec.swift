// A0APIClientSpec.swift
//
// Copyright (c) 2015 Auth0 (http://auth0.com)
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

private let CLIENT_ID = "rU5HShUyQlEqbVWjZSTCBBLMUFAbJAS3"
private let TENANT = "samples"
private let ENDPOINT = "https://samples.auth0.com"
private let CONFIG_ENDPOINT = "https://cdn.auth0.com/client/rU5HShUyQlEqbVWjZSTCBBLMUFAbJAS3.js"
private let DB_CONNECTION = "DatabaseConnection"

private func FixturePathInBundle(name: String, forClassInBundle clazz: AnyClass) -> String {
    let bundle = NSBundle(forClass: clazz)
    let url = NSURL(string: name)!
    return bundle.pathForResource(url.URLByDeletingPathExtension?.absoluteString, ofType: url.pathExtension!)!
}

class A0APIClientSpec : QuickSpec {
    override func spec() {

        var client: A0APIClient!
        let api = Auth0API()

        beforeEach {
            let router = A0APIv1Router(clientId: CLIENT_ID, domainURL: NSURL(string: ENDPOINT), configurationURL: NSURL(string: CONFIG_ENDPOINT))
            client = A0APIClient(APIRouter: router)
            api.failForEveryRequest()
        }

        afterEach {
            api.reset()
        }

        describe("initialise") {

            it("should return clientId") {
                expect(client.clientId).to(equal(CLIENT_ID))
            }

            it("should return tenant") {
                expect(client.tenant).to(equal(TENANT))
            }

            it("should return api base URL") {
                expect(client.baseURL).to(equal(NSURL(string: ENDPOINT)))
            }

        }

        describe("application info from Auth0") {

            it("should load from cdn") {
                OHHTTPStubs.stubRequestsPassingTest({ request -> Bool in
                        return request.URL == client.router.configurationURL
                    }, withStubResponse: { request -> OHHTTPStubsResponse in
                        let path = FixturePathInBundle("GET-Application-Info.response", forClassInBundle: A0APIClientSpec.classForCoder())
                        return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
                    })
                waitUntil { done in
                    client.fetchAppInfoWithSuccess({ application in
                            expect(application.identifier).to(equal(CLIENT_ID))
                            expect(application.databaseStrategy).to(beNil())
                            expect(application.enterpriseStrategies).to(haveCount(0))
                            expect(application.socialStrategies).to(haveCount(4))
                            done()
                        },
                        failure: { error in
                            fail("Should be a successful request but got error \(error)")
                            done()
                        })
                }
            }

            it("should fail when 404 is returned") {
                OHHTTPStubs.stubRequestsPassingTest({ request -> Bool in
                    return request.URL == client.router.configurationURL
                    }, withStubResponse: { request -> OHHTTPStubsResponse in
                        return OHHTTPStubsResponse(JSONObject: ["error": "not_found"], statusCode: 404, headers: ["Content-Type" : "application/json"])
                    })
                waitUntil { done in
                    client.fetchAppInfoWithSuccess({ _ in
                            fail("Should not have received any application info")
                            done()
                        }, failure: { error in
                            done()
                        })
                }
            }

            it("should fail when data is not in jsonp") {
                OHHTTPStubs.stubRequestsPassingTest({ request -> Bool in
                        return request.URL == client.router.configurationURL
                    }, withStubResponse: { request -> OHHTTPStubsResponse in
                        let data = "INVALID".dataUsingEncoding(NSUTF8StringEncoding)!
                        return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type" : "application/json"])
                    })
                waitUntil { done in
                    client.fetchAppInfoWithSuccess({ _ in
                            fail("Should not have received any application info")
                            done()
                        }, failure: { error in
                            done()
                    })
                }
            }

        }

        describe("database connection") {
            var application: A0Application!

            beforeEach {
                application = MockApplication(id: CLIENT_ID, tenant: TENANT)
                client.configureForApplication(application)
            }

            it("should fail login with user/pwd when no connection is specified") {
                waitUntil { done in
                    client.loginWithUsername("username",
                        password: "password",
                        parameters: nil,
                        success: { _, _ in
                            fail("Should have failed")
                            done()
                        },
                        failure: { error in
                            expect(error.localizedFailureReason).to(equal("Can't find connection name to use for authentication"))
                            done()
                        })
                }
            }

            it("should fail signup when no connection is specified") {
                waitUntil { done in
                    client.signUpWithEmail("support@auth0.com",
                        password: "password",
                        loginOnSuccess: true,
                        parameters: nil,
                        success: { _, _ in
                            fail("Should have failed")
                            done()
                        },
                        failure: { error in
                            expect(error.localizedFailureReason).to(equal("Can't find connection name to use for authentication"))
                            done()
                    })
                }
            }

            it("should fail change password when no connection is specified") {
                waitUntil { done in
                    client.changePassword("password",
                        forUsername: "username",
                        parameters: nil,
                        success: {
                            fail("Should have failed")
                            done()
                        },
                        failure: { error in
                            expect(error.localizedFailureReason).to(equal("Can't find connection name to use for authentication"))
                            done()
                    })
                }
            }

        }
    }
}
