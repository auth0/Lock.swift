//
//  HomeViewController.swift
//  SwiftSample
//
//  Created by Hernan Zalazar on 10/2/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    let loginManager = MyApplication.sharedInstance.loginManager

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let success = {() -> () in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            self.performSegueWithIdentifier("showProfile", sender: self)
        }
        let failure = {(error:NSError!) -> () in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            return
        }
        
        self.loginManager.resumeLogin(success, failure)
        
    }

    @IBAction func showSignIn(sender: AnyObject) {
        let authController = A0AuthenticationViewController()
        authController.closable = true
        authController.onAuthenticationBlock = {(profile:A0UserProfile!, token:A0Token!) -> () in
            let loginManager = MyApplication.sharedInstance.loginManager
            
            let success = {() -> () in
                self.dismissViewControllerAnimated(true, completion: nil)
                self.performSegueWithIdentifier("showProfile", sender: self)
            }
            let failure = {(error: NSError!) -> () in
                NSLog("Error logging the user in %s", error!.description);
            }
            
            self.loginManager.completeLogin(token, profile, success, failure)


        }
        self.presentViewController(authController, animated: true, completion: nil)
    }

}
