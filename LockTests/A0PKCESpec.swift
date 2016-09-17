// A0PKCESpec.swift
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

import Foundation
import Quick
import Nimble

class A0PKCESpec: QuickSpec {
    override func spec() {

        var pkce: A0PKCE!

        beforeEach {
            pkce = A0PKCE()
        }

        describe("code verifier") {
            it("should be base64 url-safe encoded") {
                var urlSafeBase64Set = CharacterSet.alphanumerics
                urlSafeBase64Set.formIntersection(CharacterSet.nonBaseCharacters.inverted)
                urlSafeBase64Set.insert(charactersIn: "-_")
                let set = urlSafeBase64Set.inverted
                expect(pkce.verifier.rangeOfCharacter(from: set)).to(beNil())
            }

            it("should have 43 characters") {
                expect(pkce.verifier.characters.count).to(equal(43))
            }
        }

        describe("code challenge") {
            it("should be base64 url-safe encoded") {
                var urlSafeBase64Set = CharacterSet.alphanumerics
                urlSafeBase64Set.formIntersection(CharacterSet.nonBaseCharacters.inverted)
                urlSafeBase64Set.insert(charactersIn: "-_")
                let set = urlSafeBase64Set.inverted
                expect(pkce.challenge.rangeOfCharacter(from: set)).to(beNil())
            }

            it("should have 43 characters") {
                expect(pkce.challenge.characters.count).to(equal(43))
            }

            it("should not be the same as the code verifier") {
                expect(pkce.challenge).notTo(equal(pkce.verifier))
            }

            it("should be a SHA246 hash of the code verifier") {
                let verifier = "dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk"
                let challenge = "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"
                pkce = A0PKCE(verifier: verifier)
                expect(pkce.verifier).to(equal(verifier))
                expect(pkce.challenge).to(equal(challenge))
            }

            it("should be created with method S256") {
                expect(pkce.method).to(equal("S256"))
            }
        }

        describe("authorization parameters") {
            var parameters: [String: String]!

            beforeEach {
                parameters = pkce.authorizationParameters
            }

            it("should include challenge") {
                expect(parameters["code_challenge"]).to(equal(pkce.challenge))
            }

            it("should include challenge method") {
                expect(parameters["code_challenge_method"]).to(equal(pkce.method))
            }

            it("should only contain challenge and method") {
                expect(Array(parameters.keys)).to(equal(["code_challenge", "code_challenge_method"]))
            }
        }

        describe("token parameters") {
            var parameters: [String: String]!

            beforeEach {
                parameters = pkce.tokenParameters(withAuthorizationCode: "CODE")
            }

            it("should include verifier") {
                expect(parameters["code_verifier"]).to(equal(pkce.verifier))
            }

            it("should include auth code") {
                expect(parameters["code"]).to(equal("CODE"))
            }

            it("should only contain auth code & verifier") {
                expect(Array(parameters.keys)).to(contain(["code", "code_verifier"]))
            }
        }

    }
}
