//
//  ChatDeleteCell.swift
//  BillionsApp
//
//  Created by Tristate on 11.11.21.
//

import UIKit
import FTPopOverMenu_Swift
import SDWebImage
import Firebase

class ChatSenderDeleteCell: UITableViewCell {
    @IBOutlet var viewDelete: UIView!
    @IBOutlet var lblDeleteMsg: CustomLblSFPTRegular!
    @IBOutlet var lbltime: CustomLblSFPDRegular!
    @IBOutlet var imgDelete: UIImageView!
    @IBOutlet var imgProfile: UIImageView!
    
    var btnPopoverCallback:((Int,String)->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.imgProfile.isRoundRect = true
        }
        self.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(setMessageMenu)))
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
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
        let arr = [LongPopMsg.delete.rawValue]
        FTPopOverMenu.showForSender(sender: self, with: arr , menuImageArray: [], popOverPosition: .automatic, config: config) { (index) in
            self.btnPopoverCallback?(index, arr[index])
        } cancel: {
        }
    }
    
    func setSenderDeleteCell(_ data: MessageListModel){
        DispatchQueue.main.async {
            guard let urlString = APPData.appDelegate.loginUserData[0].thumbnailPhotoURL else { return }
            let options: SDWebImageOptions = [.scaleDownLargeImages, .continueInBackground, .avoidAutoSetImage]
            let placeholder = UIImage(named: "UserpicIcon")
            
            self.imgProfile.sd_setImage(with: URL(string: urlString),
                                        placeholderImage: placeholder,
                                        options: options) { (image, _, cacheType, _) in
                guard image != nil else { return }
                guard cacheType != .memory, cacheType != .disk else {
                    self.imgProfile.image = image
                    return
                }
                UIView.transition(with: self.imgProfile, duration: 0.2, options: .transitionCrossDissolve, animations: {
                    self.imgProfile.image = image
                }, completion: nil)
            }
        }
        
        
        self.lbltime.text = timestampOfChatLogMessage(getTimestampToDate( (data.timeStamp is NSNull) ? 0 : Int((data.timeStamp as! Timestamp).seconds)))
    }
}
