//
//  ChatDetailsFireStoreViewModel.swift
//  BillionsApp
//
//  Created by tristate22 on 29.02.24.
//

import Foundation
import Firebase

var currentUID: String {
    guard Auth.auth().currentUser != nil, let currentUID = Auth.auth().currentUser?.uid else { return ""}
    return currentUID
}

protocol ChatDetailsFireStoreDelegate {
    func getData(_ data: [(String,[MessageListModel])], _ isScroll: Bool)
    func sendMessage(_ isSucess: Bool)
    func sendTyping(_ isTyping: Bool)
    func userListner()
}

class ChatDetailsFireStoreViewModel {
    var delegate: ChatDetailsFireStoreDelegate?
    var userData : [UserData] = []
    var listenerUser: ListenerRegistration?
    var listener: ListenerRegistration?
    var listenerDB: ListenerRegistration?
    var listenerTyping : ListenerRegistration?
    
    var msgData : [MessageListModel] = []
    var msgSectionData : [(String,[MessageListModel])] = []
    var lastChatId : Timestamp!
    
    var isForward = false
    var forwardData = [MessageListModel]()
    var msgType : MsgType = .text
    var photoImg : UIImage!
    var isTyping = false
    var replyMsg: MessageListModel?

    var concatMemberId: String {
        let otherUserMemberID = self.userData[0].userId ?? ""
        
        var concatMemberId = ""
        var concateMemberArray : [String] = []
        
        concateMemberArray = [self.currentUID, otherUserMemberID]
        concateMemberArray = concateMemberArray.sorted()
        
        for str in concateMemberArray {
            concatMemberId = concatMemberId == "" ? str : "\(concatMemberId)-\(str)"
        }
        return concatMemberId
    }
    
    var currentUID: String {
        guard Auth.auth().currentUser != nil, let currentUID = Auth.auth().currentUser?.uid else { return ""}
        return currentUID
    }
    
    var otherUserMemberID: String {
        return self.userData[0].userId ?? ""
    }
    
    init(userData : [UserData]) {
        self.userData = userData
        self.getData()
    }
    
    //MARk: - Get Data
    func getData(){
        FireStoreChat.shared.getChatData(docId: self.concatMemberId) { (data) in
            var arr = [MessageListModel]()
            for dataObj in data{
                if self.msgData.count == 0 {
                    self.lastChatId =  (data[0][strtimeStamp] is NSNull) ? nil : (data[0][strtimeStamp] as! Timestamp)
                }
                var dic = dataObj
                if dic[strRID] as? String ?? "" == self.currentUID && ((dic[strmsgStatus] as? String ?? "").capitalized == MsgStatus.sent.rawValue || (dic[strmsgStatus] as? String ?? "").capitalized == MsgStatus.delivered.rawValue) {
                    dic[strmsgStatus] = MsgStatus.read.rawValue
                    dic[strUpdateAt] = FieldValue.serverTimestamp()
                }
                if let msgID = dic[strmsgID] as? String {
                    Firestore.firestore().collection(dataCollection).document(self.concatMemberId).collection(messageCollection).document(msgID).updateData(dic)
                }
                arr.append(MessageListModel(dictionary: dataObj))
            }
            self.msgData += arr
            if self.msgData.count > 0 {
                self.msgSectionData = self.groupByDate()
            }
            self.delegate?.getData(self.msgSectionData, false)
            self.setListner()
            self.setUserListner()
            self.setDbListner()
            self.setForwardChat()
        }
    }
    
