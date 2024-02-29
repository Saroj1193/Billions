//
//  ServiceController.swift
//
//  Created by Tristate Technology on 15/05/19.
//  Copyright © 2019 Tristate Technology. All rights reserved.
//

import Foundation
import UIKit

class Service: NSObject {
    
    public static let shared: Service = Service()
    
    class func requestRefreshToken(completion:  @escaping APICompletion) -> URLSessionTask {
        
        let dictParam1:Dictionary<String, Any> = Dictionary<String , Any>()
        let header:[String:String] = API.shared.headerForRefreshToken()
        let url = APIActionName.SERVICE_URL + APIActionName.refresh_Token
        let data = API.shared.body(dictParam: dictParam1)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForLogin(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.login
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForAppleGoogleLogin(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.appleGoogleLogin
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForOtp(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.otp
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForResend(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.resend
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func signupUserProfile(dictParam : Dictionary<String,Any>,imageData : [[String: Data?]],isUpload:Bool,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.signup
        let data = API.shared.body(dictParam: dictParam)
        if isUpload {
            let session = API.shared.requestWithImageWithKeys(method: .post, url: url, body: data, imgImage: imageData, attachmentKey: "test", completion: completion, dictData: dictParam) //requestWithImage(method: .post, url: url, body: nil, imgImage: imageData, attachmentKey: "photos", completion: completion, dictData: dictParam)
            return session
        } else {
            let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
            return session
        }
    }
    
    class func updateUserProfile(dictParam : Dictionary<String,Any>,imageData : [[String : Data?]],isUpload:Bool,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.updateUserProfile
        let data = API.shared.body(dictParam: dictParam)
        if isUpload {
            let session = API.shared.requestWithImageWithKeys(method: .post, url: url, body: data, imgImage: imageData, attachmentKey: "test", completion: completion, dictData: dictParam)
            return session
        } else {
            let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
            return session
        }
    }
   
    class func requestForSetUserDeviceRelation(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.setUserDeviceRelation
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
   
    class func requestForLogout(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.signout
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForUserCheckIN(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.checkin
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    class func requestForUserCheckOut(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.checkOut
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForUserCheckFrndList(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.checkFrndList
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForOtherUserProfile(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.otherUserProfile
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForGetNearestPlace(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.getNearestPlace
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .get, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForGetCheckedInPlace(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.getCheckedInPlace
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .get, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForDeleteAccount(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.deleteUserProfile
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForSendChatRequest(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.sendChatRequest
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForAcceptChatRequest(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.acceptChatRequest
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForSendTblRequest(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.sendTblRequest
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForAcceptTblRequest(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.acceptTblRequest
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForPendingRequest(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.pendingRequest
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .get, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForDeleteRequest(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.deleteRequest
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForBlockedUserListRequest(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.blockUserList
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .get, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForBlockUserRequest(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.blockUser
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForReportUserRequest(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.reportUser
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
    
    class func requestForPopularPlace(dictParam : Dictionary<String,Any>,completion: @escaping APICompletion ) -> URLSessionTask{
        let url = APIActionName.SERVICE_URL + APIActionName.getFilter
        let data = API.shared.body(dictParam: dictParam)
        let session = API.shared.request(useRefreshToken: true, method: .post, url: url, body: data, completion: completion)
        return session
    }
}




