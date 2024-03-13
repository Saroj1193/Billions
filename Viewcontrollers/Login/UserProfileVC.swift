//
//  UserProfileVC.swift
//  BillionsApp
//
//  Created by Tristate on 27.10.21.
//

import UIKit
import Firebase
import SDWebImage

enum PageType: Int {
    case create, edit
}
class UserProfileVC: BaseViewController {
    // MARK: - Variable
    @IBOutlet var lblAddPhoto: CustomLblSFPDRegular!
    @IBOutlet var imgPhoto: ProfileImageView!
    @IBOutlet var txtName: CustomeTextField!
    @IBOutlet var txtPhone: CustomeTextField!
    @IBOutlet var txtBio: CustomeTextField!
    var rightBarButton : UIBarButtonItem!
    
    var number = ""
    let userProfileDataDatabaseUpdater = UserProfileDataDatabaseUpdater()
    var type : PageType = .create
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(openUserProfilePicture))
        tap.numberOfTapsRequired = 1
        imgPhoto.isUserInteractionEnabled = true
        imgPhoto.addGestureRecognizer(tap)
        self.lblAddPhoto.text = strAddPhoto
        if type == .edit {
            setProfileData()
        }
    }
    
    fileprivate func configureNavigationBar() {
        extendedLayoutIncludesOpaqueBars = true
        rightBarButton = UIBarButtonItem(title: strDone, style: .done, target: self, action: #selector(rightBarButtonDidTap))
        navigationItem.rightBarButtonItem = rightBarButton
        navigationItem.title = strProfile
        rightBarButton.isEnabled = false
        
        navigationItem.setHidesBackButton(!(type == .edit), animated: true)
        self.txtPhone.text = number
    }
    
    private func setProfileData(){
        self.txtBio.text = APPData.appDelegate.loginUserData[0].bio ?? ""
        self.txtName.text = APPData.appDelegate.loginUserData[0].name ?? ""
        self.txtPhone.text = APPData.appDelegate.loginUserData[0].phoneNumber ?? ""
        
        guard let urlString = APPData.appDelegate.loginUserData[0].thumbnailPhotoURL else { return }
        let options: SDWebImageOptions = [.scaleDownLargeImages, .continueInBackground, .avoidAutoSetImage]
        let placeholder = UIImage(named: "UserpicIcon")
        self.imgPhoto.sd_setImage(with: URL(string: urlString), placeholderImage: placeholder, options: options) { (image, _, cacheType, _) in
          guard image != nil else { return }
          guard cacheType != .memory, cacheType != .disk else {
            self.imgPhoto.image = image
            return
          }
          UIView.transition(with: self.imgPhoto, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.imgPhoto.image = image
          }, completion: nil)
        }
        
        DispatchQueue.main.async {
            self.imgPhoto.isRoundRect = true
        }
    }
    
    @objc fileprivate func openUserProfilePicture() {
        guard currentReachabilityStatus != .notReachable else {
            basicErrorAlertWith(title: basicErrorTitleForAlert, message: noInternetError, controller: self)
            return
        }
        ImagePickerManager.sharedInstance.openCameraAndPhotoLibrary(self) { (img, name, error) in
            guard error == nil,let image = img else { return }
            self.imgPhoto.showActivityIndicator()
            self.userProfileDataDatabaseUpdater.deleteCurrentPhoto { [weak self] (_) in
                self?.userProfileDataDatabaseUpdater.updateUserProfile(with: image, completion: { [weak self] (isUpdated) in
                    self?.imgPhoto.hideActivityIndicator()
                    guard isUpdated, self != nil else {
                        basicErrorAlertWith(title: basicErrorTitleForAlert, message: thumbnailUploadError, controller: self!)
                        return
                    }
                    self?.imgPhoto.image = image
                })
            }
        }
    }
    
    @objc func rightBarButtonDidTap () {
        self.txtName.resignFirstResponder()
        self.txtBio.resignFirstResponder()
        if self.txtName.text?.count == 0 || self.txtName.text!.trimmingCharacters(in: .whitespaces).isEmpty {
            self.view.makeToast("Please fill the details")
        } else {
            if currentReachabilityStatus == .notReachable {
                basicErrorAlertWith(title: "No internet connection", message: noInternetError, controller: self)
                return
            }
            updateUserData()
        }
    }
    
    @objc func profilePictureDidSet() {
        if imgPhoto.image == nil {
            lblAddPhoto.isHidden = false
        } else {
            lblAddPhoto.isHidden = true
        }
    }
    
    fileprivate func preparedPhoneNumber() -> String {
        guard let number = self.txtPhone.text else {
            return self.txtPhone.text!
        }
        return number
    }
    
    func updateUserData() {
        guard let currentUID = Auth.auth().currentUser?.uid else { return }
        self.showSpinner()
        let phoneNumber = preparedPhoneNumber()
        let dicParam = UserDataStr(name: self.txtName.text ?? "", phoneNumber: phoneNumber, bio: self.txtBio.text ?? "", OnlineStatus: statusOnline, userId: currentUID).dic
        
        FireStoreChat.shared.checkUerExist(userID: currentUID) { isExit in
            
            if !isExit {
                FireStoreChat.shared.addUser(userID: currentUID, dicParam: dicParam) { isAdd in
                    self.hideSpinner()
                    FireStoreChat.shared.getUserDetails(docId: currentUID) { data in
                        if data.count > 0 {
                            APPData.appDelegate.loginUserData = [UserData.init(dictionary: data[0])]
                            self.pushChatList()
                        }
                    }
                    
                    if Messaging.messaging().fcmToken != nil {
                        setUserNotificationToken(token: Messaging.messaging().fcmToken!)
                    }
                }
            } else {
                FireStoreChat.shared.updateUserProfile(userID: currentUID, dicParam: dicParam) { isUpdate in
                    self.hideSpinner()
                    FireStoreChat.shared.getUserDetails(docId: currentUID) { data in
                        if data.count > 0 {
                            APPData.appDelegate.loginUserData = [UserData.init(dictionary: data[0])]
                            self.pushChatList()
                        }
                    }
                    if Messaging.messaging().fcmToken != nil {
                        setUserNotificationToken(token: Messaging.messaging().fcmToken!)
                    }
                }
            }
            setOnlineStatus()
        }
    }
    
    func pushChatList(){
        if type == .edit {
            self.navigationController?.popViewController(animated: true)
        } else {
            let vc = GlobalFunction.fetchViewControllerWithName("ChatListVC", storyBoardName: AppStoryboard.registration.rawValue) as! ChatListVC
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}
// MARK: - UITextFieldDelegate
extension UserProfileVC : UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        rightBarButton.isEnabled = true
    }
}
