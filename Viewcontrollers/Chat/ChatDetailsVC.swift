//
//  ChatDetailsVC.swift
//  BillionsApp
//
//  Created by Tristate on 29.10.21.
//

import UIKit
import SwiftyJSON
import Firebase
import SDWebImage
import FirebaseFirestore
import FirebaseFirestoreSwift
import IQKeyboardManagerSwift
import FTPopOverMenu_Swift
import AVFoundation

enum MsgType: String {
    case text = "Text", photo = "Photo" , video = "Video", audio = "Audio"
}

enum MsgStatus: String {
    case sent = "Sent"
    case delivered = "Delivered"
    case read = "Read"
}

class ChatDetailsVC: BaseViewController {
    // MARK: - Variable
    let storageUploader = StorageMediaUploader()
    let imagesDownloadManager = ImagesDownloadManager()
    
    @IBOutlet var tblChat: UITableView!
    @IBOutlet var btnSend: CustomBtnSFTRegular!
    @IBOutlet var txtComment: CustomeTextView!
    @IBOutlet var constCommentH: NSLayoutConstraint!
    @IBOutlet var viewComment: UIView!
    @IBOutlet var viewMain: UIView!
    @IBOutlet var constViewCommentBottom: NSLayoutConstraint!
    @IBOutlet var viewBottom: UIView!
    @IBOutlet var btnAttach: UIButton!
    @IBOutlet var viewTyping: UIView!
    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet var lblTyping: CustomLblSFPDRegular!
    
    var userData : [UserData] = []
    var listenerUser: ListenerRegistration?
    var listener: ListenerRegistration?
    var listenerDB: ListenerRegistration?
    var listenerTyping : ListenerRegistration?
    
    var msgData : [MessageListModel] = []
    var msgSectionData : [(String,[MessageListModel])] = []
    var lastChatId : Timestamp!
    
    var isTyping = false
    var isForward = false
    var forwardData = [MessageListModel]()
    var msgType : MsgType = .text
    
    var photoImg : UIImage!
    var isGallery = false
    @IBOutlet var navView: UIView!
    @IBOutlet var userImg: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblLastSeen: UILabel!
    
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
    
    let items: [PopupMenuItem] = [
        PopupMenuItem(text: "Document", image: "doc", selected: false, colors: [UIColor.document1Color, UIColor.document2Color]),
        PopupMenuItem(text: "Camera", image: "camera", selected: false, colors: [UIColor.camera1Color, UIColor.camera2Color]),
        PopupMenuItem(text: "Gallery", image: "gallery", selected: false, colors: [UIColor.gallery1Color, UIColor.gallery2Color]),
        PopupMenuItem(text: "Audio", image: "audio", selected: false, colors: [UIColor.audio1Color, UIColor.audio2Color]),
        PopupMenuItem(text: "Location", image: "location", selected: false, colors: [UIColor.location1Color, UIColor.location2Color]),
        PopupMenuItem(text: "Contact", image: "contact", selected: false, colors: [UIColor.contact1Color, UIColor.contact2Color]),
        PopupMenuItem(text: "Poll", image: "poll", selected: false, colors: [UIColor.poll1Color, UIColor.poll2Color])
    ]
    
    var menu: PopupOverGridMenu!
    
