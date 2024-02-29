//
//  UpdateAuthToken.swift
//  
//
//  Created by tristate on 14/05/18.
//  Copyright © 2019 tristate. All rights reserved.
//

import UIKit

class UpdateAuthToken: NSObject {
    
    func initWithdictData(requestData : Dictionary<String,Any>) {
        if requestData.keys.contains("auth_token"){
            APPData.userDefault.set(setDataInString(data: requestData["auth_token"] as AnyObject), forKey: APPData.UserDefaultKeys.AUTH_TOKEN)
        }
        if requestData.keys.contains("refresh_token"){
            APPData.userDefault.set(requestData["refresh_token"], forKey: APPData.UserDefaultKeys.REFRESH_TOKEN)
        }
    }
}
