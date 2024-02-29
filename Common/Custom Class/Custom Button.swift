//
//  Custom Button.swift
//  
//
//  Created by Tristate on 12/12/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import UIKit

class CustomButton : UIButton {
    @IBInspectable var isGreenButton : Bool = false
    @IBInspectable var buttonHeight : CGFloat = 50
//    @IBInspectable var isRoundedButton : Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        frame.size.height = buttonHeight
        backgroundColor = isGreenButton ? UIColor.white : UIColor.blue
    }
}
