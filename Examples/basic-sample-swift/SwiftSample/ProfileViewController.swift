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

    override func viewDidLoad() {
        super.viewDidLoad()
        let keychain = MyApplication.sharedInstance.keychain
        let profileData:NSData! = keychain.dataForKey("profile")
        let profile:A0UserProfile = NSKeyedUnarchiver.unarchiveObjectWithData(profileData) as A0UserProfile
        self.profileImage?.sd_setImageWithURL(profile.picture)
        self.welcomeLabel?.text = "Welcome \(profile.name)!"
    }

    @IBAction func callAPI(sender: AnyObject) {
        let info = NSBundle.mainBundle().infoDictionary!
        let urlString = info["SampleAPIBaseURL"] as NSString
        let request = NSURLRequest(URL: NSURL(string: urlString)!)
        let operation = AFHTTPRequestOperation(request: request)
        operation.setCompletionBlockWithSuccess({ (operation, responseObject) -> Void in
            self.showMessage("We got the secured data successfully")
        }, failure: { (operation, error) -> Void in
            self.showMessage("Please download the API seed so that you can call it.")
        })
        operation.start()
    }

    private func showMessage(message: NSString) {
        let alert = UIAlertView(title: message, message: nil, delegate: nil, cancelButtonTitle: "OK")
        alert.show()
    }
}
