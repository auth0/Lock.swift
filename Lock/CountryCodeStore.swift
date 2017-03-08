// CountryCodeStore.swift
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

struct CountryCodeStore {

    var countryCodes: [CountryCode] = []

    init() {
        guard
            let url = bundleForLock().url(forResource: "passwordless_sms_countries", withExtension: "json"),
            let jsonData = try? Data(contentsOf: url),
            let jsonResult = try? JSONSerialization.jsonObject(with: jsonData) as! [String: String]
            else { return }

        countryCodes = jsonResult.flatMap { key, value in
            let name = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: key)
            return CountryCode(id: key, prefix: value, name: name!)
            }.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == ComparisonResult.orderedAscending }
    }

    func countryCode(forId id: String) -> CountryCode {
        return self.countryCodes.filter { $0.id == id }.first!
    }
}

struct CountryCode {
    let id: String
    let prefix: String
    let name: String
}
