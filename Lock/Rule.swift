// Rule.swift
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

protocol Rule {
    func evaluate(on password: String?) -> RuleResult

}

public protocol RuleResult {
    var valid: Bool { get }
}

func withPassword(lengthInRange range: Range<Int>) -> Rule {
    return SimpleRule { range ~= $0.characters.count }
}

func withPassword(havingCharactersIn characterSet: NSCharacterSet) -> Rule {
    return SimpleRule { $0.rangeOfCharacterFromSet(characterSet) != nil }
}

func withPassword(havingMaxConsecutiveRepeats count: Int) -> Rule {
    return SimpleRule {
        let repeated = $0.characters.reduce([]) { (partial: [Character], character: Character) in
            guard partial.count <= count else { return partial }
            guard partial.contains(character) else { return [character] }
            return partial + [character]
        }
        return repeated.count <= count
    }
}

struct AtLeastRule: Rule {

    let minimum: Int
    let rules: [Rule]

    func evaluate(on password: String?) -> RuleResult {
        let results = rules.map { $0.evaluate(on: password) }
        let count = results.reduce(0) { $0 + ($1.valid ? 1 : 0) }
        return Result(valid: count >= minimum, inner: results)
    }

    struct Result: RuleResult {
        let valid: Bool
        let inner: [RuleResult]
    }
}

struct SimpleRule: Rule {

    let valid: (String) -> Bool

    func evaluate(on password: String?) -> RuleResult {
        guard let value = password else { return Result(valid: false) }
        return Result(valid: self.valid(value))
    }

    struct Result: RuleResult {
        let valid: Bool
    }
}
