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

    var enabled: Bool { get set }
    var available: Bool { get }

    var onUpdate: (String, String) -> Void { get set }

    func login(callback: @escaping (Error?) -> Void)
    func store(withPolicy policy: [String: Any]?, identifier: String?, callback: @escaping (Error?) -> Void)
}

public class OnePassword: PasswordManager {

    /// A Boolean value indicating whether the password manager is enabled.
    public var enabled: Bool = true

    /// The text identifier to use with the password manager to identify which credentials to use.
    public var appIdentifier: String

    /// The title to be displayed when creating a new password manager entry.
    public var displayName: String

    weak var controller: UIViewController?

    public init() {
        self.appIdentifier = Bundle.main.bundleIdentifier.verbatim()
        self.displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName").verbatim()
    }

    var available: Bool {
        return self.enabled && OnePasswordExtension.shared().isAppExtensionAvailable()
    }

    var onUpdate: (String, String) -> Void = { _ in }

    func login(callback: @escaping (Error?) -> Void) {
        guard let controller = self.controller else { return }
        OnePasswordExtension.shared().findLogin(forURLString: self.appIdentifier, for: controller, sender: nil) { (result, error) in
            guard error == nil else {
                return callback(error)
            }
            self.handleResut(result)
            callback(nil)
        }
    }

    func store(withPolicy policy: [String: Any]?, identifier: String?, callback: @escaping (Error?) -> Void) {
        guard let controller = self.controller else { return }
        var loginDetails: [String: String] = [ AppExtensionTitleKey: self.displayName ]
        loginDetails[AppExtensionUsernameKey] = identifier
        OnePasswordExtension.shared().storeLogin(forURLString: self.appIdentifier, loginDetails: loginDetails, passwordGenerationOptions: policy, for: controller, sender: nil) { (result, error) in
            guard error == nil else {
                return callback(error)
            }
            self.handleResut(result)
            callback(nil)
        }
    }

    private func handleResut(_ dict: [AnyHashable : Any]?) {
        guard let username = dict?[AppExtensionUsernameKey] as? String, let password = dict?[AppExtensionPasswordKey] as? String else { return }
        self.onUpdate(username, password)
    }
}
