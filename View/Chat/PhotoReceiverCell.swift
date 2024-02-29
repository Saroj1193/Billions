//
//  PhotoReceiverCell.swift
//  BillionsApp
//
//  Created by Tristate on 09.11.21.
//

import UIKit
import SDWebImage
import FTPopOverMenu_Swift
import Firebase

enum LongPopMsg: String {
    case frwd = "Forward",  report = "Report", deleteme = "Delete for me",deleteAll = "Delete for everyone", reply = "Reply", like = "Like" , delete = "Delete"
}

class PhotoReceiverCell: UITableViewCell {
    weak var chatDetails: ChatDetailsVC? {
        didSet {
            
        }
    }
    
    @IBOutlet var imgUserProfile: UIImageView!
    @IBOutlet var viewMsg: UIView!
    @IBOutlet var viewForward: UIView!
    @IBOutlet var constViewForwardH: NSLayoutConstraint!
    @IBOutlet var lblForward: CustomLblSFPTRegular!
    @IBOutlet var imgForward: UIImageView!
    @IBOutlet var lblTime: CustomLblSFPDRegular!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var lblReceiverMsg: CustomLblSFPTRegular!
    @IBOutlet var msgImage: UIImageView!
    @IBOutlet var btnDownload: UIButton!
    @IBOutlet var progressView: CircleProgress!
    @IBOutlet var constMsgImageH: NSLayoutConstraint!
    @IBOutlet var lblStatus: CustomLblSFPDRegular!
    @IBOutlet var btnPlay: UIButton!
    
