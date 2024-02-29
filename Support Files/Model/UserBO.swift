//
//  UserBO.swift
//  BillionsApp
//
//  Created by Tristate on 28.10.21.
//

import UIKit

class UserBO: NSObject {

}


import Foundation
import SwiftyJSON


class UserBo : NSObject, NSCoding{
    static var shared : UserBo!
    
    var allowNotify : Int!
    var blockedUserId : String!
    var countryCode : String!
    var createdDate : Int!
    var dateOfBirth : String!
    var firstName : String!
    var gender : String!
    var guid : String!
    var interestedIn : String!
    var isActive : Int!
    var isAlreadyRegister : Int!
    var isBlocked : Int!
    var isVerified : Int!
    var lastName : String!
    var mobileNumber : String!
    var mode : String!
    var modifiedDate : Int!
    var userGuid : String!
    var userId : String!
    var verifyCode : String!
    var isDeleted : Int!
    var url : String!
    var auth_token:String!
    var refresh_token:String!
    var bio: String!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        allowNotify = json["allow_notify"].intValue
        blockedUserId = json["blocked_user_id"].stringValue
        countryCode = json["country_code"].stringValue
        createdDate = json["created_date"].intValue
        dateOfBirth = json["date_of_birth"].stringValue
        firstName = json["first_name"].stringValue
        gender = json["gender"].stringValue
        guid = json["guid"].stringValue
        interestedIn = json["interested_in"].stringValue
        isActive = json["is_active"].intValue
        isAlreadyRegister = json["is_already_register"].intValue
        isBlocked = json["is_blocked"].intValue
        isVerified = json["is_verified"].intValue
        lastName = json["last_name"].stringValue
        mobileNumber = json["mobile_number"].stringValue
        mode = json["mode"].stringValue
        modifiedDate = json["modified_date"].intValue
       
        isDeleted = json["is_deleted"].intValue
        url = json["url"].stringValue
        userGuid = json["user_guid"].stringValue
        userId = json["user_id"].stringValue
        verifyCode = json["verify_code"].stringValue
        auth_token = json["auth_token"].stringValue
        refresh_token = json["refresh_token"].stringValue
        bio = json["bio"].stringValue
        
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if allowNotify != nil{
            dictionary["allow_notify"] = allowNotify
        }
        if blockedUserId != nil{
            dictionary["blocked_user_id"] = blockedUserId
        }
        if countryCode != nil{
            dictionary["country_code"] = countryCode
        }
        if createdDate != nil{
            dictionary["created_date"] = createdDate
        }
        if dateOfBirth != nil{
            dictionary["date_of_birth"] = dateOfBirth
        }
        if firstName != nil{
            dictionary["first_name"] = firstName
        }
        if gender != nil{
            dictionary["gender"] = gender
        }
        if guid != nil{
            dictionary["guid"] = guid
        }
        if interestedIn != nil{
            dictionary["interested_in"] = interestedIn
        }
        if isActive != nil{
            dictionary["is_active"] = isActive
        }
        if isAlreadyRegister != nil{
            dictionary["is_already_register"] = isAlreadyRegister
        }
        if isBlocked != nil{
            dictionary["is_blocked"] = isBlocked
        }
        if isVerified != nil{
            dictionary["is_verified"] = isVerified
        }
        if lastName != nil{
            dictionary["last_name"] = lastName
        }
        if mobileNumber != nil{
            dictionary["mobile_number"] = mobileNumber
        }
        if mode != nil{
            dictionary["mode"] = mode
        }
        if modifiedDate != nil{
            dictionary["modified_date"] = modifiedDate
        }
       
        
        