    //MARK: - view Life
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        // Cell register
        let cellI = ["ChatReceiverCell", "ChatSenderCell", "PhotoSenderCell", "PhotoReceiverCell", "ChatFooterCell", "ChatHeaderCell", "ChatReceiverDeleteCell", "ChatSenderDeleteCell"]
        cellI.forEach { d in
            self.tblChat.register(UINib.init(nibName: d, bundle: nil), forCellReuseIdentifier: d)
        }
        tblChat.transform = CGAffineTransform(rotationAngle: -(CGFloat)(Double.pi))
        tblChat.estimatedSectionFooterHeight = 30
        tblChat.sectionFooterHeight = UITableView.automaticDimension
        // Keyboard observer
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow1), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide1), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navView.frame = CGRect.init(x: 30, y: 0, width: UIScreen.main.bounds.width, height: navView.frame.height)
        self.navigationController?.navigationBar.addSubview(navView)
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        if isGallery == false {
            let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
            tap.numberOfTapsRequired = 1
            self.tblChat.addGestureRecognizer(tap)
            self.msgData = []
            self.msgSectionData = []
            self.getData()
            self.setTypingListner()
        } else {
            self.isGallery = false
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        if isGallery == false {
            self.listener?.remove()
            self.listenerDB?.remove()
            self.listenerUser?.remove()
            if self.isTyping == true {
                self.startTypingIndictor(isTyping: false)
                self.listenerTyping?.remove()
            }
        }
        navView.removeFromSuperview()
    }
    
    //MARK: - KeyBoard
    @objc func tapAction(){
        self.view.endEditing(true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func keyboardWillShow1(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.constViewCommentBottom.constant =  keyboardSize.height - 8
        }
    }
    
    @objc func keyboardWillHide1(notification: NSNotification) {
        self.constViewCommentBottom.constant = 0
    }
    
    func configureNavigationBar() {
        extendedLayoutIncludesOpaqueBars = true
        lblUserName.text = userData[0].name ?? ""
        lblLastSeen.text = stringStatus(onlineStatus: userData[0].onlineStatus)
        DispatchQueue.main.async {
            guard let urlString = self.userData[0].thumbnailPhotoURL else { return }
            let options: SDWebImageOptions = [.scaleDownLargeImages, .continueInBackground, .avoidAutoSetImage]
            let placeholder = UIImage(named: "UserpicIcon")
            
            self.userImg.sd_setImage(with: URL(string: urlString),
                                     placeholderImage: placeholder,
                                     options: options) { (image, _, cacheType, _) in
                guard image != nil else { return }
                guard cacheType != .memory, cacheType != .disk else {
                    self.userImg.image = image
                    return
                }
                UIView.transition(with: self.userImg, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.userImg.image = image
                }, completion: nil)
            }
        }
    }
    
    //MARK: - Button Action
    @IBAction func btnSendAction(_ sender: Any) {
        if trimString(string: self.txtComment.text ?? "").count > 0 {
            self.btnSend.isUserInteractionEnabled = false
            self.showSpinner()
            sendMsg()
        } else {
            self.view.makeToast(AlertMessage.ALERT_TXT_EMPTY)
        }
    }
    @IBAction func btnCameraAction(_ sender: Any) {
    }
    
    @IBAction func btnAddAction(_ sender: Any) {
        presentPopover()
//        let alert:UIAlertController = UIAlertController(title: "", message: nil, preferredStyle: .actionSheet)
//        let imageAction = UIAlertAction(title: "Image", style: .default) {
//            UIAlertAction in
//            self.msgType = .photo
//            self.isGallery = true
//            self.selectPhotoMsg()
//        }
//        let videoAction = UIAlertAction(title: "Video", style: .default) {
//            UIAlertAction in
//            self.msgType = .video
//            self.isGallery = true
//            self.selectVideoMsg()
//        }
//        
//        let gifAction = UIAlertAction(title: "GIF", style: .default) {
//            UIAlertAction in
//            
//        }
//        
//        let StickerAction = UIAlertAction(title: "Stiker", style: .default) {
//            UIAlertAction in
//            
//        }
//        
//        let cancelAction = UIAlertAction(title: ConstantText.lngCanacel, style: .cancel) {
//            UIAlertAction in
//            self.msgType = .text
//        }
//        alert.addAction(imageAction)
//        alert.addAction(videoAction)
//        alert.addAction(gifAction)
//        alert.addAction(StickerAction)
//        alert.addAction(cancelAction)
//        if let popoverController = alert.popoverPresentationController {
//            popoverController.sourceView = self.view
//            popoverController.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.maxY, width: 0, height: 0)
//            popoverController.permittedArrowDirections = []
//            
//        }
//        self.present(alert, animated: true, completion: nil)
    }
    
    private func selectPhotoMsg(){
        ImagePickerManager.sharedInstance.openCameraAndPhotoLibrary(self) { (img, name, error) in
            guard error == nil,let image = img else { return }
            self.photoImg = image
            self.showSpinner()
            self.storageUploader.uploadThumbnail(createImageThumbnail(image)) { snapshot in
                if (snapshot?.progress?.fractionCompleted) != nil {
                }
            } completion: { thumbUrl in
                self.uploadOriginalImage(thumbUrl: thumbUrl)
            }
        }
    }
    
    private func selectVideoMsg(){
        ImagePickerManager.sharedInstance.openVideoLibrary(self, duration: 120, isEdit: true) { (videoUrl, videoName, error) in
            self.showSpinner()
            do {
                let videoData = try Data(contentsOf: videoUrl!.absoluteURL)
                self.storageUploader.upload(videoData) { snapshot in
                    if (snapshot?.progress?.fractionCompleted) != nil {
                    }
                } completion: { videoUrl1 in
                    if let thumb = getThumbnailImage(forUrl: videoUrl!.absoluteURL) {
                        self.storageUploader.uploadThumbnail(thumb) { snapshot in
                            if (snapshot?.progress?.fractionCompleted) != nil {
                            }
                        } completion: { thumbUrl in
                            self.sendVideoMsg(videoUrl: videoUrl1, thumbUrl: thumbUrl, thumb: thumb, localVideoUrl: videoUrl!.path)
                        }
                    } else {
                        self.sendVideoMsg(videoUrl: videoUrl1, thumbUrl: "", thumb: UIImage(), localVideoUrl: videoUrl!.path)
                    }
                    
                    
                }
            } catch {
                self.hideSpinner()
                print("Unable to load data: \(error)")
            }
            
            
        }
    }
    
    //MARk: - Get Data
    func getData(){
        FireStoreChat.shared.getChatData(docId: self.concatMemberId) { (data) in
            var arr = [MessageListModel]()
            for dataObj in data{
                if self.msgData.count == 0 {
                    self.lastChatId =  (data[0][strtimeStamp] is NSNull) ? nil : (data[0][strtimeStamp] as! Timestamp)
                }
                print(dataObj)
                arr.append(MessageListModel(dictionary: dataObj))
            }
            self.msgData += arr
            if self.msgData.count > 0 {
                self.msgSectionData = self.groupByDate()
            }
            
            self.tblChat.reloadData()
            DispatchQueue.main.async {
                self.tblChat.reloadData()
            }
            
            self.setListner()
            self.setUserListner()
            self.setDbListner()
            self.setForwardChat()
        }
    }
    
    private func setForwardChat(){
        if self.isForward == true {
            if self.forwardData[0].msgType ?? "" == MsgType.photo.rawValue {
                self.msgType = .photo
                self.sendPhotoMsg(imgUrl: self.forwardData[0].imageUrl ?? "", thumbUrl: self.forwardData[0].thumbnailImageUrl ?? "")
            } else if self.forwardData[0].msgType ?? "" == MsgType.video.rawValue {
                self.msgType = .video
                //                self.sendVideoMsg(videoUrl: self.forwardData[0]["videoUrl"] as? String ?? "", thumbUrl: self.forwardData[0]["thumbnailImageUrl"] as? String ?? "", thumb: UIImage(), localVideoUrl: self.forwardData[0]["localVideoUrl"] as? String ?? "")
            } else {
                self.msgType = .text
                self.sendMsg()
            }
        }
    }
    
    private func groupByDate() -> [(String,[MessageListModel])] {
        self.msgSectionData.removeAll()
        self.tblChat.reloadData()
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
}
//MARK: - UITableViewDelegate , UITableViewDataSource
extension ChatDetailsVC : UITableViewDelegate , UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.msgSectionData.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.msgSectionData[section].1.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = self.msgSectionData[indexPath.section].1[indexPath.row]
        if data.SID ?? "" == self.currentUID {
            // Sender Delete Msg
            if data.isDeleteAll ?? false == true {
                let cell = self.tblChat.dequeueReusableCell(withIdentifier: "ChatSenderDeleteCell", for: indexPath) as! ChatSenderDeleteCell
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.setSenderDeleteCell(data)
                cell.btnPopoverCallback = { index , strTitle in
                    self.longPopActionHandel(type: strTitle, indexPath: indexPath)
                }
                return cell
            }
            else if data.msgType ?? "" == MsgType.photo.rawValue || data.msgType ?? "" == MsgType.video.rawValue {
                let cell = self.tblChat.dequeueReusableCell(withIdentifier: "PhotoSenderCell", for: indexPath) as! PhotoSenderCell
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.setSenderPhotoCell(data, indexPath)
                cell.btnPopoverCallback = { index , strTitle in
                    self.longPopActionHandel(type: strTitle, indexPath: indexPath)
                }
                
                cell.MsgImageTapCallback = {
                    self.handleOpen(madiaAt: indexPath)
                }
                return cell
            }
            else { // Sender Msg
                let cell = self.tblChat.dequeueReusableCell(withIdentifier: "ChatSenderCell", for: indexPath) as! ChatSenderCell
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.setSenderCell(data)
                
                cell.btnPopoverCallback = { index, strTitle in
                    self.longPopActionHandel(type: strTitle, indexPath: indexPath)
                }
                return cell
            }
        } else {
            // Receiver Delete Msg
            if data.isDeleteAll ?? false == true {
                let cell = self.tblChat.dequeueReusableCell(withIdentifier: "ChatReceiverDeleteCell", for: indexPath) as! ChatReceiverDeleteCell
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.setReceiverDeleteCell(data, self.userData[0].thumbnailPhotoURL)
                return cell
            } else if data.msgType ?? "" == MsgType.photo.rawValue || self.msgSectionData[indexPath.section].1[indexPath.row].msgType ?? "" == MsgType.video.rawValue{
                let cell = self.tblChat.dequeueReusableCell(withIdentifier: "PhotoReceiverCell", for: indexPath) as! PhotoReceiverCell
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.setReceiverPhotoCell(data, indexPath, self.userData[0].thumbnailPhotoURL)
                cell.btnPopoverCallback = { index , strTitle in
                    self.longPopActionHandel(type: strTitle, indexPath: indexPath)
                }
                
                cell.MsgImageTapCallback = {
                    self.handleOpen(madiaAt: indexPath)
                }
                return cell
            } else { // Receiver Msg
                let cell = self.tblChat.dequeueReusableCell(withIdentifier: "ChatReceiverCell", for: indexPath) as! ChatReceiverCell
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.setReceiverCell(data, self.userData[0].thumbnailPhotoURL)
                
                cell.btnPopoverCallback = { index , strTitle in
                    self.longPopActionHandel(type: strTitle, indexPath: indexPath)
                }
                return cell
            }
        }
    }
    
    //    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    //        let headerCell = self.tblChat.dequeueReusableCell(withIdentifier: "ChatHeaderCell") as! ChatHeaderCell
    //        headerCell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    //        return headerCell
    //    }
    //
    //    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    //        return isTyping && section == 0 ? 30 : 0
    //    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerCell = self.tblChat.dequeueReusableCell(withIdentifier: "ChatFooterCell") as! ChatFooterCell
        DispatchQueue.main.async {
            footerCell.viewBG.isRoundRect = true
        }
        footerCell.lblTitle.text = self.msgSectionData[section].0.convertHeadertDate()
        footerCell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
        return footerCell
    }
}

