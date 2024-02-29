//
//  UserDataStr.swift
//  BillionsApp
//
//  Created by tristate22 on 21.02.24.
//

import UIKit

struct UserDataStr {
    var name: String
    var phoneNumber: String
    var bio: String
    var OnlineStatus: String
    var userId: String
    
    var dic: [String: Any] {
        return [strname: name,
                strphoneNumber: phoneNumber,
                strbio: bio,
                strOnlineStatus: OnlineStatus,
                struserId: userId ]
    }
}

// MARK: - User Data Key
let strname = "name"
let strphoneNumber = "phoneNumber"
let strbio = "bio"
let strOnlineStatus = "OnlineStatus"
let struserId = "userId"
let strid = "id"
let strphotoURL = "photoURL"
let strthumbnailPhotoURL = "thumbnailPhotoURL"
