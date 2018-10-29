//
//  AppDelegate.swift
//  LockApp
//
//  Created by Hernan Zalazar on 6/22/16.
//  Copyright © 2016 Auth0. All rights reserved.
//

import UIKit
import Lock

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return Lock.resumeAuth(url, options: options)
    }

    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return Lock.continueAuth(using: userActivity)
    }
    
}

