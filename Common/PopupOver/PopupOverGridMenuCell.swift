//
//  PopupOverGridMenuCell.swift
//  BillionsApp
//
//  Created by tristate22 on 28.02.24.
//

import UIKit

class PopupOverGridMenuCell: UICollectionViewCell {
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var viewBg: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    func toggleSelection(item: PopupMenuItem) {
        self.img.image = UIImage(named: item.image)
        self.viewBg.isRoundRect = true
        self.img.tintColor = UIColor.bwColor
        self.viewBg.addColors(colors: item.colors)
        let len = (self.lblText.attributedText?.length)!
        if len > 0 {
            let attrText = self.lblText.attributedText?.mutableCopy() as! NSMutableAttributedString
            attrText.removeAttribute(NSAttributedString.Key.foregroundColor, range: NSMakeRange(0, len))
            self.lblText.attributedText = attrText
        }
    }
}
