//
//  Constants.swift
//  Auth0Cognito
//
//  Created by Martin Gontovnikas on 3/11/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

import Foundation

enum Constants : String {
    case AWSAccountID =  "442712471438"
    case CognitoPoolID = "us-east-1:e7f3d45f-f4d5-4800-9dd6-aef5c4df6c8e"
    case CognitoRoleAuth = "arn:aws:iam::442712471438:role/Cognito_Auth0Auth_DefaultRole"
    case IDPUrl = "samples.auth0.com"
    case CognitoRoleUnauth = ""
    



    var value: String {
        get {
            return self.rawValue
        }
    }

}
