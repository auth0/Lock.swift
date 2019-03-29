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

        describe("keyboard type") {
            var input: InputField!
            var text: UITextField!

            beforeEach {
                input = InputField()
                text = input.textField
            }

            it("should assign email type") {
                input.type = .email
                expect(text.keyboardType) == UIKeyboardType.emailAddress
            }

            it("should assign username type") {
                input.type = .username
                expect(text.keyboardType) == UIKeyboardType.default
            }

            it("should assign emailOrUsername type") {
                input.type = .emailOrUsername
                expect(text.keyboardType) == UIKeyboardType.emailAddress
            }

            it("should assign password type") {
                input.type = .password
                expect(text.keyboardType) == UIKeyboardType.default
            }


            it("should assign phone type") {
                input.type = .phone
                expect(text.keyboardType) == UIKeyboardType.phonePad
            }

            it("should assign oneTimePassword type") {
                input.type = .oneTimePassword
                expect(text.keyboardType) == UIKeyboardType.decimalPad
            }

            it("should assign custom type") {
                input.type = .custom(name: "test", placeholder: "", icon: nil, keyboardType: .twitter, autocorrectionType: .no, secure: false, contentType: nil)
                expect(text.keyboardType) == UIKeyboardType.twitter
            }
        }

        describe("content type") {
            var input: InputField!
            var text: UITextField!

            beforeEach {
                input = InputField()
                text = input.textField
            }

            if #available(iOS 10.0, *) {
                it("should assign email type") {
                    input.type = .email
                    expect(text.textContentType) == UITextContentType.emailAddress
                }
            }

            if #available(iOS 11.0, *) {
                it("should assign username type") {
                    input.type = .username
                    expect(text.textContentType) == UITextContentType.username
                }
            }

            if #available(iOS 10.0, *) {
                it("should assign emailOrUsername type") {
                    input.type = .emailOrUsername
                    expect(text.textContentType) == UITextContentType.emailAddress
                }
            }

            if #available(iOS 11.0, *) {
                it("should assign password type") {
                    input.type = .password
                    expect(text.textContentType) == UITextContentType.password
                }
            }

            if #available(iOS 10.0, *) {
                it("should assign phone type") {
                    input.type = .phone
                    expect(text.textContentType) == UITextContentType.telephoneNumber
                }
            }

            #if swift(>=4.0)
                if #available(iOS 12.0, *) {
                    it("should assign oneTimePassword type") {
                        input.type = .oneTimePassword
                        expect(text.textContentType) == UITextContentType.oneTimeCode
                    }
                }
            #endif

            if #available(iOS 10.0, *) {
                it("should assign custom type") {
                    input.type = .custom(name: "test", placeholder: "", icon: nil, keyboardType: .default, autocorrectionType: .no, secure: false, contentType: .name)
                    expect(text.textContentType) == UITextContentType.name
                }
            }
        }
    }
}
