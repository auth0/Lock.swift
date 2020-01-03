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
                input.type = .custom(name: "test", placeholder: "", defaultValue: nil, storage: .userMetadata, icon: nil, keyboardType: .twitter, autocorrectionType: .no, autocapitalizationType: .none, secure: false, hidden: false, contentType: nil)
                expect(text.keyboardType) == UIKeyboardType.twitter
            }
        }

        describe("autocorrect type") {
            var input: InputField!
            var text: UITextField!

            beforeEach {
                input = InputField()
                text = input.textField
            }

            it("should assign email type") {
                input.type = .email
                expect(text.autocorrectionType) == .no
            }

            it("should assign username type") {
                input.type = .username
                expect(text.autocorrectionType) == .no
            }

            it("should assign emailOrUsername type") {
                input.type = .emailOrUsername
                expect(text.autocorrectionType) == .no
            }

            it("should assign password type") {
                input.type = .password
                expect(text.autocorrectionType) == .no
            }

            it("should assign phone type") {
                input.type = .phone
                expect(text.autocorrectionType) == .no
            }

            it("should assign oneTimePassword type") {
                input.type = .oneTimePassword
                expect(text.autocorrectionType) == .no
            }

            it("should assign custom type") {
                input.type = .custom(name: "test", placeholder: "", defaultValue: nil, storage: .userMetadata, icon: nil, keyboardType: .default, autocorrectionType: .yes, autocapitalizationType: .none, secure: false, hidden: false, contentType: nil)
                expect(text.autocorrectionType) == .yes
            }
        }

        describe("autocapitalization type") {
            var input: InputField!
            var text: UITextField!

            beforeEach {
                input = InputField()
                text = input.textField
            }

            it("should assign email type") {
                input.type = .email
                expect(text.autocapitalizationType) == UITextAutocapitalizationType.none
            }

            it("should assign username type") {
                input.type = .username
                expect(text.autocapitalizationType) == UITextAutocapitalizationType.none
            }

            it("should assign emailOrUsername type") {
                input.type = .emailOrUsername
                expect(text.autocapitalizationType) == UITextAutocapitalizationType.none
            }

            it("should assign password type") {
                input.type = .password
                expect(text.autocapitalizationType) == UITextAutocapitalizationType.none
            }

            it("should assign phone type") {
                input.type = .phone
                expect(text.autocapitalizationType) == UITextAutocapitalizationType.none
            }

            it("should assign oneTimePassword type") {
                input.type = .oneTimePassword
                expect(text.autocapitalizationType) == UITextAutocapitalizationType.none
            }

            it("should assign custom type") {
                input.type = .custom(name: "test", placeholder: "", defaultValue: nil, storage: .userMetadata, icon: nil, keyboardType: .default, autocorrectionType: .default, autocapitalizationType: .words, secure: false, hidden: false, contentType: nil)
                expect(text.autocapitalizationType) == .words
            }
        }

        describe("default value") {
            var input: InputField!
            var text: UITextField!

            beforeEach {
                input = InputField()
                text = input.textField
            }

            it("should assign email value") {
                input.type = .email
                expect(text.text?.isEmpty ?? true) == true
            }

            it("should assign username value") {
                input.type = .username
                expect(text.text?.isEmpty ?? true) == true
            }

            it("should assign emailOrUsername value") {
                input.type = .emailOrUsername
                expect(text.text?.isEmpty ?? true) == true
            }

            it("should assign password value") {
                input.type = .password
                expect(text.text?.isEmpty ?? true) == true
            }

            it("should assign phone value") {
                input.type = .phone
                expect(text.text?.isEmpty ?? true) == true
            }

            it("should assign oneTimePassword value") {
                input.type = .oneTimePassword
                expect(text.text?.isEmpty ?? true) == true
            }

            it("should assign custom value") {
                input.type = .custom(name: "test", placeholder: "", defaultValue: "Default Value", storage: .userMetadata, icon: nil, keyboardType: .default, autocorrectionType: .default, autocapitalizationType: .none, secure: true, hidden: false, contentType: nil)
                expect(text.text) == "Default Value"
            }
        }

        describe("secure value") {
            var input: InputField!
            var text: UITextField!

            beforeEach {
                input = InputField()
                text = input.textField
            }

            it("should assign email value") {
                input.type = .email
                expect(text.isSecureTextEntry) == false
            }

            it("should assign username value") {
                input.type = .username
                expect(text.isSecureTextEntry) == false
            }

            it("should assign emailOrUsername value") {
                input.type = .emailOrUsername
                expect(text.isSecureTextEntry) == false
            }

            it("should assign password value") {
                input.type = .password
                expect(text.isSecureTextEntry) == true
            }

            it("should assign phone value") {
                input.type = .phone
                expect(text.isSecureTextEntry) == false
            }

            it("should assign oneTimePassword value") {
                input.type = .oneTimePassword
                expect(text.isSecureTextEntry) == false
            }

            it("should assign custom value") {
                input.type = .custom(name: "test", placeholder: "", defaultValue: nil, storage: .userMetadata, icon: nil, keyboardType: .default, autocorrectionType: .default, autocapitalizationType: .words, secure: true, hidden: false, contentType: nil)
                expect(text.isSecureTextEntry) == true
            }
        }

        describe("hidden value") {
            var input: InputField!

            beforeEach {
                input = InputField()
            }

            it("should assign email value") {
                input.type = .email
                expect(input.isHidden) == false
            }

            it("should assign username value") {
                input.type = .username
                expect(input.isHidden) == false
            }

            it("should assign emailOrUsername value") {
                input.type = .emailOrUsername
                expect(input.isHidden) == false
            }

            it("should assign password value") {
                input.type = .password
                expect(input.isHidden) == false
            }

            it("should assign phone value") {
                input.type = .phone
                expect(input.isHidden) == false
            }

            it("should assign oneTimePassword value") {
                input.type = .oneTimePassword
                expect(input.isHidden) == false
            }

            it("should assign custom value") {
                input.type = .custom(name: "test", placeholder: "", defaultValue: nil, storage: .userMetadata, icon: nil, keyboardType: .default, autocorrectionType: .default, autocapitalizationType: .words, secure: false, hidden: true, contentType: nil)
                expect(input.isHidden) == true
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
                    input.type = .custom(name: "test", placeholder: "", defaultValue: nil, storage: .userMetadata, icon: nil, keyboardType: .default, autocorrectionType: .no, autocapitalizationType: .none, secure: false, hidden: false, contentType: .name)
                    expect(text.textContentType) == UITextContentType.name
                }
            }
        }
    }
}
