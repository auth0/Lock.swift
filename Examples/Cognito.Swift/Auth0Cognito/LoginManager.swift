//  LoginManager.swift
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

import Foundation

class LoginManager {

    let provider : AWSCognitoCredentialsProvider
    
    init() {
        AWSLogger.defaultLogger().logLevel = AWSLogLevel.Verbose;
        self.provider = AWSCognitoCredentialsProvider.credentialsWithRegionType(AWSRegionType.USEast1, accountId: Constants.AWSAccountID.value, identityPoolId: Constants.CognitoPoolID.value, unauthRoleArn: Constants.CognitoRoleAuth.value, authRoleArn: Constants.CognitoRoleAuth.value);
        
        
        let configuration = AWSServiceConfiguration(region: AWSRegionType.USEast1, credentialsProvider: self.provider);
        AWSServiceManager.defaultServiceManager().setDefaultServiceConfiguration(configuration)
    }
    
    
    func completeLogin(token : A0Token, _ profile: A0UserProfile, _ success : () -> (), _ failure : (NSError) -> ()) {
        let keychain = MyApplication.sharedInstance.keychain

        keychain.setString(token.idToken, forKey: "id_token")
        keychain.setString(token.refreshToken, forKey: "refresh_token")
        keychain.setData(NSKeyedArchiver.archivedDataWithRootObject(profile), forKey: "profile")
        doAmazonLogin(token.idToken, success, failure);
    }
    
    func doAmazonLogin(idToken: String, _ success : () -> (), _ failure : (NSError) -> ()) {
        self.provider.logins = [Constants.IDPUrl.value: idToken]
        self.provider.getIdentityId().continueWithBlock { (task: BFTask!) -> AnyObject! in
            self.provider.refresh()
            if (task.error != nil) {
                failure(task.error);
            } else {
                success()
            }
            return nil
        }
    }
    
    func resumeLogin(success : () -> (), _ failure : (NSError) -> ()) {
        let keychain = MyApplication.sharedInstance.keychain

        let idToken = keychain.stringForKey("id_token")
        if (idToken != nil) {
            if (A0JWTDecoder.isJWTExpired(idToken)) {
                let refreshToken = keychain.stringForKey("refresh_token")
                let refreshOk = {(token:A0Token!) -> () in
                    keychain.setString(token.idToken, forKey: "id_token")
                    self.doAmazonLogin(token.idToken, success, failure);
                }
                let refreshFail = {(error:NSError!) -> () in
                    keychain.clearAll()
                    failure(error)
                }
                A0APIClient.sharedClient().fetchNewIdTokenWithRefreshToken(refreshToken, parameters: nil, success: refreshOk, failure: refreshFail)
            } else {
                doAmazonLogin(idToken, success, failure);
            }
        } else {
            let error = NSError(domain: "com.auth0", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Something went wrong", comment: "This is an error")])
            failure(error)
        }
    }

}