//
//  MyApplication.swift
//  SwiftSample
//
//  Created by Hernan Zalazar on 10/2/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

import UIKit

class MyApplication: NSObject {
    class var sharedInstance :MyApplication {
        struct Singleton {
            static let instance = MyApplication()
        }
        return Singleton.instance
    }

    let keychain: A0SimpleKeychain

    private override init() {
        keychain = A0SimpleKeychain(service: "Auth0")
    }
}
