//
//  FireStoreChat.swift
//  BillionsApp
//
//  Created by Tristate on 28.10.21.
//

import UIKit
import Firebase
import FirebaseFirestore

let usersCollection = "users"
let messageCollection = "message"
let dataCollection = "data"

class FireStoreChat: NSObject {
    static let shared = FireStoreChat()
    var lastPageIndex : DocumentSnapshot!
    
    //MARK: - User
    func checkUerExist(userID : String,_ isExist : @escaping (Bool) -> Swift.Void){
        Firestore.firestore().collection(usersCollection).document(userID).getDocument { (doc, error) in
            if (error != nil) {
                isExist(false)
            } else {
                if let doc = doc?.data() {
                    if doc.count > 0 {
                        isExist(true)
                    } else {
                        isExist(false)
                    }
                } else {
                    isExist(false)
                }
                
            }
        }
    }
    
    func addUser(userID: String,dicParam : [String:Any], _ isExist : @escaping (Bool) -> Swift.Void){
        var dic = dicParam
        dic[strid] = FieldValue.serverTimestamp()
        Firestore.firestore().collection(usersCollection).document().setData(dic) { (error) in
            if (error != nil) {
                isExist(false)
            } else {
                isExist(true)
            }
            
        }
    }
    
    func updateUserProfile(userID: String,dicParam : [String:Any], _ isExist : @escaping (Bool) -> Swift.Void){
        var dic = dicParam
        dic[strid] = FieldValue.serverTimestamp()
        Firestore.firestore().collection(usersCollection).document(userID).updateData(dic) { (error) in
            if (error != nil) {
                isExist(false)
            } else {
                isExist(true)
            }
            
        }
    }
    
    func getUserListData(docId: String, _ data : @escaping ([[String :Any]]) -> Swift.Void){
        var userListData = [[String:Any]]()
        Firestore.firestore().collection(usersCollection).whereField(struserId, isNotEqualTo: docId).order(by: struserId, descending: false).getDocuments { (doc, error) in
            if error == nil {
                if doc?.count ?? 0 > 0 {
                    for document in doc!.documents {
                        userListData.append(document.data())
                    }
                    data(userListData)
                } else {
                    data(userListData)
                }
            } else {
                data(userListData)
            }
        }
    }
    
    func getUserDetails(docId: String, _ data : @escaping ([[String :Any]]) -> Swift.Void){
        var userListData = [[String:Any]]()
        Firestore.firestore().collection(usersCollection).whereField(struserId, isEqualTo: docId).getDocuments { (doc, error) in
            
            if error == nil {
                if doc?.count ?? 0 > 0 {
                    for document in doc!.documents {
                        userListData.append(document.data())
                    }
                    data(userListData)
                } else {
                    data(userListData)
                }
            } else {
                data(userListData)
            }
        }
    }
    
    //MARK: - Check chat exit
    func checkChatIDExist(chatID : String,_ isExist : @escaping (Bool) -> Swift.Void){
        Firestore.firestore().collection(dataCollection).document(chatID).getDocument { (doc, error) in
            if (error != nil) {
                isExist(false)
            } else {
                if let doc = doc?.data() {
                    if doc.count > 0 {
                        isExist(true)
                    } else {
                        isExist(false)
                    }
                } else {
                    isExist(false)
                }
            }
        }
    }
    
    func addChatMessage(docId: String, dicParam : [String:Any], _ isExist : @escaping (Bool) -> Swift.Void){
        Firestore.firestore().collection(dataCollection).document(docId).collection(messageCollection).document().setData(dicParam) { (error) in
            if (error != nil) {
                isExist(false)
            } else {
                isExist(true)
            }
        }
    }
    
    func updateChatMessage(docId: String, dicParam : [String:Any], _ isExist : @escaping (Bool ) -> Swift.Void){
        Firestore.firestore().collection(dataCollection).document(docId).collection(messageCollection).document().setData(dicParam) { (error) in
            if (error != nil) {
                isExist(false)
            } else {
                isExist(true)
            }
        }
    }
    