//MARK: - Tableview Cell Set
extension ChatDetailsVC {
    func longPopActionHandel(type: String , indexPath : IndexPath){
        if type == LongPopMsg.frwd.rawValue {
            let vc = GlobalFunction.fetchViewControllerWithName("FriendsListVC", storyBoardName: AppStoryboard.registration.rawValue) as! FriendsListVC
            vc.isForward = true
            vc.forwardData = [self.msgSectionData[indexPath.section].1[indexPath.row]]
            self.navigationController?.pushViewController(vc, animated: true)
        } else if type == LongPopMsg.like.rawValue {
            var likeusers = self.msgSectionData[indexPath.section].1[indexPath.row].likeUsers ?? [String]()
            let isLike = likeusers.contains(APPData.appDelegate.loginUserData[0].userId ?? "")
            
            if isLike == true {
                likeusers.removeAll(where: {$0 == APPData.appDelegate.loginUserData[0].userId ?? ""})
            } else {
                likeusers.append(APPData.appDelegate.loginUserData[0].userId ?? "")
            }
            if let msgID = self.msgSectionData[indexPath.section].1[indexPath.row].msgID, let chatID = self.msgSectionData[indexPath.section].1[indexPath.row].chatID {
                Firestore.firestore().collection(dataCollection).document(chatID).collection(messageCollection).document(msgID).updateData([strlikeUsers : likeusers])
            }
            
        } else if type == LongPopMsg.deleteAll.rawValue {
            if let msgID = self.msgSectionData[indexPath.section].1[indexPath.row].msgID, let chatID = self.msgSectionData[indexPath.section].1[indexPath.row].chatID {
                Firestore.firestore().collection(dataCollection).document(chatID).collection(messageCollection).document(msgID).updateData([strisDeleteAll : true])
            }
        } else if type == LongPopMsg.delete.rawValue {
            var deleteUsers = self.msgSectionData[indexPath.section].1[indexPath.row].NotDeleteMsgUsers ?? [String]()
            let isDelete = deleteUsers.contains(APPData.appDelegate.loginUserData[0].userId ?? "")
            if isDelete == true {
                for i in 0..<deleteUsers.count {
                    deleteUsers.remove(at: i)
                }
            }
            
            if let msgID = self.msgSectionData[indexPath.section].1[indexPath.row].msgID, let chatID = self.msgSectionData[indexPath.section].1[indexPath.row].chatID {
                Firestore.firestore().collection(dataCollection).document(chatID).collection(messageCollection).document(msgID).updateData([strNotDeleteMsgUsers : deleteUsers])
            }
        }
    }
    
