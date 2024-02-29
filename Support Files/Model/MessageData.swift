//
//	MessageData.swift
//	Model file generated using JSONExport: https://github.com/Ahmed-Ali/JSONExport

import Foundation 
import SwiftyJSON
import Firebase

class MessageData : NSObject {
    var RName: String?
    var RTImage : String?
    var RID : String?
    var onlineStatusR: Any?
    
    var SName: String?
    var STImage : String?
    var SID : String?
    var onlineStatusS: Any?
    
    var msgType : String?
    var message : String?
    var timeStamp : Any?
    var id : Any?
    var isGroupChat : Bool?
    var isForwarded : Bool?
    var usersIDs : [String]?
    var chatID : String?
    var msgID: String?
    var msgStatus: String?
    var NotDeleteMsgUsers: [String]?
    var unreadCount: Int?
    var isDeleteAll: Bool?

    var onlineStatusSortDescriptorR : Double? = nil
    var onlineStatusStringR: String?
    var onlineStatusSortDescriptorS : Double? = nil
    var onlineStatusStringS: String?
    
    convenience init(dictionary: [String: Any]) {
        self.init()
        RName = dictionary[strRName] as? String
        RTImage = dictionary[strRTImage] as? String
        RID = dictionary[strRID] as? String
        
        SName = dictionary[strSName] as? String
        STImage = dictionary[strSTImage] as? String
        SID = dictionary[strSID] as? String
        
        msgType = dictionary[strmsgType] as? String
        message = dictionary[strmessage] as? String
        timeStamp = dictionary[strtimeStamp]
        id = dictionary[strid]
        isGroupChat = dictionary[strisGroupChat] as? Bool
        isForwarded = dictionary[strisForwarded] as? Bool
        usersIDs = dictionary[strusersIDs] as? [String]
        chatID = dictionary[strchatID] as? String
        msgID = dictionary[strmsgID] as? String
        msgStatus = dictionary[strmsgStatus] as? String
        NotDeleteMsgUsers = dictionary[strNotDeleteMsgUsers] as? [String]
        isDeleteAll = dictionary[strisDeleteAll] as? Bool
        unreadCount = dictionary[strunreadCount] as? Int
        
        onlineStatusR = dictionary[strOnlineStatusR]
        onlineStatusStringR = stringStatus(onlineStatus: dictionary[strOnlineStatusR])
        onlineStatusSortDescriptorR = sorts(onlineStatus: dictionary[strOnlineStatusR], id: id)
        
        onlineStatusS = dictionary[strOnlineStatusS]
        onlineStatusStringS = stringStatus(onlineStatus: dictionary[strOnlineStatusS])
        onlineStatusSortDescriptorS = sorts(onlineStatus: dictionary[strOnlineStatusS], id: id)
    }
}

// MARK: - Chat List Key
let strusersIDs = "usersIDs"
let strtimeStamp = "timeStamp"
let strmsgID = "msgID"
let strNotDeleteMsgUsers = "NotDeleteMsgUsers"

let strRName = "RName"
let strRTImage = "RTImage"
let strRID = "RID"
let strOnlineStatusR = "OnlineStatusR"
let strSName = "SName"
let strSTImage = "STImage"
let strSID = "SID"
let strOnlineStatusS = "OnlineStatusS"
let strmsgType = "msgType"
let strmessage = "message"
let strisGroupChat = "isGroupChat"
let strisForwarded = "isForwarded"
let strchatID = "chatID"
let strmsgStatus = "msgStatus"
let strisDeleteAll = "isDeleteAll"
let strunreadCount = "unreadCount"
let strisTyping = "isTyping"
let strtypingIDs = "typingIDs"
