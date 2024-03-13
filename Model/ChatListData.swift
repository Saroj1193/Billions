//
//  ChatListData.swift
//  BillionsApp
//
//  Created by tristate22 on 21.02.24.
//

import UIKit

struct ChatListData {
    var RName: String
    var RTImage : String
    var RID : String
    var onlineStatusR: Any
    
    var SName: String
    var STImage : String
    var SID : String
    var onlineStatusS: Any
    
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
    // Image message
    var imageWidth: CGFloat = 0
    var imageHeight: CGFloat = 0
    var imageUrl: String = ""
    var thumbnailImageUrl: String = ""
    var localImage: Data = Data()
    // Video message
    var videoUrl: String = ""
    var localVideoUrl: String = ""
    // Replay message
    var isReplay: Bool = false
    var replyData: [String: Any] = [:]
    
    var dic: [String: Any] {
        return [strRName: RName, strRTImage: RTImage, strRID: RID, strOnlineStatusR: onlineStatusR, strSName: SName, strSTImage: STImage, strSID: SID, strOnlineStatusS: onlineStatusS, strmsgType: msgType, strmessage: message, strtimeStamp: timeStamp, strid: id, strisGroupChat: isGroupChat, strisForwarded: isForwarded, strusersIDs: usersIDs, strchatID: chatID, strmsgID: msgID, strmsgStatus: msgStatus, strNotDeleteMsgUsers: NotDeleteMsgUsers, strunreadCount: unreadCount, strisDeleteAll: isDeleteAll, strisReplay: isReplay, strreplyData: replyData]
    }
    
    var dicPhoto: [String: Any] {
        return [strRName: RName, strRTImage: RTImage, strRID: RID, strOnlineStatusR: onlineStatusR, strSName: SName, strSTImage: STImage, strSID: SID, strOnlineStatusS: onlineStatusS, strmsgType: msgType, strmessage: message, strtimeStamp: timeStamp, strid: id, strisGroupChat: isGroupChat, strisForwarded: isForwarded, strusersIDs: usersIDs, strchatID: chatID, strmsgID: msgID, strmsgStatus: msgStatus, strNotDeleteMsgUsers: NotDeleteMsgUsers, strunreadCount: unreadCount, strisDeleteAll: isDeleteAll, strimageWidth: imageWidth, strimageHeight: imageHeight, strthumbnailImageUrl: thumbnailImageUrl, strimageUrl: imageUrl, strlocalImage: localImage, strisReplay: isReplay, strreplyData: replyData]
    }
    
    var dicVideo: [String: Any] {
        return [strRName: RName, strRTImage: RTImage, strRID: RID, strOnlineStatusR: onlineStatusR, strSName: SName, strSTImage: STImage, strSID: SID, strOnlineStatusS: onlineStatusS, strmsgType: msgType, strmessage: message, strtimeStamp: timeStamp, strid: id, strisGroupChat: isGroupChat, strisForwarded: isForwarded, strusersIDs: usersIDs, strchatID: chatID, strmsgID: msgID, strmsgStatus: msgStatus, strNotDeleteMsgUsers: NotDeleteMsgUsers, strunreadCount: unreadCount, strisDeleteAll: isDeleteAll, strimageWidth: imageWidth, strimageHeight: imageHeight, strthumbnailImageUrl: thumbnailImageUrl, strimageUrl: imageUrl, strlocalImage: localImage, strvideoUrl: videoUrl, strlocalVideoUrl: localVideoUrl, strisReplay: isReplay, strreplyData: replyData]
    }
}
