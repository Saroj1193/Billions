//
//  ChatReceiverDeleteCell.swift
//  BillionsApp
//
//  Created by Tristate on 11.11.21.
//

import UIKit
import SDWebImage
import Firebase

class ChatReceiverDeleteCell: UITableViewCell {

    @IBOutlet var viewDelete: UIView!
    @IBOutlet var lblDeleteMsg: CustomLblSFPTRegular!
    @IBOutlet var lbltime: CustomLblSFPDRegular!
    @IBOutlet var imgDelete: UIImageView!
    @IBOutlet var imgProfile: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.imgProfile.isRoundRect = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setReceiverDeleteCell(_ data: MessageListModel, _ userImg: String? ){
        DispatchQueue.main.async {
            guard let urlString = userImg else { return }
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
