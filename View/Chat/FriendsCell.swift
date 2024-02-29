//
//  FriendsCell.swift
//  BillionsApp
//
//  Created by Tristate on 28.10.21.
//

import UIKit
import SDWebImage

class FriendsCell: UITableViewCell {
    @IBOutlet var imgUser: UIImageView!
    @IBOutlet var lblName: CustomLblSFPDMedium!
    @IBOutlet var lblBio: CustomLblSFPDRegular!
    @IBOutlet var imgOnline: UIImageView!
    @IBOutlet weak var lineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.lblBio.textColor = UIColor.bwColor?.withAlphaComponent(0.5)
        self.lineView.backgroundColor = UIColor.bwColor?.withAlphaComponent(0.2)
        DispatchQueue.main.async {
            self.imgUser.isRoundRect = true
            self.imgOnline.isRoundRect = true
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setFriendsCell(data: UserData) {
        self.lblName.text = data.name ?? ""
        self.lblBio.text = data.bio ?? ""
        
        if data.onlineStatusString ?? "" == statusOnline {
            self.imgOnline.backgroundColor = .green
        } else {
            self.imgOnline.backgroundColor = .gray
        }
        
        guard let urlString = data.thumbnailPhotoURL else { return }
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
    }
}
