//
//  APIController.swift


import Foundation
import  UIKit

class APIController: NSObject{
    
    class func refreshToken(completion: @escaping (Bool,String?, Int) -> Void) {
        /*let _*/  _ = Service.requestRefreshToken { (response, error) in
            
            if let dictResponse = response, (dictResponse["code"]) as? Int == 1
            {
                let dictData = (dictResponse["data"] as? [String:Any] ?? [:]).dictionaryByReplacingNullsWithBlanks()
                
                let authToken = dictData["new_token"] as? String ?? ""
//                UserBo.shared.refresh_token = APPData.REFRESH_TOKEN_FIRST_TIME
//                UserBo.shared.auth_token = authToken
//                userInfoManager.setUserInfo(userInfoModel: UserBo.shared)
                completion(true,nil, 1)
            }else if let dictResponse = response, (dictResponse["code"]) as? Int == 0 {
                completion(false,dictResponse["message"] as? String ?? ConstantText.lngApiMsg, 0)
            }
            else{
                completion(false,nil, 0)
            }
        }
    }
    
    class func requestForLogin(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForLogin(dictParam: dictParam) { (dictResponse, strError) in
//            print("Login Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                if let dictData = dictResponse["data"] as? Dictionary<String,Any>{
                    var dict  = dictData
//                    dict["auth_token"] = dictResponse["auth_token"] ?? APPData.Auth_TOKEN_FIRST_TIME
//                    dict["refresh_token"] = APPData.REFRESH_TOKEN_FIRST_TIME
                    
                    completion(dict,nil)
                }else{
                    completion(nil,dictResponse["message"] as? String ?? "")
                }
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForAppleGoogleLogin(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForAppleGoogleLogin(dictParam: dictParam) { (dictResponse, strError) in
//            print("Login Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                if let dictData = dictResponse["data"] as? Dictionary<String,Any>{
                    var dict  = dictData
                    dict["auth_token"] = dictResponse["auth_token"] ?? APPData.Auth_TOKEN_FIRST_TIME
                    dict["refresh_token"] = APPData.REFRESH_TOKEN_FIRST_TIME
                    
                    completion(dict,nil)
                }else{
                    completion(nil,dictResponse["message"] as? String ?? "")
                }
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForOtp(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForOtp(dictParam: dictParam) { (dictResponse, strError) in
//            print("response for otp -> > > > > > > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                
                if let dictData = dictResponse["data"] as? Dictionary<String,Any>{
                    var dict  = dictData
                    dict["auth_token"] = dictResponse["auth_token"] ?? APPData.Auth_TOKEN_FIRST_TIME
                    dict["refresh_token"] = APPData.REFRESH_TOKEN_FIRST_TIME
                    
                    completion(dict,nil)
                }else{
                    completion(nil,dictResponse["message"] as? String ?? "")
                }
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForResend(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForResend(dictParam: dictParam) { (dictResponse, strError) in
//            print("response for resend -> > > > > > > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func signupUserProfile(dictParam:Dictionary<String,Any>,imageData: [[String: Data?]],isUpload : Bool,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.signupUserProfile(dictParam: dictParam,imageData: imageData, isUpload: isUpload) { (dictResponse, strError) in
//            print("UserProfile -> > > > > > > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                if let dictData = dictResponse["data"] as? Dictionary<String,Any>{
                    var dict  = dictData
                    dict["auth_token"] = dictResponse["auth_token"] ?? APPData.Auth_TOKEN_FIRST_TIME
                    dict["refresh_token"] = APPData.REFRESH_TOKEN_FIRST_TIME
                    
                    completion(dict,nil)
                }else{
                    completion(nil,dictResponse["message"] as? String ?? "")
                }
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func updateUserProfile(dictParam:Dictionary<String,Any>,imageData: [[String: Data?]],isUpload : Bool,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.updateUserProfile(dictParam: dictParam,imageData: imageData, isUpload: isUpload) { (dictResponse, strError) in
//            print("Edit user Profile -> > > > > > > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                if let dictData = dictResponse["data"] as? Dictionary<String,Any>{
                    var dict  = dictData
//                    dict["auth_token"] =  UserBo.shared.auth_token ?? APPData.Auth_TOKEN_FIRST_TIME
//                    dict["refresh_token"] = UserBo.shared.refresh_token ?? APPData.REFRESH_TOKEN_FIRST_TIME
                    
                    completion(dict,nil)
                }else{
                    completion(nil,dictResponse["message"] as? String ?? "")
                }
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForSetUserDeviceRelation(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        
        let  _ = Service.requestForSetUserDeviceRelation(dictParam: dictParam) { (dictResponse, strError) in
            //print("SetUserDeviceRelation Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForLogout(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForLogout(dictParam: dictParam) { (dictResponse, strError) in
//            print("Logout Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
                
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForUserCheckIN(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForUserCheckIN(dictParam: dictParam) { (dictResponse, strError) in
//            print("UserCheckIN Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForUserCheckOut(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForUserCheckOut(dictParam: dictParam) { (dictResponse, strError) in
//            print("UserCheckOUT Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                if let dictData = dictResponse["data"] as? Dictionary<String,Any>{
                    var dict  = dictData
//                    dict["auth_token"] = dictResponse["auth_token"] ?? APPData.Auth_TOKEN_FIRST_TIME
//                    dict["refresh_token"] = APPData.REFRESH_TOKEN_FIRST_TIME
                    
                    completion(dict,nil)
                }else{
                    completion(nil,dictResponse["message"] as? String ?? "")
                }
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    
    class func requestForUserCheckFrndList(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForUserCheckFrndList(dictParam: dictParam) { (dictResponse, strError) in
//            print("UserCheckFrndList Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForOtherUserProfile(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForOtherUserProfile(dictParam: dictParam) { (dictResponse, strError) in
//            print("OtherUserProfile Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForGetNearestPlace(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForGetNearestPlace(dictParam: dictParam) { (dictResponse, strError) in
//            print("GetNearestPlace Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                if let dictData = dictResponse["data"] as? Dictionary<String,Any>{
                    let dict  = dictData

                    completion(dict,nil)
                }else{
                    completion(nil,dictResponse["message"] as? String ?? "")
                }
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForGetCheckedInPlace(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForGetCheckedInPlace(dictParam: dictParam) { (dictResponse, strError) in
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                if let dictData = dictResponse["data"] as? Dictionary<String,Any>{
                    let dict  = dictData

                    completion(dict,nil)
                }else{
                    completion(nil,dictResponse["message"] as? String ?? "")
                }
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForDeleteAccount(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForDeleteAccount(dictParam: dictParam) { (dictResponse, strError) in
//            print("DeleteAccount Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForSendChatRequest(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForSendChatRequest(dictParam: dictParam) { (dictResponse, strError) in
//            print("SendChatRequest Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForAcceptChatRequest(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForAcceptChatRequest(dictParam: dictParam) { (dictResponse, strError) in
//            print("AcceptChatRequest Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForSendTblRequest(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForSendTblRequest(dictParam: dictParam) { (dictResponse, strError) in
//            print("SendTblRequest Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForAcceptTblRequest(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForAcceptTblRequest(dictParam: dictParam) { (dictResponse, strError) in
//            print("AcceptTblRequest Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForPendingRequest(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForPendingRequest(dictParam: dictParam) { (dictResponse, strError) in
//            print("PendingRequest Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForDeleteRequest(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForDeleteRequest(dictParam: dictParam) { (dictResponse, strError) in
//            print("Delete Request Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForBlockedUserListRequest(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForBlockedUserListRequest(dictParam: dictParam) { (dictResponse, strError) in
//            print("PendingRequest Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForBlockUserRequest(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForBlockUserRequest(dictParam: dictParam) { (dictResponse, strError) in
//            print("PendingRequest Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForReportUserRequest(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForReportUserRequest(dictParam: dictParam) { (dictResponse, strError) in
//            print("PendingRequest Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
    class func requestForPopularPlace(dictParam:Dictionary<String,Any>,completion: @escaping (Dictionary<String,Any>?,String?) -> Void){
        let _ = Service.requestForPopularPlace(dictParam: dictParam) { (dictResponse, strError) in
//            print("GetNearestPlace Response > > > > > > > > >\(dictResponse ?? [:])")
            if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 1{
                completion(dictResponse,nil)
            }else if let dictResponse = dictResponse, dictResponse["code"] as? Int ?? 0 == 0 {
                completion(nil,dictResponse["message"] as? String ?? ConstantText.lngApiMsg)
            }else{
                completion(nil,nil)
            }
        }
    }
    
}
