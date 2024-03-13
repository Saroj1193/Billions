//
//  UserProfileDataDatabaseUpdater.swift
//  Pigeon-project
//
//  Created by Roman Mizin on 4/4/18.
//  Copyright © 2018 Roman Mizin. All rights reserved.
//

import UIKit
import Firebase

final class UserProfileDataDatabaseUpdater: NSObject {

  typealias UpdateUserProfileCompletionHandler = (_ success: Bool) -> Void
  func updateUserProfile(with image: UIImage, completion: @escaping UpdateUserProfileCompletionHandler) {
    
    guard let currentUserID = Auth.auth().currentUser?.uid else { return }
    
    let userReference = Firestore.firestore().collection(usersCollection).document(currentUserID)

    let thumbnailImage = createImageThumbnail(image)
    var images = [(image: UIImage, quality: CGFloat, key: String)]()
    images.append((image: image, quality: 1, key: "photoURL"))
    images.append((image: thumbnailImage, quality: 0.5, key: "thumbnailPhotoURL"))

    let photoUpdatingGroup = DispatchGroup()
    for _ in images { photoUpdatingGroup.enter() }

    photoUpdatingGroup.notify(queue: DispatchQueue.main, execute: {
      completion(true)
    })
    
    for imageElement in images {
      uploadAvatarForUserToFirebaseStorageUsingImage(imageElement.image, quality: imageElement.quality) { (url) in
        FireStoreChat.shared.checkUerExist(userID: currentUserID) { isExit in
            if isExit {
                userReference.updateData([imageElement.key: url]) { (error) in
                    photoUpdatingGroup.leave()
                }
            } else {
                userReference.setData([imageElement.key: url]) { (error) in
                    photoUpdatingGroup.leave()
                }
            }
            if APPData.appDelegate.loginUserData.count > 0 {
                if imageElement.key == "photoURL" {
                    APPData.appDelegate.loginUserData[0].photoURL = url
                } else {
                    APPData.appDelegate.loginUserData[0].thumbnailPhotoURL = url
                }
            }
        }
        
      }
    }
  }

  typealias DeleteCurrentPhotoCompletionHandler = (_ success: Bool) -> Void
  func deleteCurrentPhoto(completion: @escaping DeleteCurrentPhotoCompletionHandler) {

    guard currentReachabilityStatus != .notReachable, let currentUser = Auth.auth().currentUser?.uid else {
      completion(false)
      return
    }

    let userReference = Firestore.firestore().collection(usersCollection).document(currentUser)
    
    userReference.getDocument { doc, error in
        if error == nil {
            if doc?.data()?.count ?? 0 > 0 {
                guard let userData = doc?.data() as [String: AnyObject]? else { completion(false); return }
                guard let photoURL = userData["photoURL"] as? String,
                  let thumbnailPhotoURL = userData["thumbnailPhotoURL"] as? String,
                  photoURL != "",
                  thumbnailPhotoURL != "" else {
                  completion(true)
                  return
                }
                
                let storage = Storage.storage()
                let photoURLStorageReference = storage.reference(forURL: photoURL)
                let thumbnailPhotoURLStorageReference = storage.reference(forURL: thumbnailPhotoURL)

                let imageRemovingGroup = DispatchGroup()
                imageRemovingGroup.enter()
                imageRemovingGroup.enter()

                imageRemovingGroup.notify(queue: DispatchQueue.main, execute: {
                  completion(true)
                })

                photoURLStorageReference.delete(completion: { (_) in
                    FireStoreChat.shared.checkUerExist(userID: currentUser) { isExit in
                        if isExit {
                            userReference.updateData(["photoURL": ""]) { (error) in
                                imageRemovingGroup.leave()
                            }
                        } else {
                            userReference.setData(["photoURL": ""]) { (error) in
                                imageRemovingGroup.leave()
                            }
                        }
                    }
                    
                  
                })
                
                thumbnailPhotoURLStorageReference.delete(completion: { (_) in
                    FireStoreChat.shared.checkUerExist(userID: currentUser) { isExit in
                        if isExit {
                            userReference.updateData(["thumbnailPhotoURL": ""]) { (error) in
                                imageRemovingGroup.leave()
                            }
                        } else {
                            userReference.setData(["thumbnailPhotoURL": ""]) { (error) in
                                imageRemovingGroup.leave()
                            }
                        }
                    }
                    
                  
                })
            } else {
                completion(false)
            }
        } else {
            completion(false)
        }
    }

  }
}
