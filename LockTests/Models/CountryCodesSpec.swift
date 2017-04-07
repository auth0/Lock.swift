// CountryCodesSpec.swift
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

class CountryCodesSpec: QuickSpec {

    override func spec() {

        var store: CountryCodes?

        describe("countrycode") {

            beforeEach {
                store = CountryCodes()
            }

            it("should return 229 countries") {
                expect(store?.filteredData().count) == 229
            }

            it("should filter countries to 1") {
                store?.filter = "United Kingdom"
                expect(store?.filteredData().count) == 1
            }

            it("should return no countries") {
                store?.filter = "ZZZZ"
                expect(store?.filteredData().count) == 0
            }

            it("should return entry for valid code") {
                let countryData = store?.countryCode("US")
                expect(countryData?.phoneCode) == "+1"
            }

            it("should return nil entry for invalid code") {
                let countryData = store?.countryCode("ZZ")
                expect(countryData).to(beNil())
            }
        }

    }

}