    func groupByDate() -> [(String,[MessageListModel])] {
        self.msgSectionData.removeAll()
        var transactionsGroupedByDate = Dictionary<String, [MessageListModel] >()
        
        // Looping the Array of transactions
        for transaction in self.msgData.sorted(by: {Date(timeIntervalSince1970: TimeInterval(($0.timeStamp as! Timestamp).seconds)) > Date(timeIntervalSince1970: TimeInterval(($1.timeStamp as! Timestamp).seconds))}) {
            
            // Converting the transaction's date to String
            let date = convertDateToString(date: getTimestampToDate( (transaction.timeStamp is NSNull) ? 0 : Int((transaction.timeStamp as! Timestamp).seconds)))
            
            // Verifying if the array is nil for the current date used as a
            // key in the dictionary, if so the array is initialized only once
            if transactionsGroupedByDate[date] == nil {
                transactionsGroupedByDate[date] = [MessageListModel]()
            }
            
            //          // Adding the transaction in the dictionary to the key that is the date
            transactionsGroupedByDate[date]?.append(transaction)
        }
        
        // Sorting the dictionary to descending order and the result will be
        // an array of tuples with key(String) and value(Array<Transaction>)
        return transactionsGroupedByDate.sorted { $0.0 > $1.0 }
    }
    
    func setForwardChat(){
        if self.isForward == true {
            if self.forwardData[0].msgType ?? "" == MsgType.photo.rawValue {
                self.msgType = .photo
                self.sendPhotoMsg(imgUrl: self.forwardData[0].imageUrl ?? "", thumbUrl: self.forwardData[0].thumbnailImageUrl ?? "", text: "")
            } else if self.forwardData[0].msgType ?? "" == MsgType.video.rawValue {
                self.msgType = .video
                self.sendVideoMsg(videoUrl: self.forwardData[0].videoUrl ?? "", thumbUrl: self.forwardData[0].thumbnailImageUrl ?? "", thumb: UIImage(), localVideoUrl: self.forwardData[0].localVideoUrl ?? "", text: "")
            } else {
                self.msgType = .text
                self.sendMsg(text: "")
            }
        }
    }
    
    func setListner(){
        let ref = self.lastChatId == nil ? Firestore.firestore().collection(dataCollection).document(self.concatMemberId).collection(messageCollection).order(by: strtimeStamp, descending: true) :  Firestore.firestore().collection(dataCollection).document(self.concatMemberId).collection(messageCollection).whereField(strtimeStamp, isGreaterThan: self.lastChatId as Any).order(by: strtimeStamp, descending: true)
        
        self.listener = ref.addSnapshotListener({ (query, error) in
            if error == nil {
                if let que = query {
                    self.onTableUpdate(query: que, concatMemberId: self.concatMemberId)
                }
            }
        })
    }
    
    func onTableUpdate(query: QuerySnapshot , concatMemberId : String){
        query.documentChanges.forEach({ diff in
            if !query.metadata.hasPendingWrites {
                for doc in query.documents {
                    print("Add Data1")
                    if (doc[strtimeStamp] != nil) {
                        self.lastChatId = (doc[strtimeStamp] as! Timestamp)
                        if self.msgData.count > 0 {
                            let isAdd = self.msgData.filter({$0.timeStamp as? Timestamp == self.lastChatId })
                            if isAdd.count == 0 {
                                var dic = doc.data()
                                dic[strmsgID] = doc.documentID
                                if dic[strRID] as? String ?? "" == currentUID && ((dic[strmsgStatus] as? String ?? "").capitalized == MsgStatus.sent.rawValue || (dic[strmsgStatus] as? String ?? "").capitalized == MsgStatus.delivered.rawValue) {
                                    dic[strmsgStatus] = MsgStatus.read.rawValue
                                    dic[strUpdateAt] = FieldValue.serverTimestamp()
                                }
                                Firestore.firestore().collection(dataCollection).document(concatMemberId).collection(messageCollection).document(doc.documentID).updateData(dic)
                                
                                self.msgData.insert(MessageListModel(dictionary: dic), at: 0)
                            }
                        } else {
                            var dic = doc.data()
                            dic[strmsgID] = doc.documentID
                            if dic[strRID] as? String ?? "" == currentUID && ((dic[strmsgStatus] as? String ?? "").capitalized == MsgStatus.sent.rawValue || (dic[strmsgStatus] as? String ?? "").capitalized == MsgStatus.delivered.rawValue) {
                                dic[strmsgStatus] = MsgStatus.read.rawValue
                                dic[strUpdateAt] = FieldValue.serverTimestamp()
                            }
                            Firestore.firestore().collection(dataCollection).document(concatMemberId).collection(messageCollection).document(doc.documentID).updateData(dic)
                            
                            self.msgData.insert(MessageListModel(dictionary: dic), at: 0)
                        }
                        
                    }
                }
                
                self.msgSectionData = self.groupByDate()
                self.delegate?.getData(self.msgSectionData, true)
                
                if query.documents.count > 0 {
                    self.listener?.remove()
                    self.listenerDB?.remove()
                    
                    self.setListner()
                    self.setDbListner()
                }
            }
        })
    }
    