    func handleOpen(madiaAt indexPath: IndexPath) {
        guard let viewController = openSelectedPhoto(at: indexPath) else { return }
        present(viewController, animated: true, completion: nil)
    }
    
    func openSelectedPhoto(at indexPath: IndexPath) -> UIViewController? {
        
        let galleryPreview = GlobalFunction.fetchViewControllerWithName("FullImageVC", storyBoardName: AppStoryboard.registration.rawValue) as! FullImageVC
        galleryPreview.photo = [self.msgSectionData[indexPath.section].1[indexPath.row]]
        
        setupGalleryDismissHandler(galleryPreview: galleryPreview)
        galleryPreview.modalPresentationStyle = .overFullScreen
        galleryPreview.modalPresentationCapturesStatusBarAppearance = true
        return galleryPreview
    }
    
    func setupGalleryDismissHandler(galleryPreview: FullImageVC) {
        galleryPreview.didDismissHandler = { [weak self] viewController in
            guard let unwrappedSelf = self else { return }
            unwrappedSelf.inputAccessoryView?.isHidden = false
            unwrappedSelf.tblChat.performBatchUpdates({
                unwrappedSelf.tblChat.reloadRows(at: unwrappedSelf.tblChat.indexPathsForVisibleRows!, with: .none)
            }, completion: nil)
        }
        
    }
}

