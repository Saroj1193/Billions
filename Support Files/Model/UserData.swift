//
//  UserData.swift
//  BillionsApp
//
//  Created by Tristate on 28.10.21.
//

import UIKit
import FirebaseFirestoreSwift
import Firebase

class UserData: NSObject {
    @objc dynamic var id: Any?
    @objc dynamic var userId: String?
    @objc dynamic var name: String?
    @objc dynamic var bio: String?
    @objc dynamic var photoURL: String?
    @objc dynamic var thumbnailPhotoURL: String?
    @objc dynamic var phoneNumber: String?
    @objc dynamic var onlineStatusString: String?
    
    var onlineStatus: Any?
    var isSelected: Bool! = false // local only
    var onlineStatusSortDescriptor : Double? = nil
    
    static func primaryKey() -> String? {
        return struserId
    }
    
    convenience init(dictionary: [String: Any]) {
        self.init()
        self.id = dictionary[strid]
        self.userId = dictionary[struserId] as? String
        self.name = dictionary[strname] as? String
        self.bio = dictionary[strbio] as? String
        self.photoURL = dictionary[strphotoURL] as? String
        self.thumbnailPhotoURL = dictionary[strthumbnailPhotoURL] as? String
        self.phoneNumber = dictionary[strphoneNumber] as? String
        self.onlineStatus = dictionary[strOnlineStatus]
        
        self.onlineStatusString = stringStatus(onlineStatus: dictionary[strOnlineStatus])
        self.onlineStatusSortDescriptor = sorts(onlineStatus: dictionary[strOnlineStatus], id: id)
    }
}

extension UserData { // local only
    var titleFirstLetter: String {
        guard let name = name else {return "" }
        return String(name[name.startIndex]).uppercased()
    }
}

func sorts(onlineStatus: Any?, id: Any?) -> Double {
    guard let onlineStatus = onlineStatus else { return 0 }
    if let statusString = onlineStatus as? String {
        if statusString == statusOnline {
            return Double.greatestFiniteMagnitude - Double.random0to1() - ((id as? AnyObject)?.doubleValue ?? 0).truncatingRemainder(dividingBy: 1)
        }
    }
    
    if let lastSeen = onlineStatus as? TimeInterval {
        return lastSeen
    }
    return 0
}

func stringStatus(onlineStatus: Any?) -> String? {
    guard let onlineStatus = onlineStatus else { return "" }
    if let statusString = onlineStatus as? String {
        if statusString == statusOnline {
            return statusString
        }
    }
    
    if let lastSeen = onlineStatus as? Timestamp {
        let date = Date(timeIntervalSince1970: TimeInterval(lastSeen.seconds))
        let lastSeenTime = "Last seen " + timeAgoSinceDate(date)
        return lastSeenTime
    }
    return ""
}
