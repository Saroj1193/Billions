//
//  CustomeTextField.swift
//  
//
//  Created by  on 04/07/20.
//  Copyright © 2020 . All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

@IBDesignable
open class CustomeTextField : UITextField,UITextFieldDelegate {
    
    
    @IBInspectable var iPhoneFontSize:CGFloat = 0 {
        
        didSet {
            self.font = GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: iPhoneFontSize)
        }
    }
    
    
    var tintedClearImage: UIImage?
    @IBInspectable open var padding: CGSize = CGSize(width: 5, height: 5)
    @IBInspectable open var floatingLabelBottomMargin: CGFloat = 2.0
    @IBInspectable open var floatingPlaceholderEnabled: Bool = false
    
    open var rippleLocation: CustomeRippleLocation = .tapLocation {
        didSet {
            mkLayer.rippleLocation = rippleLocation
        }
    }
    
    @IBInspectable var placeHolderColor:UIColor = UIColor.placeholderColor {
        didSet {
            self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeHolderColor])
        }
    }
    
    @IBInspectable open var rippleAniDuration: Float = 0.75
    @IBInspectable open var backgroundAniDuration: Float = 1.0
    @IBInspectable open var shadowAniEnabled: Bool = true
    open var rippleAniTimingFunction: CustomeTimingFunction = .linear
    
    @IBInspectable open var txtCornerRadius: CGFloat = 2.5 {
        didSet {
            layer.cornerRadius = txtCornerRadius
            mkLayer.setMaskLayerCornerRadius(txtCornerRadius)
        }
    }
    // color
    @IBInspectable open var rippleLayerColor: UIColor = UIColor(white: 0.45, alpha: 0.5) {
        didSet {
            mkLayer.setCircleLayerColor(rippleLayerColor)
        }
    }
    @IBInspectable open var backgroundLayerColor: UIColor = UIColor(white: 0.75, alpha: 0.25) {
        didSet {
            mkLayer.setBackgroundLayerColor(backgroundLayerColor)
        }
    }
    
    // floating label
    @IBInspectable open var floatingLabelFont: CGFloat = 16.0 {
        didSet {
            floatingLabel.font = GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: floatingLabelFont)
        }
    }
    
    @IBInspectable open var floatingLabelTextColor: UIColor = UIColor.lightGray {
        didSet {
            floatingLabel.textColor = floatingLabelTextColor
            self.placeHolderColor = self.floatingLabel.textColor
        }
    }
    
    @IBInspectable open var bottomBorderEnabled: Bool = true {
        didSet {
            bottomBorderLayer?.removeFromSuperlayer()
            bottomBorderLayer = nil
            if bottomBorderEnabled {
                bottomBorderLayer = CALayer()
                bottomBorderLayer?.frame = CGRect(x: 0, y: layer.bounds.height, width: bounds.width, height: 1)
                bottomBorderLayer?.backgroundColor = bottomBorderColor.cgColor
                layer.addSublayer(bottomBorderLayer!)
            }
        }
    }
    @IBInspectable open var bottomBorderWidth: CGFloat = 1.0
    @IBInspectable open var bottomBorderColor: UIColor = UIColor.white
    @IBInspectable open var bottomBorderHighlightWidth: CGFloat = 1.75
    
    override open var placeholder: String? {
        didSet {
            updateFloatingLabelText()
        }
    }
    override open var bounds: CGRect {
        didSet {
            mkLayer.superLayerDidResize()
        }
    }
    
    fileprivate lazy var mkLayer: CustomeLayer = CustomeLayer(superLayer: self.layer)
    fileprivate var floatingLabel: UILabel!
    fileprivate var bottomBorderLayer: CALayer?
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupLayer()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
    
    fileprivate func setupLayer() {
        
        if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.textAlignment == .left{
            self.textAlignment = .right
        } else if UIView.appearance().semanticContentAttribute == .forceRightToLeft && self.textAlignment == .right {
            self.textAlignment = .left
        }
       // self.tintColor = self.textColor
        //        cornerRadius = 2.5
        layer.borderWidth = 0.0
        borderStyle = .none
        self.attributedPlaceholder = NSAttributedString(string: placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : placeHolderColor])

        
        // floating label
        floatingLabel = UILabel()
        floatingLabel.font = GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: floatingLabelFont)
        floatingLabel.alpha = 0.0
        updateFloatingLabelText()
        
        addSubview(floatingLabel)
    }
    
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        mkLayer.didChangeTapLocation(touch.location(in: self))
        mkLayer.animateScaleForCircleLayer(0.45, toScale: 1.0, timingFunction: CustomeTimingFunction.linear, duration: CFTimeInterval(self.rippleAniDuration))
        mkLayer.animateAlphaForBackgroundLayer(CustomeTimingFunction.linear, duration: CFTimeInterval(self.backgroundAniDuration))
        
        return super.beginTracking(touch, with: event)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        tintClearImage()
        //        self.returnKeyType = UIReturnKeyType.default
        if !floatingPlaceholderEnabled {
            return
        }
        
        if let text = text , text.isEmpty == false {
            //            floatingLabel.textColor = isFirstResponder ? tintColor : floatingLabelTextColor
            floatingLabel.textColor = isFirstResponder ?  floatingLabelTextColor : floatingLabelTextColor
            if floatingLabel.alpha == 0 {
                showFloatingLabel()
            }
        } else {
            hideFloatingLabel()
        }
        
        bottomBorderLayer?.backgroundColor = bottomBorderColor.cgColor
        let borderWidth = isFirstResponder ? bottomBorderHighlightWidth : bottomBorderWidth
        bottomBorderLayer?.frame = CGRect(x: 0, y: layer.bounds.height - borderWidth, width: layer.bounds.width, height: borderWidth)
    }
    
    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        let rect = super.textRect(forBounds: bounds)
        var newRect = CGRect(x: rect.origin.x + padding.width, y: rect.origin.y,
                             width: rect.size.width - 2*padding.width, height: rect.size.height)
        
        if !floatingPlaceholderEnabled {
            return newRect
        }
        
        if let text = text , text.isEmpty == false {
            let dTop = floatingLabel.font.lineHeight
            
            newRect = newRect.inset(by: UIEdgeInsets(top: dTop, left: 0, bottom: 4, right: 0))
            //            newRect = UIEdgeInsetsInsetRect(newRect, UIEdgeInsets(top: dTop, left: 0.0, bottom: 0.0, right: 0.0))
        }
        
        return newRect
    }
    
    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return textRect(forBounds: bounds)
    }
    
    
    // MARK:- TextField Validation
    let  arrNoOfTextfiled = NSMutableArray()
    
    @IBInspectable var MaxValue: NSInteger = 500
    @IBInspectable var DataType: NSString = ""
    
    
    @IBAction func KeyBoardStroke(sender: AnyObject)
    {
        var txt: UITextField!
        
        txt = sender as? UITextField
        
        if (txt.text?.count)!>MaxValue
        {
            var str:NSString
            str = txt.text! as NSString
            
            str = str .substring(to: MaxValue) as NSString
            txt.text = str as String
        }
        
        if DataType == "Numeric"
        {
            let inverseSet = NSCharacterSet(charactersIn: "0123456789").inverted
            let components = txt.text?.components(separatedBy: inverseSet)
            let filtered = components?.joined(separator: "")  // use join("", components) if you are using Swift 1.2
            
            return txt.text = filtered
            
        }
        if DataType == "Numeric+Punctuation"
        {
            let inverseSet = NSCharacterSet(charactersIn: "0123456789 +").inverted
            let components = txt.text?.components(separatedBy: inverseSet)
            let filtered = components?.joined(separator: "")  // use join("", components) if you are using Swift 1.2
            
            return txt.text = filtered
            
        }
        if DataType == "Character"
        {
            let inverseSet = NSCharacterSet(charactersIn: "abcdegfghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ ").inverted
            let components = txt.text?.components(separatedBy: inverseSet)
            let filtered = components?.joined(separator: "")
            if filtered?.count == 1 {
                let str = filtered?.trimmingCharacters(in: .whitespaces)
                return txt.text = str
            } else {
                return txt.text = filtered
            }
            
            
        }
        if DataType == "CharacterHash"
        {
            let inverseSet = NSCharacterSet(charactersIn: "abcdegfghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ#").inverted
            let components = txt.text?.components(separatedBy: inverseSet)
            let filtered = components?.joined(separator: "")
            if filtered?.count == 1 {
                let str = filtered?.trimmingCharacters(in: .whitespaces)
                return txt.text = str
            } else {
                return txt.text = filtered
            }
            
            
        }
        if DataType == "Numeric+Character"
        {
            let inverseSet = NSCharacterSet(charactersIn: "abcdegfghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 ").inverted
            let components = txt.text?.components(separatedBy: inverseSet)
            let filtered = components?.joined(separator: "")  // use join("", components) if you are using Swift 1.2
            
            return txt.text = filtered
            
        }
        if DataType == "Character+Punctuation"
        {
            let inverseSet = NSCharacterSet(charactersIn: "abcdegfghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ<>?:}{+|_)(*&^%$#@!~,./'=-0;").inverted
            let components = txt.text?.components(separatedBy: inverseSet)
            let filtered = components?.joined(separator: "")  // use join("", components) if you are using Swift 1.2
            
            return txt.text = filtered
            
        }
        if DataType == "Email"
        {
            let inverseSet = NSCharacterSet(charactersIn: "abcdegfghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.@_-").inverted
            let components = txt.text?.components(separatedBy: inverseSet)
            let filtered = components?.joined(separator: "")  // use join("", components) if you are using Swift 1.2
            
            return txt.text = filtered
            
        }
        if DataType == "Numericwithoutdecimal"
        {
            let inverseSet = NSCharacterSet(charactersIn: "0123456789.").inverted
            let components = txt.text?.components(separatedBy: inverseSet)
            let filtered = components?.joined(separator: "")  // use join("", components) if you are using Swift 1.2
            
            return txt.text = filtered
            
        }
        
        self .ValidateTextfield(txtValue: txt.text! as NSString)
    }
    
    // MARK: - Texfield ShouldReturn
    
    @IBAction func KeyBoardHide(textfield: UITextField) {
        
        var intIndex: NSInteger
        var txtfield = textfield
        
        intIndex = arrNoOfTextfiled .index(of: txtfield)
        
        if txtfield.returnKeyType == UIReturnKeyType.next {
            if intIndex < arrNoOfTextfiled.count {
                txtfield = arrNoOfTextfiled.object(at: intIndex+1) as! UITextField
                txtfield .becomeFirstResponder()
                return
            }
        }else if txtfield.returnKeyType == UIReturnKeyType.done {
            txtfield.resignFirstResponder()
            return
        }
    }
    
    // MARK: - TextField Editing Begin
    
    func Didbegin() {
        
        if let wd = self.window {
            
            var vc = wd.rootViewController
            if(vc is UINavigationController) {
                vc = (vc as! UINavigationController).visibleViewController
            }
            
            for subv in (vc?.view.subviews)! {
                if let textField:UITextField = subv as? UITextField {
                    arrNoOfTextfiled.add(textField);
                }
            }
        }
    }
    
    // MARK: - Validation Method
    
    func ValidateTextfield(txtValue: NSString) {
    }
    
    private func tintClearImage() {
        for view in subviews {
            if view is UIButton {
                let button = view as! UIButton
                if let uiImage = button.image(for: .highlighted) {
                    if tintedClearImage == nil {
                        tintedClearImage = tintImage(image: uiImage, color: UIColor.white)
                    }
                    button.setImage(tintedClearImage, for: .normal)
                    button.setImage(tintedClearImage, for: .highlighted)
                }
            }
        }
    }
    
    
}

