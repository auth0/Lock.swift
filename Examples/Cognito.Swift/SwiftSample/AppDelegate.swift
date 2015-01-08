//
//  AppDelegate.swift
//  SwiftSample
//
//  Created by Hernan Zalazar on 10/2/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let fbAuthenticator = A0FacebookAuthenticator.newAuthenticatorWithDefaultPermissions()
        A0IdentityProviderAuthenticator.sharedInstance().registerAuthenticationProvider(fbAuthenticator)
        return true
    }

    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String, annotation: AnyObject?) -> Bool {
        return A0IdentityProviderAuthenticator.sharedInstance().handleURL(url, sourceApplication: sourceApplication)
    }

}