    func setDbListner(){
        let ref = Firestore.firestore().collection(dataCollection).document(self.concatMemberId).collection(messageCollection).whereField(strUpdateAt, isGreaterThan: self.lastChatId as Any)
        
        listenerDB = ref.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                if !snapshot.metadata.hasPendingWrites {
                    for doc in snapshot.documents {
                        if (diff.type == .added) {
                            print("Add Data")
                            if let index = self.msgData.firstIndex(where: { $0.msgID == doc.documentID}) {
                                self.msgData[index] = MessageListModel(dictionary: doc.data())
                            }
                        }
                        
                        if (diff.type == .modified) {
                            print("Add modified")
                            if let index = self.msgData.firstIndex(where: { $0.msgID == doc.documentID}) {
                                self.msgData[index] = MessageListModel(dictionary: doc.data())
                            }
                            
                            //                    let date = convertDateToString(date: getTimestampToDate( (diff.document[strtimeStamp] is NSNull) ? 0 : Int((diff.document[strtimeStamp] as! Timestamp).seconds)))
                            //                    if date != "" {
                            //                        if let section = self.msgSectionData.firstIndex(where: {$0.0 == date}) {
                            //
                            //                            if let msgID = diff.document[strmsgID] as? String {
                            //                                if let index = self.msgSectionData[section].1.firstIndex(where: {$0.msgID == msgID }){
                            //                                    let isDelete = (diff.document[strNotDeleteMsgUsers] as? [String] ?? [String]()).contains(APPData.appDelegate.loginUserData[0].userId ?? "")
                            //
                            //                                    if isDelete == false {
                            //                                        self.msgSectionData[section].1.remove(at: index)
                            //                                        self.tblChat.deleteRows(at: [IndexPath.init(row: index, section: section)], with: .none)
                            //                                    } else {
                            //
                            //                                        self.msgSectionData[section].1[index] = MessageListModel(dictionary: diff.document.data())
                            //                                        self.tblChat.reloadRows(at: [IndexPath.init(row: index, section: section)], with: .none)
                            //                                        DispatchQueue.main.async {
                            //                                            self.tblChat.reloadRows(at: [IndexPath.init(row: index, section: section)], with: .none)
                            //                                        }
                            //                                    }
                            //
                            //                                }
                            //                            }
                            //
                            //                        }
                            //                    }
                            
                        }
                    }
                }
            }
            