// MARK - private methods
private extension CustomeTextField {
    func setFloatingLabelOverlapTextField() {
        let textRect = self.textRect(forBounds: bounds)
        //        var originX = textRect.origin.x
        //        switch textAlignment {
        //        case .center:
        //            originX += textRect.size.width/2 - floatingLabel.bounds.width/2
        //        case .right:
        //            originX += textRect.size.width - floatingLabel.bounds.width
        //        default:
        //            break
        //        }
        floatingLabel.frame = CGRect(x: textRect.origin.x, y: padding.height,
                                     width: 50, height: floatingLabel.frame.size.height)
        floatingLabel.sizeToFit()
        floatingLabel.textColor = floatingLabelTextColor
    }
    
    func showFloatingLabel() {
        let textRect = self.textRect(forBounds: bounds)
        floatingLabel.frame = CGRect(x: textRect.origin.x, y: padding.height,
                                     width: 50, height: floatingLabel.frame.size.height)
        let curFrame = floatingLabel.frame
        floatingLabel.frame = CGRect(x: curFrame.origin.x , y: bounds.height/2, width: 50, height: curFrame.height)
        floatingLabel.textColor = floatingLabelTextColor
        UIView.animate(withDuration: 0.45, delay: 0.0, options: .curveEaseOut,
                       animations: {
                        self.floatingLabel.alpha = 1.0
                        self.floatingLabel.frame = curFrame
                        self.floatingLabel.sizeToFit()
                        self.floatingLabel.textColor = self.floatingLabelTextColor
        }, completion: nil)
    }
    
    func hideFloatingLabel() {
        floatingLabel.alpha = 0.0
    }
    
    func updateFloatingLabelText() {
        floatingLabel.text = placeholder
        floatingLabel.sizeToFit()
        floatingLabel.textColor = floatingLabelTextColor
        setFloatingLabelOverlapTextField()
    }
}

func tintImage(image: UIImage, color: UIColor) -> UIImage {
    let size = image.size
    
    UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
    let context = UIGraphicsGetCurrentContext()
    image.draw(at: CGPoint.zero, blendMode: CGBlendMode.normal, alpha: 1.0)
    
    context!.setFillColor(color.cgColor)
    context!.setBlendMode(CGBlendMode.sourceIn)
    context!.setAlpha(1.0)
    
    let rect = CGRect(x: CGPoint.zero.x, y: CGPoint.zero.y, width: image.size.width, height: image.size.height)
    UIGraphicsGetCurrentContext()!.fill(rect)
    let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return tintedImage!
}
