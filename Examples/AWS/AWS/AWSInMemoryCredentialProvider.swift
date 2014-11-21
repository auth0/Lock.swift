// AWSInMemoryCredentialProvider.swift
//
// Copyright (c) 2014 Auth0 (http://auth0.com)
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

class AWSInMemoryCredentialProvider: NSObject, AWSCredentialsProvider {

    private(set) var accessKey: String
    private(set) var secretKey: String
    private(set) var sessionKey: String
    private(set) var expiration: NSDate

    init(accessKey: NSString, secretKey: NSString, sessionKey: String, expiration: NSDate) {
        self.accessKey = accessKey;
        self.secretKey = secretKey;
        self.sessionKey = sessionKey;
        self.expiration = expiration;
    }

    convenience init(credentials: [NSString: AnyObject!]) {
        let accessKey = credentials["AccessKeyId"] as String
        let secretKey = credentials["SecretAccessKey"] as String
        let sessionKey = credentials["SessionToken"] as String
        let expirationISO = credentials["Expiration"] as String
        let expiration = ISO8601DateFormatter().dateFromString(expirationISO)
        self.init(accessKey: accessKey, secretKey: secretKey, sessionKey: sessionKey, expiration: expiration)
    }
}
