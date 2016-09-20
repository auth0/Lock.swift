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

typealias JSONObject = [String: AnyObject]
typealias JSONArray = [JSONObject]

struct CDNLoaderInteractor: RemoteConnectionLoader, Loggable {

    let url: NSURL

    init(baseURL: NSURL, clientId: String) {
        self.url = NSURL(string: "client/\(clientId).js", relativeToURL: cdnURL(from: baseURL))!
    }

    func load(callback: Connections? -> ()) {
        self.logger.info("Loading client info from \(self.url)")
        let task = NSURLSession.sharedSession().dataTaskWithURL(self.url) { (data, response, error) in
            guard error == nil else {
                self.logger.error("Failed to load with error \(error!)")
                callback(nil)
                return
            }
            guard let response = response as? NSHTTPURLResponse else {
                self.logger.error("Response was not NSHTTURLResponse")
                return callback(nil)
            }

            let payload: String?
            if let data = data {
                payload = String(data: data, encoding: NSUTF8StringEncoding)
            } else {
                payload = nil
            }
            guard 200...299 ~= response.statusCode else {
                self.logger.error("HTTP response was not successful. HTTP \(response.statusCode) <\(payload ?? "No Body")>")
                return callback(nil)
            }

            guard var jsonp = payload else {
                self.logger.error("HTTP response had no jsonp \(payload ?? "No Body")")
                return callback(nil)
            }

            self.logger.verbose("Received jsonp \(jsonp)")

            if let prefixRange = jsonp.rangeOfString("Auth0.setClient(") {
                jsonp.removeRange(prefixRange)
            }
            if let suffixRange = jsonp.rangeOfString(");") {
                jsonp.removeRange(suffixRange)
            }

            do {
                var connections = OfflineConnections()
                let json = try NSJSONSerialization.JSONObjectWithData(jsonp.dataUsingEncoding(NSUTF8StringEncoding)!, options: []) as? JSONObject
                self.logger.debug("Client configuration is \(json)")
                let info = ClientInfo(json: json)
                if let auth0 = info.auth0, let connection = auth0.connections.first {
                    let requiresUsername = connection.booleanValue(forKey: "requires_username")
                    connections.database(name: connection.name, requiresUsername: requiresUsername, usernameValidator: connection.usernameValidation)
                }
                info.oauth2.forEach { strategy in
                    strategy.connections.forEach { connections.social(name: $0.name, style: AuthStyle.style(forStrategy: strategy.name, connectionName: $0.name)) }
                }
                callback(connections)
            } catch let e {
                self.logger.error("Failed to parse \(jsonp) with error \(e)")
                return callback(nil)
            }
        }
        task.resume()
    }
}

private struct ClientInfo {
    let json: JSONObject?

    var strategies: [StrategyInfo] {
        let list = json?["strategies"] as? JSONArray ?? []
        return list
            .filter { $0["name"] != nil }
            .map { StrategyInfo(json: $0) }
    }

    var auth0: StrategyInfo? { return strategies.filter({ $0.name == "auth0" }).first }

    var oauth2: [StrategyInfo] { return strategies.filter { $0.name != "auth0" && !passwordlessStrategyNames.contains($0.name) && !enterpriseStrategyNames.contains($0.name) } }

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
        "sharepoint",
    ]

}

private struct StrategyInfo {
    let json: JSONObject

    var name: String { return json["name"] as! String }

    var connections: [ConnectionInfo] {
        let list = json["connections"] as? JSONArray ?? []
        return list
            .filter { $0["name"] != nil }
            .map { ConnectionInfo(json: $0) }
    }
}

private struct ConnectionInfo {

    let json: JSONObject

    var name: String { return json["name"] as! String }

    func booleanValue(forKey key: String, defaultValue: Bool = false) -> Bool { return json[key] as? Bool ?? defaultValue }

    var usernameValidation: InputValidator {
        let validation = json["validation"] as? JSONObject
        let username = validation?["username"] as? JSONObject
        switch (username?["min"], username?["max"]) {
        case let (min as Int, max as Int):
            return UsernameValidator(range: min...max)
        case let (minString as String, maxString as String):
            guard
                let min = Int(minString),
                let max = Int(maxString)
                else { return UsernameValidator() }
            return UsernameValidator(range: min...max)
        default:
            return UsernameValidator()
        }
    }
}

private func cdnURL(from url: NSURL) -> NSURL {
    guard let host = url.host where host.hasSuffix(".auth0.com") else { return url }
    let components = host.componentsSeparatedByString(".")
    guard components.count == 4 else { return NSURL(string: "https://cdn.auth0.com")! }
    let region = components[1]
    return NSURL(string: "https://cdn.\(region).auth0.com")!
}
