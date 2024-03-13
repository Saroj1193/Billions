//
//  ChatReceiverTableViewCell.swift
//  
//
//  Created by  on 12/07/17.
//  Copyright © 2017 . All rights reserved.
//

import UIKit
import FTPopOverMenu_Swift
import SDWebImage
import Firebase

let blurredPlaceholder = blurEffect(image: UIImage(named: "blurPlaceholder")!)

class ChatReceiverCell: BaseTableViewCell {
    @IBOutlet var imgUserProfile: UIImageView!
    @IBOutlet var viewMsg: UIView!
    @IBOutlet var viewForward: UIView!
    @IBOutlet var constViewForwardH: NSLayoutConstraint!
    @IBOutlet var lblForward: CustomLblSFPTRegular!
    @IBOutlet var imgForward: UIImageView!
    @IBOutlet var lblTime: CustomLblSFPDRegular!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var lblReceiverMsg: CustomLblSFPTRegular!
    
    var btnPopoverCallback:((Int, String)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        DispatchQueue.main.async {
            self.imgUserProfile.isRoundRect = true
        }
        
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(setMessageMenu)))
        self.view1 = self.viewMsg
        self.img = self.imgUserProfile
        self.setSwipeGesture()
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
        FTPopOverMenu.showForSender(sender: self, with: arr, menuImageArray: [], popOverPosition: .automatic, config: config) { (index) in
            self.btnPopoverCallback?(index, arr[index])
        } cancel: {
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setReceiverCell(_ data: MessageListModel, _ userImg: String?){
        self.btnLike.isHidden = !(data.likeUsers ?? [String]()).contains(APPData.appDelegate.loginUserData[0].userId ?? "")
        self.viewForward.isHidden = !(data.isForwarded ?? false)
        self.lblForward.text = self.viewForward.isHidden ? "" : "Forwarded"
        self.constViewForwardH.constant = self.viewForward.isHidden ? 0 : 20
        
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
}
