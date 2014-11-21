//  ViewController.swift
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

class ViewController: UIViewController {

    @IBOutlet weak var firstStepLabel: UILabel!
    @IBOutlet weak var seconStepLabel: UILabel!
    @IBOutlet weak var thirdStepLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let idToken = A0SimpleKeychain().stringForKey("id_token")
        self.firstStepLabel.text = idToken == nil ? nil : "Auth0 JWT \(idToken)"
        if idToken == nil {
            self.showLogin()
        }
    }

    @IBAction func logout(sender: AnyObject) {
        A0SimpleKeychain().clearAll()
        self.showLogin()
        self.seconStepLabel.text = nil
        self.thirdStepLabel.text = nil
    }

    @IBAction func fetchFromFirebase(sender: AnyObject) {
        let button = sender as UIButton
        self.setInProgress(true, button: button)

        let client = A0APIClient.sharedClient()
        let jwt = A0SimpleKeychain().stringForKey("id_token")
        let parameters = A0AuthParameters.newWithDictionary([
            A0ParameterAPIType: "firebase",
            "id_token": jwt
            ])

        client.fetchDelegationTokenWithParameters(parameters,
            success: { (response) -> Void in
                let credentials = response as Dictionary<String, AnyObject>
                self.seconStepLabel.text = "AWS Creds \(credentials)"
                println("Obtained AWS credentials \(credentials)")
            },
            failure: { (error) -> Void in
                self.seconStepLabel.text = error.localizedDescription
                println("An error ocurred \(error)")
                self.setInProgress(false, button: button)
        })
    }

    func setInProgress(inProgress: Bool, button: UIButton) {
        if inProgress {
            button.enabled = false
            self.activityIndicator.startAnimating()
            self.activityIndicator.hidden = false
            self.seconStepLabel.text = nil
            self.thirdStepLabel.text = nil
        } else {
            button.enabled = true
            self.activityIndicator.stopAnimating()
        }
    }

    func showLogin() {
        let lock = A0LockViewController()
        lock.closable = false
        lock.onAuthenticationBlock = {(profile: A0UserProfile!, token: A0Token!) -> () in
            A0SimpleKeychain().setString(token.idToken, forKey: "id_token")
            self.dismissViewControllerAnimated(true, completion: nil)
            self.firstStepLabel.text = "Auth0 JWT \(token.idToken)"
            return;
        }
        self.presentViewController(lock, animated: true, completion: nil)
    }
}

