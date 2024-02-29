//
//  CustomeButton.swift
//
//
//  Created by  on 04/07/20.
//  Copyright © 2020 . All rights reserved.
//
import UIKit

class CustomBtnHV: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    @IBInspectable var iPhoneFontSize:CGFloat = 17 {
        didSet {
            self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .Hello_Valentina, fontSize: iPhoneFontSize)
        }
    }
    
    func setupButton(){
        self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .Hello_Valentina, fontSize: iPhoneFontSize)
        if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .right{
            self.contentHorizontalAlignment = .left
        } else if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .left{
            self.contentHorizontalAlignment = .right
        }
    }

}

class CustomBtnSFDMedium: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    @IBInspectable var iPhoneFontSize:CGFloat = 17 {
        didSet {
            self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .SFProDisplay_Medium, fontSize: iPhoneFontSize)
        }
    }
    
    func setupButton(){
        self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .SFProDisplay_Medium, fontSize: iPhoneFontSize)
        if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .right{
            self.contentHorizontalAlignment = .left
        } else if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .left{
            self.contentHorizontalAlignment = .right
        }
    }

}

class CustomBtnSFTRegular: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    @IBInspectable var iPhoneFontSize:CGFloat = 17 {
        didSet {
            self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: iPhoneFontSize)
        }
    }
    
    func setupButton(){
        self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: iPhoneFontSize)
        if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .right{
            self.contentHorizontalAlignment = .left
        } else if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .left{
            self.contentHorizontalAlignment = .right
        }
    }

}

class CustomBtnSFPDRegular: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    @IBInspectable var iPhoneFontSize:CGFloat = 17 {
        didSet {
            self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .SFProDisplay_Regular, fontSize: iPhoneFontSize)
        }
    }
    
    func setupButton(){
        self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .SFProDisplay_Regular, fontSize: iPhoneFontSize)
        if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .right{
            self.contentHorizontalAlignment = .left
        } else if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .left{
            self.contentHorizontalAlignment = .right
        }
    }

}

class CustomBtnSFPDBold: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    @IBInspectable var iPhoneFontSize:CGFloat = 17 {
        didSet {
            self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .SFProDisplay_Bold, fontSize: iPhoneFontSize)
        }
    }
    
    func setupButton(){
        self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .SFProDisplay_Bold, fontSize: iPhoneFontSize)
        if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .right{
            self.contentHorizontalAlignment = .left
        } else if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .left{
            self.contentHorizontalAlignment = .right
        }
    }

}

class CustomBtnSFDSemibold: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    @IBInspectable var iPhoneFontSize:CGFloat = 17 {
        didSet {
            self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .SFDIsplay_Semibold, fontSize: iPhoneFontSize)
        }
    }
    
    func setupButton(){
        self.titleLabel?.font = GlobalFunction.overrideFontSize(fontName: .SFDIsplay_Semibold, fontSize: iPhoneFontSize)
        if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .right{
            self.contentHorizontalAlignment = .left
        } else if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.contentHorizontalAlignment == .left{
            self.contentHorizontalAlignment = .right
        }
    }

}
