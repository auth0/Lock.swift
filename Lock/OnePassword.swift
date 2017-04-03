// OnePassword.swift
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

import Foundation

protocol PasswordManager {
    var fields: [String: InputField] { get set }

    func isAvailable() -> Bool
    func openManager(callback: @escaping ([String: InputField]?, Error?) -> Void)
}

class OnePassword: PasswordManager {

    let identifier: String
    weak var controller: UIViewController?

    var fields: [String: InputField] = [:]

    init(identifier: String, controller: UIViewController?) {
        self.identifier = identifier
        self.controller = controller
    }

    func isAvailable() -> Bool {
        return OnePasswordExtension.shared().isAppExtensionAvailable()
    }

    func openManager(callback: @escaping ([String: InputField]?, Error?) -> Void) {
        guard let controller = self.controller else { return }
        OnePasswordExtension.shared().findLogin(forURLString: self.identifier, for: controller, sender: nil) { (result, error) in
            guard error == nil else {
                return callback(nil, error)
            }
            guard let credentials = result as? [String: String] else {
                return callback(nil, nil)
            }

            self.fields[AppExtensionUsernameKey]?.text = credentials[AppExtensionUsernameKey]
            self.fields[AppExtensionPasswordKey]?.text = credentials[AppExtensionPasswordKey]

            callback(self.fields, nil)
        }
    }
}
