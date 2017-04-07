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

struct CountryCodes: Loggable {

    private var countryCodes: [CountryCode] = []
    var filter: String?

    init() {
        guard
            let url = bundleForLock().url(forResource: "passwordless_country_codes", withExtension: "plist"),
            let data = try? Data(contentsOf: url),
            let dict = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
            let codes = dict as? [[String: String]]
            else {
                self.logger.error("Unable to process country codes plist")
                return
        }

        codes.forEach {
            guard
                let code =  $0["code"],
                let phoneCode = $0["phone_code"],
                let localizedName = (Locale.current as NSLocale).displayName(forKey: .countryCode, value: code)
                else {
                    self.logger.error("There was a problem parsing the country codes data")
                    return
            }
            countryCodes.append(CountryCode(isoCode: code, phoneCode: "+" + phoneCode, localizedName: localizedName))
        }
    }

    func filteredData() -> [CountryCode] {
        guard let filter = self.filter?.lowercased(), !filter.isEmpty else { return self.countryCodes }
        return self.countryCodes.filter { $0.localizedName.lowercased().contains(filter) }
    }

    func countryCode(_ isoCode: String) -> CountryCode? {
        return self.countryCodes.filter { $0.isoCode == isoCode }.first
    }
}

struct CountryCode {
    let isoCode: String
    let phoneCode: String
    let localizedName: String
}
