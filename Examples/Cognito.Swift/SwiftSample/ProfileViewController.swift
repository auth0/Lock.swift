//
//  ProfileViewController.swift
//  SwiftSample
//
//  Created by Hernan Zalazar on 10/2/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

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
        let profile:A0UserProfile = NSKeyedUnarchiver.unarchiveObjectWithData(profileData) as A0UserProfile
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
