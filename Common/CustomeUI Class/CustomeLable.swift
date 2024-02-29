//
//  CustomeLable.swift
//
//
//  Created by  on 04/07/20.
//  Copyright © 2020 . All rights reserved.
//

import Foundation
import UIKit

class CustomLblHV: UILabel {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    func commonInit(){
        self.font = GlobalFunction.overrideFontSize(fontName: .Hello_Valentina, fontSize: self.font.pointSize)
    }

}

class CustomLblSFPDMedium: UILabel {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    func commonInit(){
        self.font = GlobalFunction.overrideFontSize(fontName: .SFProDisplay_Medium, fontSize: self.font.pointSize)
    }

}

class CustomLblSFPTRegular: UILabel {
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    func commonInit(){
        self.font = GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: self.font.pointSize)
    }
    
}

class CustomLblSFPDRegular: UILabel {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    func commonInit(){
        self.font = GlobalFunction.overrideFontSize(fontName: .SFProDisplay_Regular, fontSize: self.font.pointSize)
    }

}

class CustomLblSFPDBold: UILabel {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    func commonInit(){
        self.font = GlobalFunction.overrideFontSize(fontName: .SFProDisplay_Bold, fontSize: self.font.pointSize)
    }

}

class CustomLblSFDSemibold: UILabel {

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.commonInit()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    func commonInit(){
        self.font = GlobalFunction.overrideFontSize(fontName: .SFDIsplay_Semibold, fontSize: self.font.pointSize)
    }

}
