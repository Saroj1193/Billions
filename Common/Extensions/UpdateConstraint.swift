//
//  UpdateConstraint.swift
//  
//
//  Created by Tristate on 11/22/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import UIKit

class UpdateHeightConstraint: NSLayoutConstraint {
    @IBInspectable var designDeviceHeight: CGFloat = 896 //Add hegiht for design device (Height Cons)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.constant = (UIScreen.main.bounds.size.height/designDeviceHeight) * self.constant
    }
}

class UpdateWidthConstraint: NSLayoutConstraint {
    @IBInspectable var designDeviceWidth: CGFloat = 896 //Add width for design device (Width Cons)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.constant = (UIScreen.main.bounds.size.width/designDeviceWidth) * self.constant
    }
}


class UpdateHorizontalStackViewSpacing : UIStackView{
    @IBInspectable var designDeviceHeight: CGFloat = 896 //Add Device Width
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.spacing = (UIScreen.main.bounds.size.height/designDeviceHeight) * self.spacing
    }
}


class UpdateVerticalStackViewSpacing : UIStackView{
    @IBInspectable var designDeviceHeight: CGFloat = 896
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.spacing = (UIScreen.main.bounds.size.height/designDeviceHeight) * self.spacing
    }
}

class updateLableFontSize : UILabel{
    @IBInspectable var designDeviceHeight: CGFloat = 896
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.font = UIFont(name: self.font.fontName, size: (UIScreen.main.bounds.size.height/designDeviceHeight) * self.font.pointSize)
    }
}