//MARK: - UITextViewDelegate
extension ChatDetailsVC: UITextViewDelegate {
    
    func setBottomView() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .curveEaseIn) {
            self.btnCamera.alpha = (self.txtComment.text?.count ?? 0) > 0 ? 0 : 1
            self.btnCamera.isHidden = (self.txtComment.text?.count ?? 0) > 0
        } completion: { _ in
            self.btnCamera.alpha = (self.txtComment.text?.count ?? 0) > 0 ? 0 : 1
            self.btnCamera.isHidden = (self.txtComment.text?.count ?? 0) > 0
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let contentMesureTextField = UITextView()
        contentMesureTextField.frame = self.txtComment.frame
        contentMesureTextField.text = self.txtComment.text
        
        var contentSize = contentMesureTextField.sizeThatFits(contentMesureTextField.bounds.size)
        
        contentSize.height = min(90, contentSize.height)
        var frame = self.txtComment.frame
        frame.size.height = (contentSize.height<44 ? 44 : contentSize.height)
        constCommentH.constant = (contentSize.height<50 ? 50 : contentSize.height)
        self.setBottomView()
    }
    
    func textViewDidEndEditing(_ textView: UITextView)
    {
        self.startTypingIndictor(isTyping: false)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.startTypingIndictor(isTyping: true)
    }
}