            self.msgSectionData = self.groupByDate()
            self.delegate?.getData(self.msgSectionData, false)
        }
    }
    
    // MARK: - Set user listner
    func setUserListner(){
        self.listenerUser = Firestore.firestore().collection(usersCollection).whereField(struserId, isEqualTo: self.otherUserMemberID).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            if !snapshot.metadata.hasPendingWrites {
                snapshot.documentChanges.forEach { diff in
                    if (diff.type == .modified) {
                        if let userId = diff.document[struserId] as? String {
                            if let index = self.userData.firstIndex(where: {$0.userId == userId }){
                                self.userData[index] = UserData.init(dictionary: diff.document.data())
                                self.delegate?.userListner()
                                
                                let user = UserData.init(dictionary: diff.document.data())
                                
                                Firestore.firestore().collection(dataCollection).document(self.concatMemberId).getDocument { query, error in
                                    if error == nil {
                                        if query?.exists == true {
                                            Firestore.firestore().collection(dataCollection).document(self.concatMemberId).updateData([strOnlineStatusR: user.onlineStatus!, strRName : user.name!, strRTImage : user.thumbnailPhotoURL!])
                                        } else {
                                            Firestore.firestore().collection(dataCollection).document(self.concatMemberId).setData([strOnlineStatusR: user.onlineStatus!, strRName : user.name ?? "", strRTImage : user.thumbnailPhotoURL ?? "", strSID: self.currentUID, strRID: self.otherUserMemberID])
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    func startTypingIndictor(isTyping: Bool) {
        var dic : [String:Any] = self.getCommonUserData()
        dic[strisTyping] = isTyping
        
        Firestore.firestore().collection(dataCollection).document(self.concatMemberId).getDocument { query, error in
            if error == nil {
                if query?.exists == true {
                    var typeIds: [String] = []
                    if let data = query?.data() {
                        typeIds = data[strtypingIDs] as? [String] ?? [String]()
                    }
                    if isTyping {
                        if !typeIds.contains(where: {$0 == self.currentUID}) {
                            typeIds.append(self.currentUID)
                        }
                    } else {
                        if typeIds.contains(where: {$0 == self.currentUID}) {
                            typeIds.removeAll(where: {$0 == self.currentUID})
                        }
                    }
                    Firestore.firestore().collection(dataCollection).document(self.concatMemberId).updateData([strisTyping : isTyping, strtypingIDs : typeIds])
                } else {
                    Firestore.firestore().collection(dataCollection).document(self.concatMemberId).setData(dic)
                }
            }
        }
    }
    
    func setTypingListner(){
        let ref = Firestore.firestore().collection(dataCollection).whereField(strchatID, isEqualTo: self.concatMemberId)
        
        listenerTyping = ref.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if (diff.type == .added) {
                    self.isTyping = (diff.document[strtypingIDs] as? [String] ?? [String]()).contains(where: {$0 == self.otherUserMemberID}) ? true : false
                    self.delegate?.sendTyping(self.isTyping)
                }
                if (diff.type == .modified) {
                    self.isTyping = (diff.document[strtypingIDs] as? [String] ?? [String]()).contains(where: {$0 == self.otherUserMemberID}) ? true : false
                    self.delegate?.sendTyping(self.isTyping)
                }
                if (diff.type == .removed) {
                }
            }
        }
    }
}

extension ChatDetailsFireStoreViewModel {
    // MARK: -  Send Text Message
    func sendMsg(text: String) {
        self.msgType = .text
        let data = self.getSendCommonData(text: text)
        let dic = data.0.dic
        let dicMain = data.1.dic
        
        FireStoreChat.shared.checkChatIDExist(chatID: self.concatMemberId) { isExit in
            self.isForward = false
            if isExit == false {
                FireStoreChat.shared.addChatMessage(docId: self.concatMemberId, dicParam: dic) { isAdd in
                    if isAdd {
                        self.delegate?.sendMessage(true)
                        FireStoreChat.shared.setRecentMsg(self.concatMemberId, dicMain)
                    } else {
                        self.delegate?.sendMessage(false)
                    }
                }
            } else {
                FireStoreChat.shared.updateChatMessage(docId: self.concatMemberId, dicParam: dic) { isUpdate in
                    if isUpdate {
                        self.delegate?.sendMessage(true)
                        FireStoreChat.shared.setRecentMsg(self.concatMemberId, dicMain)
                    } else {
                        self.delegate?.sendMessage(false)
                    }
                }
            }
        }
    }
    
    func sendPhotoMsg(imgUrl: String , thumbUrl : String, text: String) {
        self.msgType = .photo
        let data = self.getSendPhotoCommonData(imgUrl: imgUrl, thumbUrl: thumbUrl, text: text)
        let dic = data.0.dicPhoto
        let dicMain = data.1.dicPhoto
        
        FireStoreChat.shared.checkChatIDExist(chatID: self.concatMemberId) { isExit in
            self.isForward = false
            if isExit == false{
                FireStoreChat.shared.addChatMessage(docId: self.concatMemberId, dicParam: dic) { isAdd in
                    if isAdd {
                        self.delegate?.sendMessage(true)
                        FireStoreChat.shared.setRecentMsg(self.concatMemberId, dicMain)
                    } else {
                        self.delegate?.sendMessage(false)
                    }
                }
            } else {
                FireStoreChat.shared.updateChatMessage(docId: self.concatMemberId, dicParam: dic) { isUpdate in
                    if isUpdate {
                        self.delegate?.sendMessage(true)
                        FireStoreChat.shared.setRecentMsg(self.concatMemberId, dicMain)
                    } else {
                        self.delegate?.sendMessage(false)
                    }
                }
            }
        }
        
    }
    
    func sendVideoMsg(videoUrl: String , thumbUrl : String, thumb: UIImage?, localVideoUrl : String, text: String) {
        self.msgType = .video
        let data = self.getSendVideoCommonData(videoUrl: videoUrl , thumbUrl : thumbUrl, thumb: thumb, localVideoUrl : localVideoUrl, text: text)
        let dic = data.0.dicVideo
        let dicMain = data.1.dicVideo
        
        FireStoreChat.shared.checkChatIDExist(chatID: self.concatMemberId) { isExit in
            self.isForward = false
            if isExit == false{
                FireStoreChat.shared.addChatMessage(docId: self.concatMemberId, dicParam: dic) { isAdd in
                    if isAdd {
                        self.delegate?.sendMessage(true)
                    } else {
                        self.delegate?.sendMessage(false)
                    }
                }
            } else {
                FireStoreChat.shared.updateChatMessage(docId: self.concatMemberId, dicParam: dic) { isUpdate in
                    if isUpdate {
                        self.delegate?.sendMessage(true)
                    } else {
                        self.delegate?.sendMessage(false)
                    }
                }
            }
        }
    }
    func getCommonUserData() -> [String: Any] {
        var dic : [String:Any] = [:]
        
        dic[strSID] = self.currentUID
        dic[strRID] = self.otherUserMemberID
        dic[strSName] = APPData.appDelegate.loginUserData[0].name ?? ""
        dic[strRName] = self.userData[0].name ?? ""
        dic[strtypingIDs] = [self.currentUID]
        dic[strchatID] = self.concatMemberId
        return dic
    }
    
    func getSendCommonData(text: String) -> (SendMsgData, ChatListData) {
        let message = self.isForward ? self.forwardData[0].message ?? "" : text.trimSpaces()
        let concateMemberArray : [String] = [self.currentUID, self.otherUserMemberID]
        let isForwad = (self.isForward ? ((self.forwardData[0].SID ?? "" == self.currentUID) ? false : self.isForward) : self.isForward)
        var isReply = false
        var replyData: [String: Any] = [:]
        if let data = self.replyMsg {
            isReply = true
            replyData = data.dicData
        }
        
        let time = FieldValue.serverTimestamp()
        let dic = SendMsgData(RID: self.otherUserMemberID, SID: self.currentUID, msgType: msgType.rawValue, message: message, timeStamp: time, id: time, isGroupChat: false, isForwarded: isForwad, usersIDs: concateMemberArray, chatID: self.concatMemberId, msgID: "", msgStatus: MsgStatus.sent.rawValue, NotDeleteMsgUsers: concateMemberArray, unreadCount: 0, isDeleteAll: false, likeUsers: [], likeSymbole: [], isReplay: isReply, replyData: replyData)
        
        let dicMain = ChatListData(RName: self.userData[0].name ?? "", RTImage: self.userData[0].thumbnailPhotoURL ?? "", RID: self.otherUserMemberID, onlineStatusR: self.userData[0].onlineStatus!, SName: APPData.appDelegate.loginUserData[0].name ?? "", STImage: APPData.appDelegate.loginUserData[0].thumbnailPhotoURL ?? "", SID: self.currentUID, onlineStatusS: APPData.appDelegate.loginUserData[0].onlineStatus!, msgType: msgType.rawValue, message: message, timeStamp: time, id: time, isGroupChat: false, isForwarded: isForwad, usersIDs: concateMemberArray, chatID: self.concatMemberId, msgID: "", msgStatus: MsgStatus.sent.rawValue, NotDeleteMsgUsers: concateMemberArray, unreadCount: 0, isDeleteAll: false, isReplay: isReply, replyData: replyData)
        return (dic, dicMain)
    }
    
    func getSendPhotoCommonData(imgUrl: String , thumbUrl : String, text: String) -> (SendMsgData, ChatListData) {
        let data = self.getSendCommonData(text: text)
        var dic = data.0
        dic.imageWidth = self.isForward ? self.forwardData[0].imageWidth ?? 0 : self.photoImg.size.width
        dic.imageHeight = self.isForward ? self.forwardData[0].imageHeight ?? 0 : self.photoImg.size.height
        dic.imageUrl = imgUrl
        dic.thumbnailImageUrl = thumbUrl
        dic.localImage = self.isForward ? self.forwardData[0].localImage ?? Data() : self.photoImg.jpegData(compressionQuality: 0.5) ?? Data()
        
        var dicMain = data.1
        dicMain.imageWidth = self.isForward ? self.forwardData[0].imageWidth ?? 0 : self.photoImg.size.width
        dicMain.imageHeight = self.isForward ? self.forwardData[0].imageHeight ?? 0 : self.photoImg.size.height
        dicMain.imageUrl = imgUrl
        dicMain.thumbnailImageUrl = thumbUrl
        dicMain.localImage = self.isForward ? self.forwardData[0].localImage ?? Data() : self.photoImg.jpegData(compressionQuality: 0.5) ?? Data()
        return (dic, dicMain)
    }
    
    func getSendVideoCommonData(videoUrl: String , thumbUrl : String, thumb: UIImage?, localVideoUrl : String, text: String) -> (SendMsgData, ChatListData) {
        let data = self.getSendCommonData(text: text)
        var dic = data.0
        dic.imageWidth = self.isForward ? self.forwardData[0].imageWidth ?? 0 : thumb?.size.width ?? 0
        dic.imageHeight = self.isForward ? self.forwardData[0].imageHeight ?? 0 : thumb?.size.height ?? 0
        dic.videoUrl = self.isForward ? self.forwardData[0].videoUrl ?? "" : videoUrl
        dic.thumbnailImageUrl = self.isForward ? self.forwardData[0].thumbnailImageUrl ?? "" : thumbUrl
        dic.localImage = self.isForward ? self.forwardData[0].localImage ?? Data() : thumb!.jpegData(compressionQuality: 0.5) ?? Data()
        dic.localVideoUrl = self.isForward ? self.forwardData[0].localVideoUrl ?? "" : localVideoUrl
        
        var dicMain = data.1
        dicMain.imageWidth = self.isForward ? self.forwardData[0].imageWidth ?? 0 : thumb?.size.width ?? 0
        dicMain.imageHeight = self.isForward ? self.forwardData[0].imageHeight ?? 0 : thumb?.size.height ?? 0
        dicMain.videoUrl = self.isForward ? self.forwardData[0].videoUrl ?? "" : videoUrl
        dicMain.thumbnailImageUrl = self.isForward ? self.forwardData[0].thumbnailImageUrl ?? "" : thumbUrl
        dicMain.localImage = self.isForward ? self.forwardData[0].localImage ?? Data() : thumb!.jpegData(compressionQuality: 0.5) ?? Data()
        dicMain.localVideoUrl = self.isForward ? self.forwardData[0].localVideoUrl ?? "" : localVideoUrl
        return (dic, dicMain)
    }
}
