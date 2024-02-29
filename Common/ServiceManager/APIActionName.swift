//
//  APIActionName.swift
//
//
//  Created by  on 10/07/20.
//  Copyright © 2020 . All rights reserved.
//

import UIKit

class APIActionName {
//    //MARK: - Server URL
    
    //MARK: - Development Server URL
    public static let GoogleKey = "AIzaSyCVfxNjiV-QbIf1lyV9iUypOGRIXjEn7NM"
    
    public static let SERVICE_URL = "https://api.chatoutapp.com:8443/"    
    public static let TC_URL = "https://www.chatoutapp.com/terms-conditions"
    public static let PP_URL = "https://www.chatoutapp.com/privacy-policy"
    
        
    //MARK: - API Action Name
    static let refresh_Token = "users/refreshToken"
    
    /*Login And Registration API Calls*/
    static let login = "users/enter_mobile"
    static let appleGoogleLogin = "users/appleGoogleLogin"
    static let otp = "users/verify_otp"
    static let resend = "users/resend_otp"
    static let signup = "users/signup"
    static let signout = "users/logout"
    static let deleteUserProfile = "users/deleteUserProfile"
    
    
    static let checkin = "users/check_in"
    static let checkOut = "users/checkOut"
    static let checkFrndList = "users/check_friend_list"
    
    static let getUserProfile = "users/get_user_profile"
    static let updateUserProfile = "users/edit_user_profile"
    static let otherUserProfile = "users/get_other_userProfile"
    static let getNearestPlace =  "users/getNearestPlace"
    static let getCheckedInPlace =  "users/checkInDetail"
    
    static let sendChatRequest = "users/send_chat_request"
    static let acceptChatRequest = "users/accept_chat_request"
    static let sendTblRequest = "users/send_table_request"
    static let acceptTblRequest = "users/accept_table_request"
    static let pendingRequest = "users/pending"
    static let deleteRequest = "users/deleteInvitation"    
    static let setUserDeviceRelation = "users/updateDeviceToken"
    
    static let blockUserList = "users/getMyBlockedUserList"
    static let blockUser = "users/blockOrUnblock"
    static let reportUser = "users/reportUser"
    static let getFilter =  "users/filter"
    
}
