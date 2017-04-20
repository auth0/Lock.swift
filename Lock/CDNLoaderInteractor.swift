// CDNLoaderInteractor.swift
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

typealias JSONObject = [String: Any]
typealias JSONArray = [JSONObject]

struct CDNLoaderInteractor: RemoteConnectionLoader, Loggable {

    let url: URL

    init(baseURL: URL, clientId: String) {
        self.url = URL(string: "client/\(clientId).js", relativeTo: cdnURL(from: baseURL))!
    }

    func load(_ callback: @escaping (UnrecoverableError?, Connections?) -> Void) {
        self.logger.info("Loading client info from \(self.url)")
        let task = URLSession.shared.dataTask(with: self.url, completionHandler: { (data, response, error) in
            guard error?._code != NSURLErrorTimedOut else { return callback(.connectionTimeout, nil) }
            guard error == nil else {
                self.logger.error("Failed to load with error \(error!)")
                return callback(.requestIssue, nil)
            }

            guard let response = response as? HTTPURLResponse else {
                self.logger.error("Response was not NSHTTURLResponse")
                return callback(.requestIssue, nil)
            }

            let payload: String?
            if let data = data {
                payload = String(data: data, encoding: .utf8)
            } else {
                payload = nil
            }

            guard 200...299 ~= response.statusCode else {
                self.logger.error("HTTP response was not successful. HTTP \(response.statusCode) <\(payload ?? "No Body")>")
                guard response.statusCode != 403 else { return callback(.invalidClientOrDomain, nil) }
                return callback(.requestIssue, nil)
            }

            guard var jsonp = payload else {
                self.logger.error("HTTP response had no jsonp \(payload ?? "No Body")")
                return callback(.invalidClientOrDomain, nil)
            }

            self.logger.verbose("Received jsonp \(jsonp)")

            if let prefixRange = jsonp.range(of: "Auth0.setClient(") {
                jsonp.removeSubrange(prefixRange)
            }
            if let suffixRange = jsonp.range(of: ");") {
                jsonp.removeSubrange(suffixRange)
            }

            do {
                var connections = OfflineConnections()
                let json = try JSONSerialization.jsonObject(with: jsonp.data(using: String.Encoding.utf8)!, options: []) as? JSONObject
                self.logger.debug("Client configuration is \(json.verbatim())")
                let info = ClientInfo(json: json)
                if let auth0 = info.auth0 {
                    auth0.connections.forEach { connection in
                        let requiresUsername = connection.booleanValue(forKey: "requires_username")
                        connections.database(name: connection.name, requiresUsername: requiresUsername, usernameValidator: connection.usernameValidation, passwordValidator: PasswordPolicyValidator(policy: connection.passwordPolicy))
                    }
                }
                info.enterprise.forEach { strategy in
                    strategy.connections.forEach { connection in
                        let domains = connection.json["domain_aliases"] as? [String] ?? []
                        let template = AuthStyle.style(forStrategy: strategy.name, connectionName: connection.name)
                        let style = AuthStyle(name: domains.first ?? strategy.name, color: template.normalColor, withImage: template.image)
                        connections.enterprise(name: connection.name, domains: domains, style: style)
                    }
                }
                info.oauth2.forEach { strategy in
                    strategy.connections.forEach { connections.social(name: $0.name, style: AuthStyle.style(forStrategy: strategy.name, connectionName: $0.name)) }
                }
                info.passwordless.forEach { strategy in
                    strategy.connections.forEach {
                        if strategy.name == "email" {
                            connections.email(name: $0.name)
                        } else {
                            connections.sms(name: $0.name)
                        }
                    }
                }

                guard !connections.isEmpty else { return callback(.clientWithNoConnections, connections) }
                callback(nil, connections)
            } catch let e {
                self.logger.error("Failed to parse \(jsonp) with error \(e)")
                return callback(.invalidClientOrDomain, nil)
            }
        })
        task.resume()
    }
}

private struct ClientInfo {
    let json: JSONObject?

    var strategies: [StrategyInfo] {
        let list = json?["strategies"] as? JSONArray ?? []
        return list
            .map { StrategyInfo(json: $0) }
            .filter { $0 != nil }
            .map { $0! }
    }

    var auth0: StrategyInfo? { return strategies.filter({ $0.name == "auth0" }).first }

    var oauth2: [StrategyInfo] { return strategies.filter { $0.name != "auth0" && !passwordlessStrategyNames.contains($0.name) && !enterpriseStrategyNames.contains($0.name) } }

    var enterprise: [StrategyInfo] { return strategies.filter { $0.name != "auth0" && !passwordlessStrategyNames.contains($0.name) && enterpriseStrategyNames.contains($0.name) } }

    var passwordless: [StrategyInfo] { return strategies.filter { passwordlessStrategyNames.contains($0.name) } }

    let passwordlessStrategyNames = [
        "email",
        "sms"
    ]

    let enterpriseStrategyNames = [
        "google-apps",
        "google-openid",
        "office365",
        "waad",
        "adfs",
        "ad",
        "samlp",
        "pingfederate",
        "ip",
        "mscrm",
        "custom",
        "sharepoint"
    ]

    let enterpriseCredentialAuthNames = [
        "waad",
        "adfs",
        "ad"
    ]

}

private struct StrategyInfo {
    let json: JSONObject
    let name: String

    var connections: [ConnectionInfo] {
        let list = json["connections"] as? JSONArray ?? []
        return list
            .map { ConnectionInfo(json: $0) }
            .filter { $0 != nil }
            .map { $0! }
    }

    init?(json: JSONObject) {
        guard let name = json["name"] as? String else { return nil }
        self.json = json
        self.name = name
    }
}

private struct ConnectionInfo {

    let json: JSONObject
    let name: String

    func booleanValue(forKey key: String, defaultValue: Bool = false) -> Bool { return json[key] as? Bool ?? defaultValue }

    var usernameValidation: UsernameValidator {
        let validation = json["validation"] as? JSONObject
        let username = validation?["username"] as? JSONObject
        switch (username?["min"], username?["max"]) {
        case let (min as Int, max as Int):
            return UsernameValidator(withLength: min...max, characterSet: UsernameValidator.auth0)
        case let (minString as String, maxString as String):
            guard
                let min = Int(minString),
                let max = Int(maxString)
                else { return UsernameValidator() }
            return UsernameValidator(withLength: min...max, characterSet: UsernameValidator.auth0)
        default:
            return UsernameValidator()
        }
    }

    var passwordPolicy: PasswordPolicy {
        let name = (json["passwordPolicy"] as? String) ?? "none"
        guard let policy = PasswordPolicy.Auth0(rawValue: name) else { return .none }
        switch policy {
        case .excellent:
            return .excellent
        case .good:
            return .good
        case .fair:
            return .fair
        case .low:
            return .low
        case .none:
            return .none
        }
    }

    init?(json: JSONObject) {
        guard let name = json["name"] as? String else { return nil }
        self.json = json
        self.name = name
    }
}

private func cdnURL(from url: URL) -> URL {
    guard let host = url.host, host.hasSuffix(".auth0.com") else { return url }
    let components = host.components(separatedBy: ".")
    guard components.count == 4 else { return URL(string: "https://cdn.auth0.com")! }
    let region = components[1]
    return URL(string: "https://cdn.\(region).auth0.com")!
}
