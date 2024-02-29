//
//  ChatListCell.swift
//  BillionsApp
//
//  Created by Tristate on 02.11.21.
//

import UIKit
import Firebase
import SDWebImage

class ChatListCell: UITableViewCell {
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblName: CustomLblSFPDBold!
    @IBOutlet var lblTime: CustomLblSFPTRegular!
    @IBOutlet var lblMsg: CustomLblSFPTRegular!
    @IBOutlet var lblBadgeCOunt: CustomLblSFPTRegular!
    @IBOutlet var btnImg: UIButton!
    @IBOutlet var imgMedia: UIImageView!
    @IBOutlet var constImgMediaW: NSLayoutConstraint!
    
    var btnProfilecallBack:(()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.imgUser.isRoundRect = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func btnImgAction(_ sender: Any) {
        btnProfilecallBack?()
    }
    // MARK: - Sender Cell
    func setSenderCall(_ data: MessageData){
        self.imgMedia.isHidden = data.msgType ?? "" == MsgType.text.rawValue
        self.constImgMediaW.constant = self.imgMedia.isHidden ? 0 : 15
        
        if data.msgType ?? "" == MsgType.photo.rawValue {
            self.imgMedia.image = UIImage(systemName: "photo")
        } else if data.msgType ?? "" == MsgType.video.rawValue {
            self.imgMedia.image = UIImage(systemName: "video.fill")
        }
        
        guard let urlString = data.STImage else { return }
        let options: SDWebImageOptions = [.scaleDownLargeImages, .continueInBackground, .avoidAutoSetImage]
        let placeholder = UIImage(named: "UserpicIcon")
        self.imgUser.sd_setImage(with: URL(string: urlString),
                         placeholderImage: placeholder,
                         options: options) { (image, _, cacheType, _) in
          guard image != nil else { return }
          guard cacheType != .memory, cacheType != .disk else {
            self.imgUser.image = image
            return
          }
          UIView.transition(with: self.imgUser, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.imgUser.image = image
          }, completion: nil)
        }
        
        self.lblMsg.text = self.imgMedia.isHidden ? data.message ?? "" : data.msgType ?? ""
        self.lblName.text = data.SName ?? ""
        self.lblTime.text = timeAgoChatList(getTimestampToDate( (data.timeStamp is NSNull) ? 0 : Int((data.timeStamp as! Timestamp).seconds)))
    }
    
    // MARK: - Receiver Cell
    func setReceiverCall(_ data: MessageData){
        self.imgMedia.isHidden = data.msgType  ?? "" == MsgType.text.rawValue
        self.constImgMediaW.constant = self.imgMedia.isHidden ? 0 : 15
        
        if data.msgType  ?? "" == MsgType.photo.rawValue {
            self.imgMedia.image = UIImage(systemName: "photo")
        } else if data.msgType  ?? "" == MsgType.video.rawValue {
            self.imgMedia.image = UIImage(systemName: "video.fill")
        }
        
        guard let urlString = data.RTImage else { return }
        let options: SDWebImageOptions = [.scaleDownLargeImages, .continueInBackground, .avoidAutoSetImage]
        let placeholder = UIImage(named: "UserpicIcon")
        self.imgUser.sd_setImage(with: URL(string: urlString),
                         placeholderImage: placeholder,
                         options: options) { (image, _, cacheType, _) in
          guard image != nil else { return }
          guard cacheType != .memory, cacheType != .disk else {
            self.imgUser.image = image
            return
          }
          UIView.transition(with: self.imgUser, duration: 0.2, options: .transitionCrossDissolve, animations: {
            self.imgUser.image = image
          }, completion: nil)
        }
        
        self.lblMsg.text = self.imgMedia.isHidden ? data.message ?? "" : data.msgType ?? ""
        self.lblName.text = data.RName ?? ""
        self.lblTime.text = timeAgoChatList(getTimestampToDate( (data.timeStamp is NSNull) ? 0 : Int((data.timeStamp as! Timestamp).seconds)))
    }
}
