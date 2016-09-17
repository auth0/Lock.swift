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
private let JWT = "HEADER.PAYLOAD.SIGNATURE"
private let EMAIL = "support@auth0.com"
private let USERNAME = "username"
private let PASSWORD = "password"
private let DEVICE = UUID().uuidString
private let SOCIAL_TOKEN = "SOCIAL TOKEN"
private let REFRESH_TOKEN = "RefreshToken"

private func FixturePathInBundle(_ name: String, forClassInBundle clazz: AnyClass) -> String {
    let bundle = Bundle(for: clazz)
    let url = URL(string: name)!
    return bundle.path(forResource: url.deletingPathExtension().absoluteString, ofType: url.pathExtension)!
}

class A0APIClientSpec : QuickSpec {
    override func spec() {

        var client: A0APIClient!
        let api = Auth0API()

        beforeEach {
            let router = A0APIv1Router(clientId: CLIENT_ID, domainURL: NSURL(string: ENDPOINT) as URL!, configurationURL: NSURL(string: CONFIG_ENDPOINT) as URL!)
            client = A0APIClient(apiRouter: router!)
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
                expect(client.baseURL).to(equal(URL(string: ENDPOINT)))
            }

        }

        describe("application info from Auth0") {

            it("should load from cdn") {
                OHHTTPStubs.stubRequests(passingTest: { request -> Bool in
                        return request.url == client.router.configurationURL
                    }, withStubResponse: { request -> OHHTTPStubsResponse in
                        let path = FixturePathInBundle("GET-Application-Info.response", forClassInBundle: A0APIClientSpec.classForCoder())
                        return OHHTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: ["Content-Type" : "application/json"])
                    })
                waitUntil { done in
                    client.fetchAppInfo(success: { application in
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
                OHHTTPStubs.stubRequests(passingTest: { request -> Bool in
                    return request.url == client.router.configurationURL
                    }, withStubResponse: { request -> OHHTTPStubsResponse in
                        return OHHTTPStubsResponse(jsonObject: ["error": "not_found"], statusCode: 404, headers: ["Content-Type" : "application/json"])
                    })
                waitUntil { done in
                    client.fetchAppInfo(success: { _ in
                            fail("Should not have received any application info")
                            done()
                        }, failure: { error in
                            done()
                        })
                }
            }

            it("should fail when data is not in jsonp") {
                OHHTTPStubs.stubRequests(passingTest: { request -> Bool in
                        return request.url == client.router.configurationURL
                    }, withStubResponse: { request -> OHHTTPStubsResponse in
                        let data = "INVALID".data(using: String.Encoding.utf8)!
                        return OHHTTPStubsResponse(data: data, statusCode: 200, headers: ["Content-Type" : "application/json"])
                    })
                waitUntil { done in
                    client.fetchAppInfo(success: { _ in
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
                client.configure(for: application)
                client.manager.requestSerializer = A0AnnotatedRequestSerializer()
            }

            it("should fail login with user/pwd when no connection is specified") {
                waitUntil { done in
                    client.login(withUsername: USERNAME,
                        password: PASSWORD,
                        parameters: nil,
                        success: { _, _ in
                            fail("Should have failed")
                            done()
                        },
                        failure: { error in
                            expect((error as NSError).localizedFailureReason).to(equal("Can't find connection name to use for authentication"))
                            done()
                        })
                }
            }

            it("should fail signup when no connection is specified") {
                waitUntil { done in
                    client.signUp(withEmail: EMAIL,
                        password: PASSWORD,
                        loginOnSuccess: true,
                        parameters: nil,
                        success: { _, _ in
                            fail("Should have failed")
                            done()
                        },
                        failure: { error in
                            expect((error as NSError).localizedFailureReason).to(equal("Can't find connection name to use for authentication"))
                            done()
                    })
                }
            }

            it("should fail change password when no connection is specified") {
                waitUntil { done in
                    client.changePassword(PASSWORD,
                        forUsername: USERNAME,
                        parameters: nil,
                        success: {
                            fail("Should have failed")
                            done()
                        },
                        failure: { error in
                            expect((error as NSError).localizedFailureReason).to(equal("Can't find connection name to use for authentication"))
                            done()
                    })
                }
            }

            context("with application info") {

                beforeEach {
                    application = MockApplication(id: CLIENT_ID, tenant: TENANT, databases: [DB_CONNECTION])
                    client.configure(for: application)
                }

                describe("login email/password") {

                    it("should login with username/password") {
                        api.allowLoginWithUsername(USERNAME, password: PASSWORD, clientId: CLIENT_ID, database: DB_CONNECTION)
                        api.allowTokenInfoForToken(JWT)
                        waitUntil { done in
                            client.login(withUsername: USERNAME,
                                password: PASSWORD,
                                parameters: nil,
                                success: { (profile, token) in
                                    done()
                                },
                                failure: { error in
                                    fail("It should be a successful login")
                                    done()
                            })
                        }
                    }

                    it("should login with username/password with parameters") {
                        api.allowLoginWithUsername(USERNAME, password: PASSWORD, clientId: CLIENT_ID, database: DB_CONNECTION)
                        api.allowTokenInfoForToken(JWT)
                        waitUntil { done in
                            let parameters = A0AuthParameters.new(with: ["key": "value"])
                            client.login(withUsername: USERNAME,
                                password: PASSWORD,
                                parameters: parameters,
                                success: { (profile, token) in
                                    done()
                                },
                                failure: { error in
                                    fail("It should be a successful login")
                                    done()
                            })
                        }
                    }

                    it("should login with username/password with parameters") {
                        api.allowLoginWithParameters([
                            "username": USERNAME,
                            "password": PASSWORD,
                            "scope": "openid"
                            ])
                        api.allowTokenInfoForToken(JWT)
                        waitUntil { done in
                            let parameters = A0AuthParameters.new(withScopes: ["openid"])
                            client.login(withUsername: USERNAME,
                                password: PASSWORD,
                                parameters: parameters,
                                success: { (profile, token) in
                                    done()
                                },
                                failure: { error in
                                    fail("It should be a successful login")
                                    done()
                                })
                        }
                    }
                }

                describe("signup user/pwd") {

                    it("should create and login user") {
                        api.allowSignUpWithParameters([
                            "email": EMAIL,
                            "password": PASSWORD,
                            "client_id": CLIENT_ID,
                            "connection": DB_CONNECTION,
                            ])
                        api.allowLoginWithUsername(EMAIL, password: PASSWORD, clientId: CLIENT_ID, database: DB_CONNECTION)
                        api.allowTokenInfoForToken(JWT)
                        waitUntil { done in
                            client.signUp(withEmail: EMAIL,
                                password: PASSWORD,
                                loginOnSuccess: true,
                                parameters: nil,
                                success: { (profile, token) in
                                    expect(profile).toNot(beNil())
                                    expect(token).toNot(beNil())
                                    done()
                                },
                                failure: { error in
                                    fail("It should be a successful signup and login")
                                    done()
                                })
                        }
                    }

                    it("should only create user") {
                        api.allowSignUpWithParameters([
                            "email": EMAIL,
                            "password": PASSWORD,
                            "client_id": CLIENT_ID,
                            "connection": DB_CONNECTION,
                            ])
                        waitUntil { done in
                            client.signUp(withEmail: EMAIL,
                                password: PASSWORD,
                                loginOnSuccess: false,
                                parameters: nil,
                                success: { (profile, token) in
                                    expect(profile).to(beNil())
                                    expect(token).to(beNil())
                                    done()
                                },
                                failure: { error in
                                    fail("It should be a successful signup")
                                    done()
                            })
                        }
                    }

                    it("should create and login user with email & username") {
                        api.allowSignUpWithParameters([
                            "email": EMAIL,
                            "username": USERNAME,
                            "password": PASSWORD,
                            "client_id": CLIENT_ID,
                            "connection": DB_CONNECTION,
                            ])
                        api.allowLoginWithUsername(USERNAME, password: PASSWORD, clientId: CLIENT_ID, database: DB_CONNECTION)
                        api.allowTokenInfoForToken(JWT)
                        waitUntil { done in
                            client.signUp(withEmail: EMAIL,
                                username: USERNAME,
                                password: PASSWORD,
                                loginOnSuccess: true,
                                parameters: nil,
                                success: { (profile, token) in
                                    expect(profile).toNot(beNil())
                                    expect(token).toNot(beNil())
                                    done()
                                },
                                failure: { error in
                                    fail("It should be a successful signup and login")
                                    done()
                            })
                        }
                    }

                    it("should create and login user with parameters") {
                        api.allowSignUpWithParameters([
                            "email": EMAIL,
                            "username": USERNAME,
                            "password": PASSWORD,
                            "client_id": CLIENT_ID,
                            "connection": DB_CONNECTION,
                            "custom_key": "custom_value"
                            ])
                        api.allowLoginWithUsername(USERNAME, password: PASSWORD, clientId: CLIENT_ID, database: DB_CONNECTION)
                        api.allowTokenInfoForToken(JWT)
                        waitUntil { done in
                            let parameters = A0AuthParameters.new(with: ["custom_key": "custom_value"])
                            client.signUp(withEmail: EMAIL,
                                username: USERNAME,
                                password: PASSWORD,
                                loginOnSuccess: true,
                                parameters: parameters,
                                success: { (profile, token) in
                                    expect(profile).toNot(beNil())
                                    expect(token).toNot(beNil())
                                    done()
                                },
                                failure: { error in
                                    fail("It should be a successful signup and login")
                                    done()
                            })
                        }
                    }

                    it("should call failure when create user fails") {
                        api.failForRoute(.SignUp,
                            parameters: [
                                "email": EMAIL,
                                "username": USERNAME,
                                "password": PASSWORD,
                                "client_id": CLIENT_ID,
                                "connection": DB_CONNECTION,
                            ],
                            message: "signup_failed")
                        waitUntil { done in
                            client.signUp(withEmail: EMAIL,
                                username: USERNAME,
                                password: PASSWORD,
                                loginOnSuccess: true,
                                parameters: nil,
                                success: { (profile, token) in
                                    fail("It should not be a successful signup or login")
                                    done()
                                },
                                failure: { error in
                                    expect(error.localizedDescription).to(equal("signup_failed"))
                                    done()
                            })
                        }
                    }
                }

                describe("change password") {

                    it("should change password") {
                        api.allowChangePasswordWithParameters([
                            "email": EMAIL,
                            "password": PASSWORD,
                            "connection": DB_CONNECTION
                            ])
                        waitUntil { done in
                            client.changePassword(PASSWORD,
                                forUsername: EMAIL,
                                parameters: nil,
                                success: { done() },
                                failure: { _ in
                                    fail("Should have changed password")
                                    done()
                            })
                        }
                    }

                    it("should fail to change password with error") {
                        api.failForRoute(.ChangePassword,
                            parameters: [
                                "email": EMAIL,
                                "password": PASSWORD,
                                "connection": DB_CONNECTION
                            ], message: "failed_change_passsword")
                        waitUntil { done in
                            client.changePassword(PASSWORD,
                                forUsername: EMAIL,
                                parameters: nil,
                                success: {
                                    fail("Should have failed to change password")
                                    done()
                                },
                                failure: { error in
                                    expect(error.localizedDescription).to(equal("failed_change_passsword"))
                                    done()
                            })
                        }
                    }

                    it("should request change password") {
                        api.allowChangePasswordWithParameters([
                            "email": EMAIL,
                            "connection": DB_CONNECTION
                            ])
                        waitUntil { done in
                            client.requestChangePassword(forUsername: EMAIL,
                                parameters: nil,
                                success: { done() },
                                failure: { _ in
                                    fail("Should have changed password")
                                    done()
                            })
                        }
                    }

                    it("should fail to request change password with error") {
                        api.failForRoute(.ChangePassword,
                            parameters: [
                                "email": EMAIL,
                                "connection": DB_CONNECTION
                            ], message: "failed_change_passsword")
                        waitUntil { done in
                            client.requestChangePassword(forUsername: EMAIL,
                                parameters: nil,
                                success: {
                                    fail("Should have failed to change password")
                                    done()
                                },
                                failure: { error in
                                    expect(error.localizedDescription).to(equal("failed_change_passsword"))
                                    done()
                            })
                        }
                    }

                }

                describe("login with JWT") {

                    it("should login with valid JWT") {
                        let idToken = "id_token"
                        api.allowLoginWithParameters([
                            "id_token": idToken,
                            "device": DEVICE,
                            "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                            "client_id" :CLIENT_ID,
                            ])
                        api.allowTokenInfoForToken(JWT)
                            waitUntil { done in
                                client.login(withIdToken: idToken,
                                    deviceName: DEVICE,
                                    parameters: nil,
                                    success: { (profile, token) in
                                        done()
                                    },
                                    failure: { error in
                                        fail("Should have logged in with JWT")
                                        done()
                                    })
                            }
                    }

                    it("should call failure callback with error") {
                        let idToken = "id_token"
                        api.failForRoute(.Login,
                            parameters: [
                                "id_token": idToken,
                                "device": DEVICE,
                                "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                                "client_id" :CLIENT_ID,
                            ],
                            message: "jwt_login_failed")
                        waitUntil { done in
                            client.login(withIdToken: idToken,
                                deviceName: DEVICE,
                                parameters: nil,
                                success: { (profile, token) in
                                    fail("Should have failed to login")
                                    done()
                                },
                                failure: { error in
                                    expect(error.localizedDescription).to(equal("jwt_login_failed"))
                                    done()
                            })
                        }
                    }
                }
            } //END DB Connection

            describe("login with SMS") {

                let phoneNumber = "4444444444"
                let code = "1234"

                context("with sms connection enabled") {

                    beforeEach {
                        application = MockApplication(id: CLIENT_ID, tenant: TENANT, hasPasswordless: true)
                        client.configure(for: application)
                        client.manager.requestSerializer = A0AnnotatedRequestSerializer()
                    }

                    it("should login with valid SMS and code") {
                        api.allowLoginWithParameters([
                            "username": phoneNumber,
                            "password": code,
                            "connection": "sms",
                            "grant_type": "password",
                            "client_id" :CLIENT_ID,
                            ])
                        api.allowTokenInfoForToken(JWT)
                        waitUntil { done in
                            client.login(withPhoneNumber: phoneNumber,
                                passcode: code,
                                parameters: nil,
                                success: { _, _ in
                                    done()
                                },
                                failure: { error in
                                    fail("Should have not failed to authencticate with sms")
                                    done()
                            })
                        }
                    }

                    it("should call failure callback with error") {
                        api.failForRoute(.Login,
                            parameters: [
                                "username": phoneNumber,
                                "password": code,
                                "connection": "sms",
                                "grant_type": "password",
                                "client_id" :CLIENT_ID,
                            ],
                            message: "sms_login_failed")
                        waitUntil { done in
                            client.login(withPhoneNumber: phoneNumber,
                                passcode: code,
                                parameters: nil,
                                success: { _, _ in
                                    fail("Should have failed")
                                    done()
                                },
                                failure: { error in
                                    expect(error.localizedDescription).to(equal("sms_login_failed"))
                                    done()
                            })
                        }
                    }
                }
            } //End SMS

            describe("start sms passwordless authentication") {

                let phoneNumber = "1234567890"

                it("should send sms") {
                    api.allowStartPasswordlessWithParameters([
                        "phone_number": phoneNumber,
                        "connection": "sms",
                    ])
                    waitUntil { done in
                        client.startPasswordless(withPhoneNumber: phoneNumber, success: { done() }, failure: { _ in fail("Should not have failed") })
                    }
                }

                it("should call failure callback with error") {
                    api.failForRoute(.StartPasswordless,
                        parameters: [
                            "phone_number": phoneNumber,
                        ],
                        message: "passwordless_start_failed")
                    waitUntil { done in
                        client.startPasswordless(withPhoneNumber: phoneNumber, success: { fail("Should have failed") }, failure: { error in
                            expect(error.localizedDescription).to(equal("passwordless_start_failed"))
                            done()
                        })
                    }
                }
            } //END SMS passwordless

            describe("start email passwordless authentication") {

                let email = "support@auth0.com"

                it("should send email") {
                    api.allowStartPasswordlessWithParameters([
                        "email": email,
                        "connection": "email",
                        "send": "code"
                        ])
                    waitUntil { done in
                        client.startPasswordless(withEmail: email, success: { done() }, failure: { _ in fail("Should not have failed") })
                    }
                }

                it("should call failure callback with error") {
                    api.failForRoute(.StartPasswordless,
                        parameters: [
                            "email": email,
                        ],
                        message: "passwordless_start_failed")
                    waitUntil { done in
                        client.startPasswordless(withEmail: email, success: { fail("Should have failed") }, failure: { error in
                            expect(error.localizedDescription).to(equal("passwordless_start_failed"))
                            done()
                        })
                    }
                }
            } //END Email passwordless

            describe("social authentication") {

                var credentials: A0IdentityProviderCredentials!

                beforeEach {
                    credentials = A0IdentityProviderCredentials(accessToken: SOCIAL_TOKEN)
                }

                it("should login with social credentials") {
                    api.allowSocialLoginWithParameters([
                        "access_token": SOCIAL_TOKEN,
                        "connection": "facebook",
                        "scope": "openid offline_access"
                    ])
                    api.allowTokenInfoForToken(JWT)
                    waitUntil { done in
                        client.authenticate(withSocialConnectionName: A0StrategyNameFacebook,
                            credentials: credentials,
                            parameters: nil,
                            success: {_, _ in done() },
                            failure: {_ in fail("Should not have failed")})
                    }
                }

                it("should not override connection name specified as a method parameter") {
                    api.allowSocialLoginWithParameters([
                        "access_token": SOCIAL_TOKEN,
                        "connection": "facebook",
                        "scope": "openid offline_access"
                        ])
                    api.allowTokenInfoForToken(JWT)
                    let parameters = A0AuthParameters.newDefaultParams()
                    parameters["connection"] = "invalid connection"
                    waitUntil { done in
                        client.authenticate(withSocialConnectionName: "facebook",
                            credentials: credentials,
                            parameters: parameters,
                            success: {_, _ in done() },
                            failure: {_ in fail("Should not have failed")})
                    }
                }

                it("should login with access token in parameters") {
                    let parameters = A0AuthParameters.newDefaultParams()
                    let accessToken = "AnotherToken"
                    parameters.accessToken = accessToken
                    api.allowSocialLoginWithParameters([
                        "access_token": SOCIAL_TOKEN,
                        "connection": "facebook",
                        "scope": "openid offline_access",
                        "main_access_token": accessToken,
                    ])
                    api.allowTokenInfoForToken(JWT)
                    waitUntil { done in
                        client.authenticate(withSocialConnectionName: A0StrategyNameFacebook,
                            credentials: credentials,
                            parameters: parameters,
                            success: {_, _ in done() },
                            failure: {_ in fail("Should not have failed")})
                    }
                }

                it("should login with extra information") {
                    credentials = A0IdentityProviderCredentials(accessToken: SOCIAL_TOKEN, extraInfo: [
                        A0StrategySocialTokenSecretParameter: "SECRET",
                        A0StrategySocialUserIdParameter: "USERID",
                    ])
                    api.allowSocialLoginWithParameters([
                        "access_token": SOCIAL_TOKEN,
                        "connection": "twitter",
                        "scope": "openid offline_access",
                        "access_token_secret": "SECRET",
                        "user_id": "USERID",
                    ])
                    api.allowTokenInfoForToken(JWT)
                    waitUntil { done in
                        client.authenticate(withSocialConnectionName: A0StrategyNameTwitter,
                            credentials: credentials,
                            parameters: nil,
                            success: {_, _ in done() },
                            failure: {_ in fail("Should not have failed") })
                    }
                }

                it("should call callback on failure with error") {
                    api.failForRoute(.SocialLogin,
                        parameters: [
                            "access_token": SOCIAL_TOKEN,
                        ],
                        message: "invalid_social_login")
                    waitUntil { done in
                        client.authenticate(withSocialConnectionName: A0StrategyNameWeibo,
                            credentials: credentials,
                            parameters: nil,
                            success: { _, _ in fail("Should have failed") },
                            failure: { error in
                                done()
                            })
                    }
                }
            } //END Social Login

            describe("Delegation") {

                it("should return a new jwt with another jwt") {
                    api.allowDelegationWithParameters([
                        "id_token": JWT,
                        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                        "client_id": CLIENT_ID,
                        "scope": "openid offline_access",
                    ])
                    waitUntil { done in
                        client.fetchNewIdToken(withIdToken: JWT,
                            parameters: nil,
                            success: { token in
                                done()
                            },
                            failure: { _ in fail("Should not have failed") })
                    }
                }

                it("should return a new jwt with refresh token") {
                    api.allowDelegationWithParameters([
                        "refresh_token": REFRESH_TOKEN,
                        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                        "client_id": CLIENT_ID,
                        "scope": "openid offline_access",
                        ])

                    waitUntil { done in
                        client.fetchNewIdToken(withRefreshToken: REFRESH_TOKEN,
                            parameters: nil,
                            success: { token in
                                done()
                            },
                            failure: { _ in fail("Should not have failed") })
                    }
                }

                it("should return a new jwt with parameters") {
                    api.allowDelegationWithParameters([
                        "id_token": JWT,
                        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                        "client_id": CLIENT_ID,
                        "scope": "openid offline_access",
                        "key": "value",
                    ])
                    let parameters = A0AuthParameters.new(with: ["key": "value"])
                    waitUntil { done in
                        client.fetchNewIdToken(withIdToken: JWT,
                            parameters: parameters,
                            success: { token in
                                done()
                            },
                            failure: { _ in fail("Should not have failed") })
                    }
                }

                it("should return a delegation info with parameters") {
                    api.allowDelegationWithParameters([
                        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                        "client_id": CLIENT_ID,
                        "scope": "openid offline_access",
                        "key": "value",
                    ])
                    let parameters = A0AuthParameters.new(with: ["key": "value"])
                    waitUntil { done in
                        client.fetchDelegationToken(with: parameters,
                            success: { info in
                                expect(info).notTo(beEmpty())
                                done()
                            },
                            failure: { _ in fail("Should not have failed") })
                    }
                }

                it("should call failure callback with error when using jwt") {
                    let errorMessage = "invalid_delegation";
                    api.failForRoute(.Delegation, parameters: ["id_token": JWT], message: errorMessage)
                    waitUntil { done in
                        client.fetchNewIdToken(withIdToken: JWT,
                            parameters: nil,
                            success: { _ in fail("Should have failed") },
                            failure: { error in
                                expect(error.localizedDescription).to(equal(errorMessage))
                                done()
                            })
                    }
                }

                it("should return a new jwt with refreshToken and parameters") {
                    api.allowDelegationWithParameters([
                        "refresh_token": REFRESH_TOKEN,
                        "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
                        "client_id": CLIENT_ID,
                        "scope": "openid offline_access",
                        "key": "value",
                        ])

                    waitUntil { done in
                        let parameters = A0AuthParameters.new(with: ["key": "value"])
                        client.fetchNewIdToken(withRefreshToken: REFRESH_TOKEN,
                            parameters: parameters,
                            success: { token in
                                done()
                            },
                            failure: { _ in fail("Should not have failed") })
                    }
                }

                it("should call failure callback with error when using refresh token") {
                    let errorMessage = "invalid_delegation"
                    api.failForRoute(.Delegation, parameters: ["refresh_token": REFRESH_TOKEN], message: errorMessage)
                    waitUntil { done in
                        client.fetchNewIdToken(withRefreshToken: REFRESH_TOKEN,
                            parameters: nil,
                            success: { _ in
                                fail("Should have failed")
                            },
                            failure: { error in
                                expect(error.localizedDescription).to(equal(errorMessage))
                                done()
                            })
                    }
                }

                it("should call failure callback with error") {
                    let errorMessage = "invalid_delegation"
                    api.failForRoute(.Delegation, parameters: ["key": "value"], message: errorMessage)
                    let parameters = A0AuthParameters.new(with: ["key": "value"])

                    waitUntil { done in
                        client.fetchDelegationToken(with: parameters,
                            success: { _ in fail("Should have failed") },
                            failure: { error in
                                expect(error.localizedDescription).to(equal(errorMessage))
                                done()
                            })
                    }
                }
            } //END Delegation
        }
    }
}
