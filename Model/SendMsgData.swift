//
//  SendMsgData.swift
//  BillionsApp
//
//  Created by tristate22 on 21.02.24.
//

import UIKit

struct SendMsgData {
    var RID : String
    var SID : String
    var msgType : String
    var message : String
    var timeStamp : Any
    var id : Any
    var isGroupChat : Bool
    var isForwarded : Bool
    var usersIDs : [String]
    var chatID : String
    var msgID: String
    var msgStatus: String
    var NotDeleteMsgUsers: [String]
    var unreadCount: Int
    var isDeleteAll: Bool
    var likeUsers: [String]
    var likeSymbole: [String]
    // Image message
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    var imageUrl: String = ""
    var thumbnailImageUrl: String = ""
    var localImage: Data = Data()
    
    var dic: [String: Any] {
        return [strRID: RID, strSID: SID, strmsgType: msgType, strmessage: message, strtimeStamp: timeStamp, strid: id, strisGroupChat: isGroupChat, strisForwarded: isForwarded, strusersIDs: usersIDs, strchatID: chatID, strmsgID: msgID, strmsgStatus: msgStatus, strNotDeleteMsgUsers: NotDeleteMsgUsers, strunreadCount: unreadCount, strisDeleteAll: isDeleteAll, strlikeUsers: likeUsers, strlikeSymbole: likeSymbole, strimageWidth: imageWidth, strimageHeight: imageHeight, strthumbnailImageUrl: thumbnailImageUrl, strimageUrl: imageUrl, strlocalImage: localImage]
    }
}

// MARK: - Send Msg Key
let strlikeUsers = "likeUsers"
let strlikeSymbole = "likeSymbole"
let strimageWidth = "imageWidth"
let strimageHeight = "imageHeight"
let strimageUrl = "imageUrl"
let strthumbnailImageUrl = "thumbnailImageUrl"
let strlocalImage = "localImage"
