// CustomField.swift
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

import Foundation

public struct CustomField {

    let name: String
    let placeholder: String
    let icon: LazyImage
    let keyboardType: UIKeyboardType
    let secure: Bool
    let validation: String? -> ErrorType?

    public init(name: String, placeholder: String, icon: LazyImage, keyboardType: UIKeyboardType = .Default, secure: Bool = false, validation: String? -> ErrorType? = nonEmpty) {
        self.name = name
        self.placeholder = placeholder
        self.icon = icon
        self.keyboardType = keyboardType
        self.secure = secure
        self.validation = validation
    }

    var type: InputField.InputType {
        return .Custom(name: name, placeholder: placeholder, icon: icon, keyboardType: keyboardType, secure: secure)
    }
}

private func nonEmpty(value: String?) -> ErrorType? {
    guard let username = value?.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()) where !username.isEmpty else { return InputValidationError.MustNotBeEmpty }
    return nil
}