//MARK: - Listner Call
extension ChatDetailsVC{
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
                    if (doc[strtimeStamp] != nil) {
                        self.lastChatId = (doc[strtimeStamp] as! Timestamp)
                        print("Tristate:--", doc.data())
                        if self.msgData.count > 0 {
                            let isAdd = self.msgData.filter({$0.timeStamp as? Timestamp == self.lastChatId })
                            if isAdd.count == 0 {
                                var dic = doc.data()
                                dic["msgID"] = doc.documentID
                                
                                Firestore.firestore().collection(dataCollection).document(concatMemberId).collection(messageCollection).document(doc.documentID).updateData(dic)
                                
                                self.msgData.insert(MessageListModel(dictionary: dic), at: 0)
                            }
                        } else {
                            var dic = doc.data()
                            dic["msgID"] = doc.documentID
                            
                            Firestore.firestore().collection(dataCollection).document(concatMemberId).collection("message").document(doc.documentID).updateData(dic)
                            
                            self.msgData.insert(MessageListModel(dictionary: dic), at: 0)
                        }
                        
                    }
                }
                
                self.msgSectionData = self.groupByDate()
                self.tblChat.reloadData()
                DispatchQueue.main.async {
                    self.tblChat.reloadData()
                }
                
                if query.documents.count > 0 {
                    self.listener?.remove()
                    
                    self.setListner()
                }
                
            }
        })
    }
    
    func setDbListner(){
        let ref = Firestore.firestore().collection(dataCollection).document(self.concatMemberId).collection(messageCollection).whereField(strusersIDs, arrayContains: [self.currentUID]).order(by: strtimeStamp, descending: true)
        
        listenerDB = ref.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            
            snapshot.documentChanges.forEach { diff in
                
                
                if (diff.type == .added) {
                    print("Add Data")
                }
                
                if (diff.type == .modified) {
                    
                    let date = convertDateToString(date: getTimestampToDate( (diff.document[strtimeStamp] is NSNull) ? 0 : Int((diff.document[strtimeStamp] as! Timestamp).seconds)))
                    if date != "" {
                        if let section = self.msgSectionData.firstIndex(where: {$0.0 == date}) {
                            
                            if let msgID = diff.document[strmsgID] as? String {
                                if let index = self.msgSectionData[section].1.firstIndex(where: {$0.msgID == msgID }){
                                    let isDelete = (diff.document[strNotDeleteMsgUsers] as? [String] ?? [String]()).contains(APPData.appDelegate.loginUserData[0].userId ?? "")
                                    
                                    if isDelete == false {
                                        self.msgSectionData[section].1.remove(at: index)
                                        self.tblChat.deleteRows(at: [IndexPath.init(row: index, section: section)], with: .none)
                                    } else {
                                        
                                        self.msgSectionData[section].1[index] = MessageListModel(dictionary: diff.document.data())
                                        self.tblChat.reloadRows(at: [IndexPath.init(row: index, section: section)], with: .none)
                                        DispatchQueue.main.async {
                                            self.tblChat.reloadRows(at: [IndexPath.init(row: index, section: section)], with: .none)
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
                    self.lblTyping.text = self.isTyping ? "Typing ...." : ""
                }
                if (diff.type == .modified) {
                    self.isTyping = (diff.document[strtypingIDs] as? [String] ?? [String]()).contains(where: {$0 == self.otherUserMemberID}) ? true : false
                    self.lblTyping.text = self.isTyping ? "Typing ...." : ""
                }
                if (diff.type == .removed) {
                }
            }
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
                                self.configureNavigationBar()
                                self.tblChat.reloadData()
                                
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
}
//MARK: - Set Data and Upload Msg
extension ChatDetailsVC{
    
    private func uploadOriginalImage(thumbUrl : String){
        self.storageUploader.upload(self.photoImg) { snapshot in
            if (snapshot?.progress?.fractionCompleted) != nil {
            }
        } completion: { imgUrl in
            self.sendPhotoMsg(imgUrl: imgUrl, thumbUrl: thumbUrl)
        }
    }
    
    private func startTypingIndictor(isTyping: Bool){
        var dic : [String:Any] = self.getCommonUserData()
        dic[strisTyping] = isTyping
        
        Firestore.firestore().collection(dataCollection).document(self.concatMemberId).getDocument { query, error in
            if error == nil {
                if query?.exists == true {
                    var typeIds: [String] = []
                    if let data = query?.data() {
                        typeIds = data[strtypingIDs] as? [String] ?? [String]()
                    }
                    if typeIds.contains(where: {$0 == self.currentUID}) {
                        typeIds.removeAll(where: {$0 == self.currentUID})
                    } else {
                        typeIds.append(self.currentUID)
                    }
                    Firestore.firestore().collection(dataCollection).document(self.concatMemberId).updateData([strisTyping : isTyping, strtypingIDs : typeIds])
                } else {
                    Firestore.firestore().collection(dataCollection).document(self.concatMemberId).setData(dic)
                }
            }
        }
    }
    
    func sendPhotoMsg(imgUrl: String , thumbUrl : String) {
        let dic = self.getSendPhotoCommonData(imgUrl: imgUrl, thumbUrl: thumbUrl).0.dic
        let dicMain = self.getSendPhotoCommonData(imgUrl: imgUrl, thumbUrl: thumbUrl).1
        
        FireStoreChat.shared.checkChatIDExist(chatID: concatMemberId) { isExit in
            self.isForward = false
            if isExit == false{
                FireStoreChat.shared.addChatMessage(docId: self.concatMemberId, dicParam: dic) { isAdd in
                    self.hideSpinner()
                    self.btnSend.isUserInteractionEnabled = true
                    if isAdd {
                        self.setTextviewRemove()
                        FireStoreChat.shared.setRecentMsg(self.concatMemberId, dicMain)
                    }
                }
            } else {
                FireStoreChat.shared.updateChatMessage(docId: self.concatMemberId, dicParam: dic) { isUpdate in
                    self.hideSpinner()
                    self.btnSend.isUserInteractionEnabled = true
                    if isUpdate {
                        self.setTextviewRemove()
                        FireStoreChat.shared.setRecentMsg(self.concatMemberId, dicMain)
                    }
                }
            }
        }
        
    }
    
    func sendMsg(){
        let dic = self.getSendCommonData().0.dic
        let dicMain = self.getSendCommonData().1
        
        FireStoreChat.shared.checkChatIDExist(chatID: concatMemberId) { isExit in
            self.isForward = false
            if isExit == false {
                FireStoreChat.shared.addChatMessage(docId: self.concatMemberId, dicParam: dic) { isAdd in
                    self.hideSpinner()
                    self.btnSend.isUserInteractionEnabled = true
                    if isAdd {
                        self.setTextviewRemove()
                        FireStoreChat.shared.setRecentMsg(self.concatMemberId, dicMain)
                    }
                }
            } else {
                FireStoreChat.shared.updateChatMessage(docId: self.concatMemberId, dicParam: dic) { isUpdate in
                    self.hideSpinner()
                    self.btnSend.isUserInteractionEnabled = true
                    if isUpdate {
                        self.setTextviewRemove()
                        FireStoreChat.shared.setRecentMsg(self.concatMemberId, dicMain)
                    }
                }
            }
        }
    }
    
    private func setTextviewRemove() {
        self.txtComment.text = ""
        self.textViewDidChange(self.txtComment)
    }
    
    private func sendVideoMsg(videoUrl: String , thumbUrl : String, thumb: UIImage?, localVideoUrl : String){
        guard Auth.auth().currentUser != nil, let currentUID = Auth.auth().currentUser?.uid else { return }
        let currentUserMemberName = APPData.appDelegate.loginUserData[0].name ?? ""
        let SImage = APPData.appDelegate.loginUserData[0].photoURL ?? ""
        let STImage = APPData.appDelegate.loginUserData[0].thumbnailPhotoURL ?? ""
        
        let otherUserMemberID = self.userData[0].userId ?? ""
        let otherUserMemberName = self.userData[0].name ?? ""
        let RImage = self.userData[0].photoURL ?? ""
        let RTImage = self.userData[0].thumbnailPhotoURL ?? ""
        
        
        let message = self.isForward ? self.forwardData[0].message ?? "" : trimString(string: self.txtComment.text ?? "")
        
        var concatMemberId = ""
        var concateMemberArray : [String] = []
        let RName = otherUserMemberName
        let SName = currentUserMemberName
        let RID = otherUserMemberID
        let SID = currentUID
        
        concateMemberArray = [currentUID, otherUserMemberID]
        concateMemberArray = concateMemberArray.sorted()
        
        for str in concateMemberArray {
            concatMemberId = concatMemberId == "" ? str : "\(concatMemberId)-\(str)"
        }
        
        var dic : [String:Any] = [:]
        dic["SImage"] = SImage
        dic["RImage"] = RImage
        dic["STImage"] = STImage
        dic["RTImage"] = RTImage
        dic["SPhoneNumber"] = APPData.appDelegate.loginUserData[0].phoneNumber ?? ""
        dic["RPhoneNumber"] = self.userData[0].phoneNumber ?? ""
        dic["usersIDs"] = concateMemberArray
        dic["SID"] = SID
        dic[strRID] = RID
        dic["SName"] = SName
        dic[strRName] = RName
        dic["message"] = message
        dic["isDeleteAll"] = false
        dic["timeStamp"] = FieldValue.serverTimestamp()
        dic["isGroupChat"] = false
        dic["chatID"] = concatMemberId
        dic["isForwarded"] = self.isForward ? ((self.forwardData[0].SID ?? "" == APPData.appDelegate.loginUserData[0].userId) ? false : self.isForward) : self.isForward
        dic["likeUsers"] = [String]()
        dic["NotDeleteMsgUsers"] = [currentUID,otherUserMemberID]
        dic["likeSymbole"] = [String]()
        dic["msgType"] = msgType.rawValue
        //        dic["imageWidth"] = self.isForward ? self.forwardData[0]["imageWidth"] as? CGFloat ?? 0 : thumb?.size.width ?? 0
        //        dic["imageHeight"] = self.isForward ? self.forwardData[0]["imageHeight"] as? CGFloat ?? 0 : thumb?.size.height ?? 0
        //        dic["videoUrl"] = self.isForward ? self.forwardData[0]["videoUrl"] as? String ?? "" : videoUrl
        //        dic["thumbnailImageUrl"] = self.isForward ? self.forwardData[0]["thumbnailImageUrl"] as? String ?? "" : thumbUrl
        //        dic["localImage"] = self.isForward ? self.forwardData[0]["localImage"] as? Data ?? Data() : thumb!.jpegData(compressionQuality: 0.5) ?? Data()
        //        dic["localVideoUrl"] = self.isForward ? self.forwardData[0]["localVideoUrl"] as? Data ?? Data() : localVideoUrl
        
        FireStoreChat.shared.checkChatIDExist(chatID: concatMemberId) { isExit in
            self.isForward = false
            if isExit == false{
                FireStoreChat.shared.addChatMessage(docId: concatMemberId, dicParam: dic) { isAdd in
                    self.hideSpinner()
                    self.btnSend.isUserInteractionEnabled = true
                    if isAdd {
                        self.txtComment.text = ""
                        self.textViewDidChange(self.txtComment)
                    }
                }
            } else {
                FireStoreChat.shared.updateChatMessage(docId: concatMemberId, dicParam: dic) { isUpdate in
                    self.hideSpinner()
                    self.btnSend.isUserInteractionEnabled = true
                    if isUpdate {
                        self.txtComment.text = ""
                        self.textViewDidChange(self.txtComment)
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
    
    func getSendCommonData() -> (SendMsgData, ChatListData) {
        let message = self.isForward ? self.forwardData[0].message ?? "" : trimString(string: self.txtComment.text ?? "")
        let concateMemberArray : [String] = [currentUID, otherUserMemberID]
        let isForwad = (self.isForward ? ((self.forwardData[0].SID ?? "" == self.currentUID) ? false : self.isForward) : self.isForward)
        
        let dic = SendMsgData(RID: self.otherUserMemberID, SID: self.currentUID, msgType: msgType.rawValue, message: message, timeStamp: FieldValue.serverTimestamp(), id: FieldValue.serverTimestamp(), isGroupChat: false, isForwarded: isForwad, usersIDs: concateMemberArray, chatID: self.concatMemberId, msgID: "", msgStatus: MsgStatus.sent.rawValue, NotDeleteMsgUsers: concateMemberArray, unreadCount: 0, isDeleteAll: false, likeUsers: [], likeSymbole: [])
        
        let dicMain = ChatListData(RName: self.userData[0].name ?? "", RTImage: self.userData[0].thumbnailPhotoURL ?? "", RID: self.otherUserMemberID, onlineStatusR: self.userData[0].onlineStatus!, SName: APPData.appDelegate.loginUserData[0].name ?? "", STImage: APPData.appDelegate.loginUserData[0].thumbnailPhotoURL ?? "", SID: self.currentUID, onlineStatusS: APPData.appDelegate.loginUserData[0].onlineStatus!, msgType: msgType.rawValue, message: message, timeStamp: FieldValue.serverTimestamp(), id: FieldValue.serverTimestamp(), isGroupChat: false, isForwarded: isForwad, usersIDs: concateMemberArray, chatID: self.concatMemberId, msgID: "", msgStatus: MsgStatus.sent.rawValue, NotDeleteMsgUsers: concateMemberArray, unreadCount: 0, isDeleteAll: false)
        return (dic, dicMain)
    }
    func getSendPhotoCommonData(imgUrl: String , thumbUrl : String) -> (SendMsgData, ChatListData) {
        var dic = self.getSendCommonData().0
        dic.imageWidth = self.isForward ? self.forwardData[0].imageWidth ?? 0 : self.photoImg.size.width
        dic.imageHeight = self.isForward ? self.forwardData[0].imageHeight ?? 0 : self.photoImg.size.height
        dic.imageUrl = imgUrl
        dic.thumbnailImageUrl = thumbUrl
        dic.localImage = self.isForward ? self.forwardData[0].localImage ?? Data() : self.photoImg.jpegData(compressionQuality: 0.5) ?? Data()
        
        var dicMain = self.getSendCommonData().1
        dicMain.imageWidth = self.isForward ? self.forwardData[0].imageWidth ?? 0 : self.photoImg.size.width
        dicMain.imageHeight = self.isForward ? self.forwardData[0].imageHeight ?? 0 : self.photoImg.size.height
        dicMain.imageUrl = imgUrl
        dicMain.thumbnailImageUrl = thumbUrl
        dicMain.localImage = self.isForward ? self.forwardData[0].localImage ?? Data() : self.photoImg.jpegData(compressionQuality: 0.5) ?? Data()
        return (dic, dicMain)
    }
}

//MARK: - UIViewControllerPreviewingDelegate
extension ChatDetailsVC: UIViewControllerPreviewingDelegate {
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        guard let indexPath = self.tblChat.indexPathForRow(at: location) else { return nil }
        guard let cell = self.tblChat.cellForRow(at: indexPath) as? PhotoSenderCell else { return nil }
        guard cell.btnDownload.isHidden == true && cell.progressView.isHidden == true else { return nil}
        let sourcePoint = cell.viewMsg.convert(cell.msgImage.frame.origin, to: self.tblChat)
        let sourceRect = CGRect(x: sourcePoint.x, y: sourcePoint.y,
                                width: cell.msgImage.frame.width, height: cell.msgImage.frame.height)
        previewingContext.sourceRect = sourceRect
        //    if let viewController = openSelectedPhoto(at: indexPath) as? INSPhotosViewController {
        //      viewController.view.backgroundColor = .clear
        //            viewController.overlayView.setHidden(true, animated: false)
        //            viewController.currentPhotoViewController?.playerController.player?.play()
        //      let imageView = viewController.currentPhotoViewController?.scalingImageView.imageView
        //      let radius = (imageView?.image?.size.width ?? 20) * 0.05
        //      viewController.currentPhotoViewController?.scalingImageView.imageView.layer.cornerRadius = radius
        //      viewController.currentPhotoViewController?.scalingImageView.imageView.layer.masksToBounds = true
        //      return viewController
        //    }
        return nil
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        //    if let viewController = viewControllerToCommit as? INSPhotosViewController {
        //      viewController.view.backgroundColor = .black
        //      viewController.currentPhotoViewController?.scalingImageView.imageView.layer.cornerRadius = 0
        //      viewController.currentPhotoViewController?.scalingImageView.imageView.layer.masksToBounds = false
        //            viewController.overlayView.setHidden(false, animated: false)
        //      present(viewController, animated: true)
        //    } else if let viewController = viewControllerToCommit as? AVPlayerViewController {
        //      present(viewController, animated: true)
        //    }
    }
}

extension ChatDetailsVC {
    func presentPopover() {
        let itemW = CGFloat(self.view.frame.size.width / 4)
        let itemSize = CGSize(width:itemW , height: 70)
        let viewW = CGFloat(self.view.frame.width / 1.1)
        let cellCount : Int = Int(viewW) / Int(itemW + 10)
        let contentSize = CGSize(width: viewW, height: CGFloat(80 * ((items.count % cellCount == 0) ? items.count / cellCount : (Int(items.count / cellCount) + 1)) ))
        menu = PopupOverGridMenu.presentPopover(self, appear: .fromTop, sender: self.btnAttach, items: items, itemSize: itemSize, direction: .down, contentSize: contentSize, action: { item in
            if item.isSelected {
                print("item selected at index \(self.items.firstIndex(where: {$0 === item})!)")
            } else {
                print("item deselected at index \(self.items.firstIndex(where: {$0 === item})!)")
            }
            self.menu?.dismiss()
        }, completion: {
            self.menu?.dismiss()
            print("completed")
        } )
    }
}
