// EmailValidatorSpec.swift
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

class EmailValidatorSpec: QuickSpec {

    override func spec() {

        var validator: EmailValidator { return EmailValidator() }

        ["", " ", "         ", "\n"].forEach { value in
            it("should consider \(String(describing: value)) an invalid email") {
                expect(validator.validate(value) as? InputValidationError) == .mustNotBeEmpty
            }
        }

        ["test@iana.org", "test@nominet.org.uk", "test@about.museum", "a@iana.org", "test@e.com", "test@iana.a", "123@iana.org", "test@123.com", "test.mail@server.co.uk"].forEach { value in
            it("should consider \(value!) a valid email") {
                expect(validator.validate(value)).to(beNil())
            }
        }

        ["test", "@", "test@", "@io", "@iana.org", ".test@iana.org", "test.@iana.org", "test..iana.org", "test_exa-mple.com", "test\\@test@iana.org", "test@-iana.org", "test@iana.org.", "test@iana..com"].forEach { value in
            it("should consider \(String(describing: value)) an invalid email") {
                expect(validator.validate(value) as? InputValidationError) == .notAnEmailAddress
            }
        }
    }

}

extension InputValidationError: Equatable {}

public func ==(lhs: InputValidationError, rhs: InputValidationError) -> Bool {
    return (lhs as NSError) == (rhs as NSError)
}
