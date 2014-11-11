//
//  HomeViewController.swift
//  SwiftSample
//
//  Created by Hernan Zalazar on 10/2/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let keychain = MyApplication.sharedInstance.keychain
        let idToken = keychain.stringForKey("id_token")
        if (idToken != nil) {
            if (A0JWTDecoder.isJWTExpired(idToken)) {
                let refreshToken = keychain.stringForKey("refresh_token")
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                let success = {(token:A0Token!) -> () in
                    keychain.setString(token.idToken, forKey: "id_token")
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.performSegueWithIdentifier("showProfile", sender: self)
                }
                let failure = {(error:NSError!) -> () in
                    keychain.clearAll()
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                A0APIClient.sharedClient().fetchNewIdTokenWithRefreshToken(refreshToken, parameters: nil, success: success, failure: failure)
            } else {
                self.performSegueWithIdentifier("showProfile", sender: self)
            }
        }
    }

    @IBAction func showSignIn(sender: AnyObject) {
        let authController = A0LockViewController()
        authController.closable = true
        authController.onAuthenticationBlock = {(profile:A0UserProfile!, token:A0Token!) -> () in
            let keychain = MyApplication.sharedInstance.keychain
            keychain.setString(token.idToken, forKey: "id_token")
            keychain.setString(token.refreshToken, forKey: "refresh_token")
            keychain.setData(NSKeyedArchiver.archivedDataWithRootObject(profile), forKey: "profile")
            self.dismissViewControllerAnimated(true, completion: nil)
            self.performSegueWithIdentifier("showProfile", sender: self)
        }
        self.presentViewController(authController, animated: true, completion: nil)
    }

}
