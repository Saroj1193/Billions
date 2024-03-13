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
import EmojiPicker

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
    var viewModel: ChatDetailsFireStoreViewModel!
    
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
    @IBOutlet weak var btnSmile: UIButton!
    @IBOutlet var lblTyping: CustomLblSFPDRegular!
    
    // Top navigation
    @IBOutlet var navView: UIView!
    @IBOutlet var userImg: UIImageView!
    @IBOutlet var lblUserName: UILabel!
    @IBOutlet var lblLastSeen: UILabel!
    
    
    // View Reply
    @IBOutlet weak var viewReply: UIView!
    @IBOutlet weak var lblReplyName: UILabel!
    @IBOutlet weak var lblReplyMsg: UILabel!
    @IBOutlet weak var btnReplayClose: UIButton!
    @IBOutlet weak var constViewReplayH: NSLayoutConstraint!
    @IBOutlet weak var viewReplyLine: UIView!
    @IBOutlet weak var viewReplyDetail: UIView!
    @IBOutlet weak var imgReply: UIImageView!
    
    var msgSectionData : [(String,[MessageListModel])] = []
    var isGallery = false
    
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
    var selectedMenu: PopupMenuItem?
    
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
        self.viewModel.delegate = self
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
            self.viewModel.setTypingListner()
        } else {
            self.isGallery = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
        if isGallery == false {
            self.viewModel.listener?.remove()
            self.viewModel.listenerDB?.remove()
            self.viewModel.listenerUser?.remove()
            if self.viewModel.isTyping == true {
                self.viewModel.startTypingIndictor(isTyping: false)
                self.viewModel.listenerTyping?.remove()
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
        lblUserName.text = self.viewModel.userData[0].name ?? ""
        lblLastSeen.text = stringStatus(onlineStatus: self.viewModel.userData[0].onlineStatus)
        DispatchQueue.main.async {
            guard let urlString = self.viewModel.userData[0].thumbnailPhotoURL else { return }
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
    @IBAction func btnSmileAction(_ sender: UIButton) {
//        let viewController = EmojiPickerViewController()
////                viewController.delegate = self
//        viewController.sourceView = sender
//        present(viewController, animated: true)
    }
    
    @IBAction func btnSendAction(_ sender: Any) {
        if trimString(string: self.txtComment.text ?? "").count > 0 {
            self.btnSend.isUserInteractionEnabled = false
            self.showSpinner()
            self.viewModel.sendMsg(text: self.txtComment.text ?? "")
        } else {
            self.view.makeToast(AlertMessage.ALERT_TXT_EMPTY)
        }
    }
    
    @IBAction func btnCameraAction(_ sender: Any) {
        
    }
    
    @IBAction func btnReplayCloseAction(_ sender: Any) {
        self.constViewReplayH.constant = 0
        self.viewReply.isHidden = true
        self.viewModel.replyMsg = nil
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
        ImagePickerManager.sharedInstance.openPhotoLibrary(self, isEdit: true) { (img, name, error) in
            guard error == nil,let image = img else { return }
            self.viewModel.photoImg = image
            self.showSpinner()
            self.storageUploader.uploadThumbnail(createImageThumbnail(image)) { snapshot in
                if (snapshot?.progress?.fractionCompleted) != nil {
                }
            } completion: { thumbUrl in
                self.uploadOriginalImage(thumbUrl: thumbUrl)
            }
        }
//        ImagePickerManager.sharedInstance.openCameraAndPhotoLibrary(self) { (img, name, error) in
//            guard error == nil,let image = img else { return }
//            self.viewModel.photoImg = image
//            self.showSpinner()
//            self.storageUploader.uploadThumbnail(createImageThumbnail(image)) { snapshot in
//                if (snapshot?.progress?.fractionCompleted) != nil {
//                }
//            } completion: { thumbUrl in
//                self.uploadOriginalImage(thumbUrl: thumbUrl)
//            }
//        }
    }
    
    private func selectCameraPhotoMsg(){
        ImagePickerManager.sharedInstance.openCamara(self, isEdit: true) { (img, name, error) in
            guard error == nil,let image = img else { return }
            self.viewModel.photoImg = image
            self.showSpinner()
            self.storageUploader.uploadThumbnail(createImageThumbnail(image)) { snapshot in
                if (snapshot?.progress?.fractionCompleted) != nil {
                }
            } completion: { thumbUrl in
                self.uploadOriginalImage(thumbUrl: thumbUrl)
            }
        }
//        ImagePickerManager.sharedInstance.openCameraAndPhotoLibrary(self) { (img, name, error) in
//            guard error == nil,let image = img else { return }
//            self.viewModel.photoImg = image
//            self.showSpinner()
//            self.storageUploader.uploadThumbnail(createImageThumbnail(image)) { snapshot in
//                if (snapshot?.progress?.fractionCompleted) != nil {
//                }
//            } completion: { thumbUrl in
//                self.uploadOriginalImage(thumbUrl: thumbUrl)
//            }
//        }
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
                            self.viewModel.sendVideoMsg(videoUrl: videoUrl1, thumbUrl: thumbUrl, thumb: thumb, localVideoUrl: videoUrl!.path, text: self.txtComment.text ?? "")
                        }
                    } else {
                        self.viewModel.sendVideoMsg(videoUrl: videoUrl1, thumbUrl: "", thumb: UIImage(), localVideoUrl: videoUrl!.path, text: self.txtComment.text ?? "")
                    }
                    
                    
                }
            } catch {
                self.hideSpinner()
                print("Unable to load data: \(error)")
            }
        }
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
        if data.SID ?? "" == self.viewModel.currentUID {
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
                cell.replyCallBack = {
                    self.viewModel.replyMsg = data
                    if let data = self.viewModel.replyMsg {
                        self.setReplyMsg(data)
                    }
                }
                return cell
            }
            else { // Sender Msg
                let cell = self.tblChat.dequeueReusableCell(withIdentifier: "ChatSenderCell", for: indexPath) as! ChatSenderCell
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.setSenderCell(data, self.viewModel.userData[0].name ?? "" )
                
                cell.btnPopoverCallback = { index, strTitle in
                    self.longPopActionHandel(type: strTitle, indexPath: indexPath)
                }
                cell.replyCallBack = {
                    self.viewModel.replyMsg = data
                    if let data = self.viewModel.replyMsg {
                        self.setReplyMsg(data)
                    }
                }
                return cell
            }
        } else {
            // Receiver Delete Msg
            if data.isDeleteAll ?? false == true {
                let cell = self.tblChat.dequeueReusableCell(withIdentifier: "ChatReceiverDeleteCell", for: indexPath) as! ChatReceiverDeleteCell
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.setReceiverDeleteCell(data, self.viewModel.userData[0].thumbnailPhotoURL)
                return cell
            } else if data.msgType ?? "" == MsgType.photo.rawValue || self.msgSectionData[indexPath.section].1[indexPath.row].msgType ?? "" == MsgType.video.rawValue{
                let cell = self.tblChat.dequeueReusableCell(withIdentifier: "PhotoReceiverCell", for: indexPath) as! PhotoReceiverCell
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.setReceiverPhotoCell(data, indexPath, self.viewModel.userData[0].thumbnailPhotoURL)
                cell.btnPopoverCallback = { index , strTitle in
                    self.longPopActionHandel(type: strTitle, indexPath: indexPath)
                }
                
                cell.MsgImageTapCallback = {
                    self.handleOpen(madiaAt: indexPath)
                }
                cell.replyCallBack = {
                    self.viewModel.replyMsg = data
                    if let data = self.viewModel.replyMsg {
                        self.setReplyMsg(data)
                    }
                }
                return cell
            } else { // Receiver Msg
                let cell = self.tblChat.dequeueReusableCell(withIdentifier: "ChatReceiverCell", for: indexPath) as! ChatReceiverCell
                cell.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                cell.setReceiverCell(data, self.viewModel.userData[0].thumbnailPhotoURL)
                
                cell.btnPopoverCallback = { index , strTitle in
                    self.longPopActionHandel(type: strTitle, indexPath: indexPath)
                }
                cell.replyCallBack = {
                    self.viewModel.replyMsg = data
                    if let data = self.viewModel.replyMsg {
                        self.setReplyMsg(data)
                    }
                }
                return cell
            }
        }
    }
    
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