    func getChatData(docId: String, _ data : @escaping ([[String :Any]]) -> Swift.Void){
        var chatHistoryArray = [[String:Any]]()
        Firestore.firestore().collection(dataCollection).document(docId).collection(messageCollection).whereField(strNotDeleteMsgUsers, arrayContainsAny: [APPData.appDelegate.loginUserData[0].userId ?? ""]).order(by: strtimeStamp, descending: true).getDocuments {(doc, error) in
            if error == nil {
                if doc?.count ?? 0 > 0 {
                    for document in doc!.documents {
                        chatHistoryArray.append(document.data())
                    }
                    data(chatHistoryArray)
                } else {
                    data(chatHistoryArray)
                }
            } else {
                data(chatHistoryArray)
            }
        }
    }
    
    func setRecentMsg(_ concatMemberId: String, _ dic: [String:Any]) {
        var dicParam = dic
        Firestore.firestore().collection(dataCollection).document(concatMemberId).getDocument { query, error in
            if error == nil {
                if let d = query?.data() {
                    let uC = d[strunreadCount] as? Int ?? 0
                    dicParam[strunreadCount] = (uC + 1)
                }
                
                if query?.exists == true {
                    Firestore.firestore().collection(dataCollection).document(concatMemberId).updateData(dicParam)
                } else {
                    Firestore.firestore().collection(dataCollection).document(concatMemberId).setData(dicParam)
                }
            }
        }
    }
    
    func getChatListData(docId: String, _ data : @escaping ([[String :Any]]) -> Swift.Void){
        var chatHistoryArray = [[String:Any]]()
        Firestore.firestore().collection(dataCollection).whereField(strusersIDs, arrayContainsAny: [docId]).order(by: strtimeStamp, descending: true).getDocuments {(doc, error) in
            if error == nil {
                if doc?.count ?? 0 > 0 {
                    for document in doc!.documents {
                        chatHistoryArray.append(document.data())
                    }
                    data(chatHistoryArray)
                } else {
                    data(chatHistoryArray)
                }
            } else {
                data(chatHistoryArray)
            }
        }
    }
    
    func deleteOneMsgChat(docId: String, msgId: String, _ data : @escaping (Bool) -> Swift.Void) {
        Firestore.firestore().collection(dataCollection).document(docId).collection(messageCollection).whereField(strmsgID, isEqualTo: msgId).addSnapshotListener(includeMetadataChanges: true) { query, error in
            if error != nil {
                data(false)
            } else {
                for doc in query!.documents{
                    doc.reference.delete()
                    data(true)
                }
            }
        }
    }
    
    func deleteLastMsgChat(docId: String, msgId: String, _ data : @escaping (Bool) -> Swift.Void) {
        Firestore.firestore().collection(dataCollection).document(docId).collection(messageCollection).whereField(strmsgID, isEqualTo: msgId).addSnapshotListener(includeMetadataChanges: true) { query, error in
            if error != nil {
                data(false)
            } else {
                for doc in query!.documents{
                    doc.reference.delete()
                    data(true)
                }
            }
        }
    }
    
    func deleteForUserMsgChat(docId: String, msgId: String, _ data : @escaping (Bool) -> Swift.Void) {
        Firestore.firestore().collection(dataCollection).document(docId).collection(messageCollection).whereField(strmsgID, isEqualTo: msgId).addSnapshotListener(includeMetadataChanges: true) { query, error in
            if error != nil {
                data(false)
            } else {
                for doc in query!.documents{
                    doc.reference.delete()
                    data(true)
                }
            }
        }
    }
    
    func getUnreadMsgCount(docId: String, _ data : @escaping (Int) -> Swift.Void) {
        Firestore.firestore().collection(dataCollection).document(docId).collection(messageCollection).whereField(strmsgStatus, isNotEqualTo: MsgStatus.read.rawValue).getDocuments(completion: { snap, error in
            if error != nil {
                data(0)
            } else {
                data(snap?.documents.count ?? 0)
            }
        })
    }
}

