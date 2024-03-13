//
//  MessageListModel.swift
//  BillionsApp
//
//  Created by tristate22 on 21.02.24.
//

import Foundation
import SwiftyJSON
import Firebase

class MessageListModel : NSObject {
    
    var RID : String?
    var SID : String?
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
    var likeUsers: [String]?
    var likeSymbole: [String]?
    // Image message
    var imageWidth: CGFloat?
    var imageHeight: CGFloat?
    var imageUrl: String?
    var thumbnailImageUrl: String?
    var localImage: Data?
    // Video message
    var videoUrl: String?
    var localVideoUrl: String?
    
    // Replay message
    var isReplay: Bool?
    var replyData: MessageListModel?
    var dicData: [String: Any] = [:]
    
    convenience init(dictionary: [String: Any]) {
        self.init()
        self.dicData = dictionary
        RID = dictionary[strRID] as? String
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
        likeUsers = dictionary[strlikeUsers] as? [String]
        isDeleteAll = dictionary[strisDeleteAll] as? Bool
        unreadCount = dictionary[strunreadCount] as? Int
        // Image message
        imageWidth = dictionary[strimageWidth] as? CGFloat
        imageHeight = dictionary[strimageHeight] as? CGFloat
        imageUrl = dictionary[strimageUrl] as? String
        thumbnailImageUrl = dictionary[strthumbnailImageUrl] as? String
        localImage = dictionary[strlocalImage] as? Data
        // Video message
        videoUrl = dictionary[strvideoUrl] as? String
        localVideoUrl = dictionary[strlocalVideoUrl] as? String
        
        // Reply message
        isReplay = dictionary[strisReplay] as? Bool
        if isReplay ?? false {
            replyData = MessageListModel(dictionary: dictionary[strreplyData] as? [String: Any] ?? [:])
        }
    }
}
