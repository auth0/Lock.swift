// CustomTextField.swift
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

public struct CustomTextField {

    let name: String
    let placeholder: String
    let defaultValue: String?
    let storage: UserStorage
    let icon: LazyImage?
    let keyboardType: UIKeyboardType
    let autocorrectionType: UITextAutocorrectionType
    let autocapitalizationType: UITextAutocapitalizationType
    let secure: Bool
    let hidden: Bool
    let contentType: UITextContentType?
    let validation: (String?) -> Error?

    public init(name: String, placeholder: String, defaultValue: String? = nil, storage: UserStorage = .userMetadata, icon: LazyImage? = nil, keyboardType: UIKeyboardType = .default, autocorrectionType: UITextAutocorrectionType = .default, autocapitalizationType: UITextAutocapitalizationType = .none, secure: Bool = false, hidden: Bool = false, contentType: UITextContentType? = nil, validation: @escaping (String?) -> Error? = nonEmpty) {
        self.name = name
        self.placeholder = placeholder
        self.defaultValue = defaultValue
        self.icon = icon
        self.keyboardType = keyboardType
        self.autocorrectionType = autocorrectionType
        self.autocapitalizationType = autocapitalizationType
        self.secure = secure
        self.hidden = hidden
        self.contentType = contentType
        self.validation = validation
        self.storage = storage
    }

    var type: InputField.InputType {
        return .custom(name: name, placeholder: placeholder, defaultValue: defaultValue, storage: storage, icon: icon, keyboardType: keyboardType, autocorrectionType: autocorrectionType, autocapitalizationType: autocapitalizationType, secure: secure, hidden: hidden, contentType: contentType)
    }
}

public func nonEmpty(_ value: String?) -> Error? {
    guard let username = value?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), !username.isEmpty else { return InputValidationError.mustNotBeEmpty }
    return nil
}
