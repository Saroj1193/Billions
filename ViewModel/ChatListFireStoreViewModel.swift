//
//  ChatListFireStoreViewModel.swift
//  BillionsApp
//
//  Created by tristate22 on 04.03.24.
//

import UIKit
import Firebase

protocol ChatListFireStoreDelegate: AnyObject {
    func getChatListData( _ data : [MessageData])
    func userDataListner(_ data : [MessageData], _ index: IndexPath, _ isScroll: Bool)
}

class ChatListFireStoreViewModel {
    weak var delegate: ChatListFireStoreDelegate?
    var msgData : [MessageData] = []
    var lastChatId : Timestamp!
    var listener: ListenerRegistration?
    var listenerUser: ListenerRegistration?
 
    init() {
        self.getData()
    }
    
    func getData(){
        guard Auth.auth().currentUser != nil, let currentUID = Auth.auth().currentUser?.uid else { return }
        
        FireStoreChat.shared.getChatListData(docId: currentUID) { (data) in
            self.msgData  = []
            var arr = [MessageData]()

            for dataObj in data{
                if self.msgData.count == 0 {
                    self.lastChatId =  (data[0][strtimeStamp] as! Timestamp)
                }
                arr.append(MessageData(dictionary: dataObj))
            }
            self.msgData = arr
            self.setDbListner()
            self.setUserListner()
            self.delegate?.getChatListData(self.msgData)
        }
    }
    
    // MARK: - Set user listner
    func setUserListner(){
        self.listenerUser = Firestore.firestore().collection(usersCollection).whereField(strname, isNotEqualTo: "").addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
                if !snapshot.metadata.hasPendingWrites {
                    snapshot.documentChanges.forEach { diff in
                        if (diff.type == .modified) {
                            if let userId = diff.document[struserId] as? String {
                                print(diff.document.data())
                                if let index = self.msgData.firstIndex(where: {$0.RID == userId }){
                                    let user = UserData.init(dictionary: diff.document.data())
                                    self.msgData[index].onlineStatusR = user.onlineStatus
                                    self.msgData[index].RName = user.name
                                    self.msgData[index].RTImage = user.thumbnailPhotoURL
                                    self.delegate?.userDataListner(self.msgData, IndexPath.init(row: index, section: 0), false)
                                    Firestore.firestore().collection(dataCollection).document(self.msgData[index].chatID  ?? "").updateData(([strOnlineStatusR: user.onlineStatus!, strRName : user.name ?? "", strRTImage : user.thumbnailPhotoURL ?? ""])) { error in
                                    }
                                } else if let index = self.msgData.firstIndex(where: {$0.SID == userId }){
                                    let user = UserData.init(dictionary: diff.document.data())
                                    self.msgData[index].onlineStatusS = user.onlineStatus
                                    self.msgData[index].SName = user.name
                                    self.msgData[index].STImage = user.thumbnailPhotoURL
                                    self.delegate?.userDataListner(self.msgData, IndexPath.init(row: index, section: 0), false)
                                    Firestore.firestore().collection(dataCollection).document(self.msgData[index].chatID  ?? "").updateData(([strOnlineStatusS: user.onlineStatus!, strSName : user.name ?? "", strSTImage : user.thumbnailPhotoURL ?? ""])) { error in
                                    }
                                }
                            }
                        }
                    }
                }
                
            }
    }
    
    func setDbListner(){
        guard Auth.auth().currentUser != nil, let currentUID = Auth.auth().currentUser?.uid else { return }
               
        let ref = Firestore.firestore().collection(dataCollection).whereField(strusersIDs, arrayContainsAny: [currentUID]).order(by: strtimeStamp, descending: true)
        
       listener = ref.addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error fetching snapshots: \(error!)")
                    return
                }
        
                snapshot.documentChanges.forEach { diff in
                    
                    if (diff.type == .added) {
                        if let id = (diff.document[strtimeStamp] as? Timestamp) {
                            self.lastChatId = id
                            if self.msgData.count > 0 {
                                let isAdd = self.msgData.filter({$0.timeStamp as? Timestamp == self.lastChatId })
                                if isAdd.count == 0 {
                                    self.msgData.insert(MessageData(dictionary: diff.document.data()), at: 0)
                                    self.delegate?.userDataListner(self.msgData, IndexPath.init(row: 0, section: 0), true)
                                }
                            } else {
                                self.msgData.insert(MessageData(dictionary: diff.document.data()), at: 0)
                                self.delegate?.userDataListner(self.msgData, IndexPath.init(row: 0, section: 0), true)
                            }
                            
                        }
                    }
                    if (diff.type == .modified) {
                        if let time = diff.document[strchatID] as? String {
                            if let index = self.msgData.firstIndex(where: {$0.chatID == time }){
                                self.msgData[index] = MessageData(dictionary: diff.document.data())
                                self.delegate?.userDataListner(self.msgData, IndexPath.init(row: index, section: 0), false)
                            }
                        }
                    }
//                    if (diff.type == .removed) {
//                        if let time = diff.document["timeStamp"] as? NSNumber {
//                            if let index = self.arrData.firstIndex(where: {$0["timeStamp"] as? NSNumber == time }){
//                                self.arrData.remove(at: index)
//                                self.tblChat.deleteRows(at: [IndexPath.init(row: index, section: 0)], with: .none)
//                            }
//                        }
//                    }
                }
            }
    }

}
