//
//  UserExistenceChecker.swift
//  FalconMessenger
//
//  Created by Roman Mizin on 12/27/18.
//  Copyright © 2018 Roman Mizin. All rights reserved.
//

import UIKit
import Firebase
import SDWebImage

protocol UserExistenceDelegate {
    func user(isAlreadyExists: Bool, name: String?, bio: String?, image: UIImage?)
}

final class UserExistenceChecker: NSObject {
    
    fileprivate var isNameExists: Bool?
    fileprivate var isBioExists: Bool?
    fileprivate var isPhotoExists: Bool?
    
    fileprivate var name: String?
    fileprivate var bio: String?
    fileprivate var photo: UIImage?
    
    var delegate: UserExistenceDelegate?
    
    fileprivate func checkUserData() {
        
        guard let isNameExistsVal = isNameExists, isBioExists != nil, isPhotoExists != nil else { return }
        delegate?.user(isAlreadyExists: isNameExistsVal, name: name , bio: bio, image: photo)
    }
    
    
    func checkIfUserDataExists() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection(usersCollection).document(currentUserID).getDocument { (doc, error) in
            if (error != nil) {
                self.isNameExists = false
            } else {
                if let doc = doc?.data() {
                    if doc.count > 0 {
                        self.name = doc["name"] as? String ?? ""
                        self.isNameExists = self.name != ""
                        
                        self.bio = doc["bio"] as? String ?? ""
                        self.isBioExists = self.bio != ""
                        
                        self.name = doc["name"] as? String ?? ""
                        self.isNameExists = self.name != ""
                        
                        if doc["photoURL"] != nil {
                            guard let urlString = doc["photoURL"] as? String else {
                                return
                            }
                            SDWebImageDownloader.shared.downloadImage(with: URL(string: urlString), options: [.scaleDownLargeImages, .continueInBackground], progress: nil, completed: { (image, _, _, _) in
                                self.isPhotoExists = true
                                self.photo = image
                            })
                        } else {
                            self.isPhotoExists = false
                        }
                        
                    } else {
                        self.isNameExists = false
                        self.isPhotoExists = false
                        self.isBioExists = false
                    }
                } else {
                    self.isNameExists = false
                    self.isPhotoExists = false
                    self.isBioExists = false
                }
                self.checkUserData()
            }
        }
    }
}
