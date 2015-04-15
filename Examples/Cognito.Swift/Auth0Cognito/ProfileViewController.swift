//  ProfileViewController.swift
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

class ProfileViewController: UIViewController {


    @IBOutlet var profileImage: UIImageView?
    @IBOutlet var welcomeLabel: UILabel?
    @IBOutlet weak var textValue: UITextField!
    
    
    var dataset : AWSCognitoDataset?

    override func viewDidLoad() {
        super.viewDidLoad()
        let keychain = MyApplication.sharedInstance.keychain
        let profileData:NSData! = keychain.dataForKey("profile")
        let profile = NSKeyedUnarchiver.unarchiveObjectWithData(profileData) as! A0UserProfile
        self.profileImage?.sd_setImageWithURL(profile.picture)
        self.welcomeLabel?.text = "Welcome \(profile.name)!"
        
        let cognitoSync = AWSCognito.defaultCognito()
        dataset = cognitoSync.openOrCreateDataset("MainDataset")
        
        getAndShowData()
    }
    
    func getAndShowData() {
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        dataset!.synchronize().continueWithBlock { (task) -> AnyObject! in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.textValue.text = self.dataset!.stringForKey("value")
                MBProgressHUD.hideHUDForView(self.view, animated: true)
            })
            return nil
        }
    }
    
    
    @IBAction func setStoredValue(sender: AnyObject) {
        dataset!.setString(self.textValue.text, forKey: "value")
        dataset!.synchronize().continueWithBlock { (task) -> AnyObject! in
            return nil
        }
    }
    
    
    @IBAction func getStoredValue(sender: AnyObject) {
        getAndShowData()
    }

}
