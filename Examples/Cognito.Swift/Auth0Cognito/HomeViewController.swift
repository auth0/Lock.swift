//  HomeViewController.swift
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
        let authController = A0LockViewController()
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