        if userGuid != nil{
            dictionary["user_guid"] = userGuid
        }
        if userId != nil{
            dictionary["user_id"] = userId
        }
        if verifyCode != nil{
            dictionary["verify_code"] = verifyCode
        }
        if refresh_token != nil{
            dictionary["refresh_token"] = refresh_token
        }
        if auth_token != nil{
            dictionary["auth_token"] = auth_token
        }
        if isDeleted != nil{
            dictionary["is_deleted"] = isDeleted
        }
        if url != nil{
            dictionary["url"] = url
        }
        if bio != nil{
            dictionary["bio"] = bio
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        allowNotify = aDecoder.decodeObject(forKey: "allow_notify") as? Int
        blockedUserId = aDecoder.decodeObject(forKey: "blocked_user_id") as? String
        countryCode = aDecoder.decodeObject(forKey: "country_code") as? String
        createdDate = aDecoder.decodeObject(forKey: "created_date") as? Int
        dateOfBirth = aDecoder.decodeObject(forKey: "date_of_birth") as? String
        firstName = aDecoder.decodeObject(forKey: "first_name") as? String
        gender = aDecoder.decodeObject(forKey: "gender") as? String
        guid = aDecoder.decodeObject(forKey: "guid") as? String
        interestedIn = aDecoder.decodeObject(forKey: "interested_in") as? String
        isActive = aDecoder.decodeObject(forKey: "is_active") as? Int
        isAlreadyRegister = aDecoder.decodeObject(forKey: "is_already_register") as? Int
        isBlocked = aDecoder.decodeObject(forKey: "is_blocked") as? Int
        isVerified = aDecoder.decodeObject(forKey: "is_verified") as? Int
        lastName = aDecoder.decodeObject(forKey: "last_name") as? String
        mobileNumber = aDecoder.decodeObject(forKey: "mobile_number") as? String
        mode = aDecoder.decodeObject(forKey: "mode") as? String
        modifiedDate = aDecoder.decodeObject(forKey: "modified_date") as? Int
        userGuid = aDecoder.decodeObject(forKey: "user_guid") as? String
        userId = aDecoder.decodeObject(forKey: "user_id") as? String
        verifyCode = aDecoder.decodeObject(forKey: "verify_code") as? String
        url = aDecoder.decodeObject(forKey: "url") as? String
        isDeleted = aDecoder.decodeObject(forKey: "is_deleted") as? Int
        auth_token = aDecoder.decodeObject(forKey: "auth_token") as? String
        refresh_token = aDecoder.decodeObject(forKey: "refresh_token") as? String
        bio = aDecoder.decodeObject(forKey: "bio") as? String
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if allowNotify != nil{
            aCoder.encode(allowNotify, forKey: "allow_notify")
        }
        if blockedUserId != nil{
            aCoder.encode(blockedUserId, forKey: "blocked_user_id")
        }
        if countryCode != nil{
            aCoder.encode(countryCode, forKey: "country_code")
        }
        if createdDate != nil{
            aCoder.encode(createdDate, forKey: "created_date")
        }
        if dateOfBirth != nil{
            aCoder.encode(dateOfBirth, forKey: "date_of_birth")
        }
        if firstName != nil{
            aCoder.encode(firstName, forKey: "first_name")
        }
        if gender != nil{
            aCoder.encode(gender, forKey: "gender")
        }
        if guid != nil{
            aCoder.encode(guid, forKey: "guid")
        }
        if interestedIn != nil{
            aCoder.encode(interestedIn, forKey: "interested_in")
        }
        if isActive != nil{
            aCoder.encode(isActive, forKey: "is_active")
        }
        if isAlreadyRegister != nil{
            aCoder.encode(isAlreadyRegister, forKey: "is_already_register")
        }
        if isBlocked != nil{
            aCoder.encode(isBlocked, forKey: "is_blocked")
        }
        if isVerified != nil{
            aCoder.encode(isVerified, forKey: "is_verified")
        }
        if lastName != nil{
            aCoder.encode(lastName, forKey: "last_name")
        }
        if mobileNumber != nil{
            aCoder.encode(mobileNumber, forKey: "mobile_number")
        }
        if mode != nil{
            aCoder.encode(mode, forKey: "mode")
        }
        if modifiedDate != nil{
            aCoder.encode(modifiedDate, forKey: "modified_date")
        }
        
        if userGuid != nil{
            aCoder.encode(userGuid, forKey: "user_guid")
        }
        if userId != nil{
            aCoder.encode(userId, forKey: "user_id")
        }
        if verifyCode != nil{
            aCoder.encode(verifyCode, forKey: "verify_code")
        }
        if auth_token != nil{
            aCoder.encode(auth_token, forKey: "auth_token")
        }
        if refresh_token != nil{
            aCoder.encode(refresh_token, forKey: "refresh_token")
        }
        if isDeleted != nil{
            aCoder.encode(isDeleted, forKey: "is_deleted")
        }
        if url != nil{
            aCoder.encode(url, forKey: "url")
        }
        if bio != nil{
            aCoder.encode(bio, forKey: "bio")
        }
    }
}


let userInfoKey: String = "UserModel"

class userInfoManager: NSObject {
    
    // MARK: - Setter Method
    // set user's info in UserDefaults
    class func setUserInfo(userInfoModel: UserBo!) {
        if let userModel = userInfoModel {
            let archivedServerModules = NSKeyedArchiver.archivedData(withRootObject: userModel)
            GlobalFunction.setValueToUserDefaultsForKey(keyName: userInfoKey, value: archivedServerModules as AnyObject?)
        }
    }
    
    // MARK: - Getter Method
    // Get user info from UserDefaults
    class func getUserInfoModel() -> UserBo! {
        let archivedServerModules: AnyObject? = GlobalFunction.getValueFromUserDefaultsForKey(keyName: userInfoKey)
        if archivedServerModules == nil {
            return nil
        }
        if let data = archivedServerModules as? NSData {
            if let userInfoModel = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? UserBo {
                return userInfoModel
            } }
        return nil
    }
    
    // MARK: - Remove user's info
    // remove user's info from UserDefaults
    class func removeUserInfo() {
        
        UserDefaults.standard.removeObject(forKey: userInfoKey)
        UserDefaults.standard.set(false, forKey: "isLogin")
        UserDefaults.standard.synchronize()
        
        UserBo.shared = UserBo.init(fromJson: JSON([String:Any]()))
        userInfoManager.setUserInfo(userInfoModel: UserBo.shared)
    }
    
}