extension ChatDetailsVC {
    func setReplyMsg(_ data: MessageListModel){
        self.btnReplayClose.setTitle("", for: .normal)
        self.constViewReplayH.constant = 40
        self.viewReply.isHidden = false
        
        self.lblReplyName.textColor = data.SID ?? "" == self.viewModel.currentUID ? UIColor.reply2Color :  UIColor.reply1Color
        self.viewReplyDetail.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        self.viewReplyLine.backgroundColor = data.SID ?? "" == self.viewModel.currentUID ? UIColor.reply2Color :  UIColor.reply1Color
        self.viewReplyDetail.addShadow(offset: CGSize(width: 0, height: 1), color: UIColor.black.withAlphaComponent(0.2), radius: 3, opacity: 1)
        self.btnReplayClose.addShadow(offset: CGSize(width: 0, height: 1), color: UIColor.bwColor!.withAlphaComponent(0.2), radius: 3, opacity: 1)
        
        viewReplyLine.setCorner(corners: [.layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 5)
        self.lblReplyName.text = data.SID ?? "" == self.viewModel.currentUID ? "You" : self.viewModel.userData[0].name
        self.lblReplyMsg.text = (data.msgType ?? "" == MsgType.photo.rawValue || data.msgType ?? "" == MsgType.video.rawValue ) ? data.msgType ?? "" : data.message ?? ""
        
        self.imgReply.isHidden = !(data.msgType ?? "" == MsgType.photo.rawValue || data.msgType ?? "" == MsgType.video.rawValue )
        self.imgReply.sd_setImage(with: URL(string: data.imageUrl ?? ""))
        self.imgReply.setCorner(corners: [.layerMaxXMinYCorner, .layerMaxXMaxYCorner], radius: 5)
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
                Firestore.firestore().collection(dataCollection).document(chatID).collection(messageCollection).document(msgID).updateData([strlikeUsers : likeusers, strUpdateAt: FieldValue.serverTimestamp()])
            }
            
        } else if type == LongPopMsg.deleteAll.rawValue {
            if let msgID = self.msgSectionData[indexPath.section].1[indexPath.row].msgID, let chatID = self.msgSectionData[indexPath.section].1[indexPath.row].chatID {
                Firestore.firestore().collection(dataCollection).document(chatID).collection(messageCollection).document(msgID).updateData([strisDeleteAll : true, strUpdateAt: FieldValue.serverTimestamp()])
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
                Firestore.firestore().collection(dataCollection).document(chatID).collection(messageCollection).document(msgID).updateData([strNotDeleteMsgUsers : deleteUsers, strUpdateAt: FieldValue.serverTimestamp()])
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
        self.viewModel.startTypingIndictor(isTyping: false)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.viewModel.startTypingIndictor(isTyping: true)
    }
}

extension ChatDetailsVC: ChatDetailsFireStoreDelegate {
    func getData(_ data: [(String, [MessageListModel])], _ isScroll: Bool) {
        self.msgSectionData = data
        self.tblChat.reloadData()
        DispatchQueue.main.async {
            self.tblChat.reloadData()
        }
        if isScroll {
            self.tblChat.scrollToRow(at: IndexPath.init(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    func sendMessage(_ isSucess: Bool) {
        self.hideSpinner()
        self.btnSend.isUserInteractionEnabled = true
        if isSucess {
            self.setTextviewRemove()
        }
    }
    
    func sendTyping(_ isTyping: Bool) {
        self.lblTyping.text = isTyping ? "Typing ...." : ""
    }
    
    func userListner() {
        self.configureNavigationBar()
        self.tblChat.reloadData()
    }
}

//MARK: - Set Data and Upload Msg
extension ChatDetailsVC{
    private func uploadOriginalImage(thumbUrl : String){
        self.storageUploader.upload(self.viewModel.photoImg) { snapshot in
            if (snapshot?.progress?.fractionCompleted) != nil {
            }
        } completion: { imgUrl in
            self.viewModel.sendPhotoMsg(imgUrl: imgUrl, thumbUrl: thumbUrl, text: self.txtComment.text ?? "")
        }
    }
    
    private func setTextviewRemove() {
        self.txtComment.text = ""
        self.textViewDidChange(self.txtComment)
        self.viewModel.replyMsg = nil
        self.constViewReplayH.constant = 0
        self.viewReply.isHidden = true
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
            self.selectedMenu = item
            self.menu?.dismiss()
        }, completion: {
            print("completed")
            if let item = self.selectedMenu {
                if item.text == "Gallery" {
                    self.viewModel.msgType = .photo
                    self.isGallery = true
                    self.selectPhotoMsg()
                } else if item.text == "Camera" {
                    self.viewModel.msgType = .photo
                    self.isGallery = true
                    self.selectCameraPhotoMsg()
                }
                self.selectedMenu = nil
            }
        } )
    }
}
