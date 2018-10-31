//
//  AppDelegate.swift
//  LockApp
//
//  Created by Hernan Zalazar on 6/22/16.
//  Copyright © 2016 Auth0. All rights reserved.
//

import UIKit
import Lock
import Auth0

#if swift(>=4.2)
typealias A0RestorationHandler = UIUserActivityRestoring
#else
typealias A0RestorationHandler = Any
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [A0ApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [Auth0.A0URLOptionsKey : Any]) -> Bool {
        return Lock.resumeAuth(url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([A0RestorationHandler]?) -> Void) -> Bool {
        return Lock.continueAuth(using: userActivity)
    }
    
}

