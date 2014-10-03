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
        let store = MyApplication.sharedInstance.store
        let idToken = store.stringForKey("id_token")
        if (idToken != nil) {
            if (A0JWTDecoder.isJWTExpired(idToken)) {
                let refreshToken = store.stringForKey("refresh_token")
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
                let success = {(token:A0Token!) -> () in
                    store.setString(token.idToken, forKey: "id_token")
                    store.synchronize()
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                    self.performSegueWithIdentifier("showProfile", sender: self)
                }
                let failure = {(error:NSError!) -> () in
                    store.removeAllItems()
                    store.synchronize()
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                }
                A0APIClient.sharedClient().delegationWithRefreshToken(refreshToken, parameters:nil, success:success, failure:failure)
            } else {
                self.performSegueWithIdentifier("showProfile", sender: self)
            }
        }
    }

    @IBAction func showSignIn(sender: AnyObject) {
        let authController = A0AuthenticationViewController()
        authController.closable = true
        authController.onAuthenticationBlock = {(profile:A0UserProfile!, token:A0Token!) -> () in
            let store = MyApplication.sharedInstance.store
            store.setString(token.idToken, forKey: "id_token")
            store.setString(token.refreshToken, forKey: "refresh_token")
            store.setData(NSKeyedArchiver.archivedDataWithRootObject(profile), forKey: "profile")
            store.synchronize()
            self.dismissViewControllerAnimated(true, completion: nil)
            self.performSegueWithIdentifier("showProfile", sender: self)
        }
        self.presentViewController(authController, animated: true, completion: nil)
    }

}
