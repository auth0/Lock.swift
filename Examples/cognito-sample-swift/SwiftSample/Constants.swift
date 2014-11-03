//
//  Constants.swift
//  SwiftSample
//
//  Created by Martin Gontovnikas on 3/11/14.
//  Copyright (c) 2014 Auth0. All rights reserved.
//

import Foundation

enum Constants : String {
    case AWSAccountID =  "442712471438"
    case CognitoPoolID = "us-east-1:9c0ff46a-1492-4ac6-ae80-af9cd64b0e24"
    case CognitoRoleAuth = "arn:aws:iam::442712471438:role/Cognito_Auth0Auth_DefaultRole"
    case CognitoRoleUnauth = ""
    
    
    
    var value: String {
        get {
            return self.rawValue
        }
    }
    
}
