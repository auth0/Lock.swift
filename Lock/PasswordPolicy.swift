// PasswordPolicy.swift
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

public protocol PasswordPolicy {

    func on(password: String?) -> [RuleResult]

}

public struct Auth0PasswordPolicy: PasswordPolicy {

    let rules: [Rule]

    public func on(password: String?) -> [RuleResult] {
        return rules.map { $0.evaluate(on: password) }
    }

    public static var none: PasswordPolicy {
        return Auth0PasswordPolicy(rules: [withPassword(lengthInRange: 1..<Int.max)])
    }

    public static var low: PasswordPolicy {
        return Auth0PasswordPolicy(rules: [withPassword(lengthInRange: 6..<Int.max)])
    }

    public static var fair: PasswordPolicy {
        return Auth0PasswordPolicy(rules: [
            withPassword(lengthInRange: 8..<Int.max),
            AtLeastRule(minimum: 3, rules: [
                    withPassword(havingCharactersIn: .lowercaseLetterCharacterSet()),
                    withPassword(havingCharactersIn: .uppercaseLetterCharacterSet()),
                    withPassword(havingCharactersIn: .decimalDigitCharacterSet()),
                ]),
            ])
    }

    public static var good: PasswordPolicy {
        let specialCharacterSet = NSMutableCharacterSet.punctuationCharacterSet()
        specialCharacterSet.formUnionWithCharacterSet(.symbolCharacterSet())
        return Auth0PasswordPolicy(rules: [
            withPassword(lengthInRange: 8..<Int.max),
            AtLeastRule(minimum: 3, rules: [
                withPassword(havingCharactersIn: .lowercaseLetterCharacterSet()),
                withPassword(havingCharactersIn: .uppercaseLetterCharacterSet()),
                withPassword(havingCharactersIn: .decimalDigitCharacterSet()),
                withPassword(havingCharactersIn: specialCharacterSet),
                ]),
            ])
    }

    public static var excellent: PasswordPolicy {
        let specialCharacterSet = NSMutableCharacterSet.punctuationCharacterSet()
        specialCharacterSet.formUnionWithCharacterSet(.symbolCharacterSet())
        return Auth0PasswordPolicy(rules: [
            withPassword(lengthInRange: 10...128),
            AtLeastRule(minimum: 3, rules: [
                withPassword(havingCharactersIn: .lowercaseLetterCharacterSet()),
                withPassword(havingCharactersIn: .uppercaseLetterCharacterSet()),
                withPassword(havingCharactersIn: .decimalDigitCharacterSet()),
                withPassword(havingCharactersIn: specialCharacterSet),
                ]),
            withPassword(havingMaxConsecutiveRepeats: 2)
            ])
    }

}
