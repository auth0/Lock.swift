// InputFieldSpec.swift
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

class InputFieldSpec: QuickSpec {

    override func spec() {

        describe("delegate") {

            var input: InputField!
            var text: UITextField!
            var didTextChange: Bool!
            var didReturn: Bool!
            var didBegin: Bool!
            var didEnd: Bool!

            beforeEach {
                didTextChange = false
                didReturn = false
                didBegin = false
                didEnd = false
                input = InputField()
                input.onReturn = { _ in didReturn = true }
                input.onTextChange = { _ in didTextChange = true }
                input.onBeginEditing = { _ in didBegin = true }
                input.onEndEditing = { _ in didEnd = true }
                text = UITextField()
                text.text = "test"
            }

            describe("delegate") {

                it("on return editing called") {
                    expect(input.textFieldShouldReturn(text)).to(beTrue())
                    expect(didReturn).to(beTrue())
                    expect(didTextChange).to(beTrue())
                }

                it("on begin editing called") {
                    input.textFieldDidBeginEditing(text)
                    expect(didBegin).to(beTrue())
                }

                it("on end editing called") {
                    input.textFieldDidEndEditing(text)
                    expect(didEnd).to(beTrue())
                }
            }

            describe("text change") {

                it("text updated") {
                    input.textChanged(text)
                    expect(didTextChange).to(beTrue())
                }

            }
            
        }
    }
}
