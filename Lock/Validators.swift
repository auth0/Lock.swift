// Validators.swift
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

protocol InputValidator {
    func validate(_ value: String?) -> Error?
}

public class PhoneValidator: InputValidator {
    let predicate: NSPredicate

    public init() {
        let regex = "^[0-9]{8,15}$"
        self.predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    }

    func validate(_ value: String?) -> Error? {
        guard let email = value?.trimmed, !email.isEmpty else { return InputValidationError.mustNotBeEmpty }
        guard self.predicate.evaluate(with: email) else { return InputValidationError.notAPhoneNumber }
        return nil
    }
}

public class OneTimePasswordValidator: InputValidator {
    func validate(_ value: String?) -> Error? {
        guard let value = value?.trimmed, !value.isEmpty else { return InputValidationError.mustNotBeEmpty }
        #if swift(>=3.2)
            guard value.count > 3, value.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else { return InputValidationError.notAOneTimePassword }
        #else
            guard value.characters.count > 3, value.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil else { return InputValidationError.notAOneTimePassword }
        #endif
        return nil
    }
}

public class NonEmptyValidator: InputValidator {
    func validate(_ value: String?) -> Error? {
        guard let value = value?.trimmed, !value.isEmpty else { return InputValidationError.mustNotBeEmpty }
        return nil
    }
}

public class UsernameValidator: InputValidator {

    let invalidSet: CharacterSet?
    let range: CountableClosedRange<Int>
    let emailValidator = EmailValidator()

    var min: Int { return self.range.lowerBound }
    var max: Int { return self.range.upperBound }

    public init() {
        self.range = 1...Int.max
        self.invalidSet = nil
    }

    public init(withLength range: CountableClosedRange<Int>, characterSet: CharacterSet) {
        self.invalidSet = characterSet
        self.range = range
    }

    func validate(_ value: String?) -> Error? {
        guard let username = value?.trimmed, !username.isEmpty else { return InputValidationError.mustNotBeEmpty }
        #if swift(>=3.2)
        guard self.range ~= username.count else { return self.invalidSet == nil ? InputValidationError.mustNotBeEmpty : InputValidationError.notAUsername }
        #else
        guard self.range ~= username.characters.count else { return self.invalidSet == nil ? InputValidationError.mustNotBeEmpty : InputValidationError.notAUsername }
        #endif
        guard let characterSet = self.invalidSet else { return nil }
        guard username.rangeOfCharacter(from: characterSet) == nil else { return InputValidationError.notAUsername }
        guard self.emailValidator.validate(username) != nil else { return InputValidationError.notAUsername }
        return nil
    }

    public static var auth0: CharacterSet {
        let set = NSMutableCharacterSet()
        set.formUnion(with: CharacterSet.alphanumerics)
        set.addCharacters(in: "_.-!#$'^`~@+")
        return set.inverted
    }
}

public class EmailValidator: InputValidator {
    let predicate: NSPredicate

    public init() {
        let regex = "[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\.[A-Za-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?\\.)+[A-Za-z0-9](?:[A-Za-z0-9-]*[A-Za-z0-9])?"
        self.predicate = NSPredicate(format: "SELF MATCHES %@", regex)
    }

    func validate(_ value: String?) -> Error? {
        guard let email = value?.trimmed, !email.isEmpty else { return InputValidationError.mustNotBeEmpty }
        guard self.predicate.evaluate(with: email) else { return InputValidationError.notAnEmailAddress }
        return nil
    }
}

protocol PasswordPolicyValidatorDelegate: class {
    func update(withRules rules: [RuleResult])
}

public class PasswordPolicyValidator: InputValidator {
    let policy: PasswordPolicy
    weak var delegate: PasswordPolicyValidatorDelegate?

    public init(policy: PasswordPolicy) {
        self.policy = policy
    }

    func validate(_ value: String?) -> Error? {
        let result = self.policy.on(value)
        self.delegate?.update(withRules: result)
        let valid = result.allSatisfy { $0.valid }
        guard !valid else { return nil }
        return InputValidationError.passwordPolicyViolation(result: result.filter { !$0.valid })
    }
}

private extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
