//
//  LoginManager.swift
//  SwiftSample
//
//  Created by Martin Gontovnikas on 3/11/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

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
                keychain.setString(token.accessToken, forKey: "acess_token")
        keychain.setString(token.refreshToken, forKey: "refresh_token")
        keychain.setData(NSKeyedArchiver.archivedDataWithRootObject(profile), forKey: "profile")
        doAmazonLogin(token.accessToken, success, failure);
    }
    
    func doAmazonLogin(idToken: String, success : () -> (), _ failure : (NSError) -> ()) {
        self.provider.logins = ["auth0-oidc-test.herokuapp.com": idToken]
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
        let accessToken = keychain.stringForKey("acess_token")
        if (idToken != nil) {
            if (A0JWTDecoder.isJWTExpired(idToken)) {
                let refreshToken = keychain.stringForKey("refresh_token")
                let refreshOk = {(token:A0Token!) -> () in
                    keychain.setString(token.idToken, forKey: "id_token")
                    self.doAmazonLogin(token.accessToken, success, failure);
                }
                let refreshFail = {(error:NSError!) -> () in
                    keychain.clearAll()
                    failure(error)
                }
                A0APIClient.sharedClient().fetchNewIdTokenWithRefreshToken(refreshToken, parameters: nil, success: refreshOk, failure: refreshFail)
            } else {
                doAmazonLogin(accessToken, success, failure);
            }
        } else {
            let error = NSError(domain: "com.auth0", code: 0, userInfo: [NSLocalizedDescriptionKey: NSLocalizedString("Something went wrong", comment: "This is an error")])
            failure(error)
        }
    }

}