    var btnPopoverCallback:((Int,String)->())?
    var MsgImageTapCallback:(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        DispatchQueue.main.async {
            self.imgUserProfile.isRoundRect = true
        }
        
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(setMessageMenu)))
        
        self.msgImage.isUserInteractionEnabled = true
        self.msgImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap(_:))))
    }

    func configureCellContextMenuView() -> FTConfiguration {
        let config = FTConfiguration()
        config.backgoundTintColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        config.borderColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 0.0)
        config.menuWidth = 150
        config.menuSeparatorColor = .clear
        config.menuRowHeight = 40
        config.cornerRadius = 25
        config.textAlignment = .center
        return config
    }
    
    @objc func setMessageMenu(){
        let config = self.configureCellContextMenuView()
        let arr = [LongPopMsg.frwd.rawValue,LongPopMsg.report.rawValue, LongPopMsg.deleteme.rawValue, LongPopMsg.reply.rawValue, LongPopMsg.like.rawValue]
        FTPopOverMenu.showForSender(sender: self, with: arr , menuImageArray: [], popOverPosition: .automatic, config: config) { (index) in
            self.btnPopoverCallback?(index, arr[index])
        } cancel: {
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func btnPlayAction(_ sender: Any) {
        self.MsgImageTapCallback?()
    }
    
    @IBAction func btnDownloadAction(_ sender: Any) {
        guard let indexPath = chatDetails?.tblChat.indexPath(for: self) else { return }
        guard let message = chatDetails?.msgData else { return }
        
//        loadFullSize(message: message, messageImageUrlString: message[indexPath.row]["imageUrl"] as? String ?? "", indexPath: indexPath)
    }
    
    func setReceiverPhotoCell(_ data: MessageListModel, _ indexPath: IndexPath, _ userImg: String?){
        self.setupImageFromURL(data, indexPath)
        
        self.btnLike.isHidden = !(data.likeUsers ?? [String]()).contains(APPData.appDelegate.loginUserData[0].userId ?? "")
        self.viewForward.isHidden = !(data.isForwarded ?? false)
        self.lblForward.text = self.viewForward.isHidden ? "" : "Forwarded"
        self.constViewForwardH.constant = self.viewForward.isHidden ? 0 : 20
        self.lblStatus.isHidden = true
        self.lblStatus.text = ""
        
        DispatchQueue.main.async {
            guard let urlString = userImg else { return }
            let options: SDWebImageOptions = [.scaleDownLargeImages, .continueInBackground, .avoidAutoSetImage]
            let placeholder = UIImage(named: "UserpicIcon")
            self.imgUserProfile.sd_setImage(with: URL(string: urlString),
                                            placeholderImage: placeholder,
                                            options: options) { (image, _, cacheType, _) in
                guard image != nil else { return }
                guard cacheType != .memory, cacheType != .disk else {
                    self.imgUserProfile.image = image
                    return
                }
                UIView.transition(with: self.imgUserProfile, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.imgUserProfile.image = image
                }, completion: nil)
            }
        }
        
        
        self.lblReceiverMsg.text = data.message ?? ""
        self.lblTime.text = timestampOfChatLogMessage(getTimestampToDate( (data.timeStamp is NSNull) ? 0 : Int((data.timeStamp as! Timestamp).seconds)))
    }
    
    func setupImageFromURL(_ data: MessageListModel, _ indexPath: IndexPath) {
        
        if let localImageData = data.localImage {
            self.msgImage.image = UIImage(data: localImageData)
            self.msgImage.isUserInteractionEnabled = true
            self.setImageHW(data)
//            self.btnPlay.isHidden = message[indexPath.row]["videoUrl"] as? String ?? "" == "" && message[indexPath.row]["localVideoUrl"] as? String ?? "" == ""
            return
        }
        
        if let chatDetail = chatDetails, chatDetail.imagesDownloadManager.cellsWithActiveDownloads.contains(indexPath) {
            loadFullSize(data, indexPath)
            return
        }
        
        if data.thumbnailImageUrl ?? "" != "" && data.imageUrl ?? "" == "" {
            loadThumbnail(data, indexPath)
        } else if data.thumbnailImageUrl ?? "" == "" && data.imageUrl ?? "" != "" {
            loadFullSize(data, indexPath)
        } else if data.thumbnailImageUrl ?? "" != "" && data.imageUrl ?? "" != "" {
            if let urlString = data.imageUrl, let url = URL(string: urlString) {
                SDWebImageManager.shared.imageCache.containsImage!( forKey: SDWebImageManager.shared.cacheKey(for: url), cacheType: SDImageCacheType.disk) { (cacheType) in
                    guard cacheType == SDImageCacheType.disk || cacheType == SDImageCacheType.memory else {
                        if let localImageData = data.localImage  {
                            self.msgImage.image = UIImage(data: localImageData)
                            self.setImageHW(data)
                            return
                        }
                        self.loadThumbnail(data, indexPath)
                        return
                    }
                    self.loadFullSize(data, indexPath)
                }
            }
        } else {
            self.msgImage.image = blurredPlaceholder
        }
    }
    
    func setImageHW(_ data: MessageListModel){
        if let w = data.imageWidth , let h = data.imageHeight {
            if w == h {
                self.constMsgImageH.constant = UIScreen.main.bounds.size.width * 0.6
            } else if w > h {
                self.constMsgImageH.constant = (UIScreen.main.bounds.size.width * 0.6 * h) / w
            } else {
                self.constMsgImageH.constant = (UIScreen.main.bounds.size.width * 0.6 * h) / w
            }
           
            self.msgImage.image = self.msgImage.image?.sd_resizedImage(with: CGSize(width: UIScreen.main.bounds.size.width * 0.6, height: self.constMsgImageH.constant), scaleMode: .aspectFill)
        }
    }
    
    fileprivate func loadThumbnail(_ data: MessageListModel, _ indexPath: IndexPath) {
        guard let urlString = data.thumbnailImageUrl, let messageImageUrl = URL(string: urlString) else { return }
        let options: SDWebImageOptions = [.continueInBackground, .scaleDownLargeImages, .avoidAutoSetImage, .highPriority]
        
        self.btnDownload.isHidden = false
        
        if urlString != "" {
            self.msgImage.sd_setImage(with: messageImageUrl, completed: nil)
            return
        }
        
        self.msgImage.sd_setImage(
            with: messageImageUrl,
            placeholderImage: blurredPlaceholder,
            options: options,
            completed: { (image, error, cacheType, _) in
                
                guard let image = image else {
                    self.msgImage.image = blurredPlaceholder
                    return
                }
                
                guard cacheType != SDImageCacheType.memory, cacheType != SDImageCacheType.disk else {
                    self.msgImage.image = blurEffect(image: image)
                    return
                }
                
                UIView.transition(with: self.msgImage, duration: 0.1, options: .transitionCrossDissolve, animations: { self.msgImage.image = blurEffect(image: image)
                    self.setImageHW(data)
                }, completion: nil)
            })
    }
    
    fileprivate func loadFullSize(_ data: MessageListModel, _ indexPath: IndexPath) {
        guard let urlString = data.imageUrl, let messageImageUrl = URL(string: urlString) else { return }
        
        chatDetails?.imagesDownloadManager.addCell(at: indexPath)
        progressView.startLoading()
        progressView.isHidden = false
        btnDownload.isHidden = true
        let options: SDWebImageOptions = [.continueInBackground, .scaleDownLargeImages]
        
        msgImage.sd_setImage(
            with: messageImageUrl,
            placeholderImage: blurredPlaceholder,
            options: options,
            progress: { (_, _, _) in
                DispatchQueue.main.async {
                    self.progressView.progress = self.msgImage.sd_imageProgress.fractionCompleted
                }
            }, completed: { (image, error, _, _) in
                if error != nil {
                    self.progressView.isHidden = false
                    self.msgImage.isUserInteractionEnabled = false
                    self.btnPlay.isHidden = true
                    return
                }
                
                self.chatDetails?.imagesDownloadManager.removeCell(at: indexPath)
                self.progressView.isHidden = true
                self.msgImage.isUserInteractionEnabled = true
                self.setImageHW(data)
//                self.btnPlay.isHidden = message[indexPath.row]["videoUrl"] as? String ?? "" == "" && message[indexPath.row]["localVideoUrl"] as? String ?? "" == ""
            })
    }
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        self.MsgImageTapCallback?()
    }
}
