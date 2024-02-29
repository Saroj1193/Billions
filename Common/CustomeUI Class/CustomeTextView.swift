//
//  CustomeTextView.swift
//
//
//  Created by  on 04/07/20.
//  Copyright © 2020 . All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

protocol CustomeTextViewDelegate {
    func updateLabelCount(labelCount : Int)
}

@IBDesignable
open class CustomeTextView : UITextView {
    var coundDelegate : CustomeTextViewDelegate?
    @IBInspectable var iPhoneFontSize:CGFloat = 0 {
        didSet {
            self.font = GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: iPhoneFontSize)
        }
    }
    
    @IBInspectable var placeholderColor: UIColor = UIColor.lightGray
    @IBInspectable var placeholderText: String = ""

    @IBInspectable open var borderEnabled: Bool = true {
        didSet {
            borderLayer?.removeFromSuperlayer()
            borderLayer = nil
            if borderEnabled {
                borderLayer = CALayer()
                borderLayer?.frame = CGRect(x: 0, y: layer.bounds.height - 1, width: bounds.width, height: 1)
                borderLayer?.backgroundColor = UIColor.darkGray.cgColor
                layer.addSublayer(borderLayer!)
            }
            
        }
        
    }
//    @IBInspectable open var borderWidth: CGFloat = 10.0
//    @IBInspectable open var borderColor: UIColor = UIColor.darkGray
    @IBInspectable open var borderHighlightWidth: CGFloat = 1.75
    fileprivate var borderLayer: CALayer?
    
    @IBInspectable open var borderFullEnabled: Bool = true {
        didSet {
            
            if borderFullEnabled {
                self.layer.borderWidth = borderFullWidth
                self.layer.borderColor = borderFullColor.cgColor
                self.layer.masksToBounds = true
            }
            
        }
        
    }
    
    @IBInspectable open var borderFullWidth: CGFloat = 10.0
    @IBInspectable open var borderFullColor: UIColor = UIColor.darkGray
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        self.contentInset = UIEdgeInsets(top: 5, left: 5, bottom: 0, right: 0)
    }
    
    override open var contentInset: UIEdgeInsets {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override open var textAlignment: NSTextAlignment {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override open var text: String? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override open var attributedText: NSAttributedString? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUp()
    }
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
    }
    
    private func setUp() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.textChanged(notification:)),
                                               name: Notification.Name("UITextViewTextDidChangeNotification"),
                                               object: nil)
    }
    
    @objc func textChanged(notification: NSNotification) {
        
        
        if (self.text?.count)!>MaxValue && setMaxValue == true
        {
            var str:NSString
            str = self.text! as NSString
            
            str = str .substring(to: MaxValue) as NSString
            self.text = str as String
        }
        self.coundDelegate?.updateLabelCount(labelCount: self.text?.count ?? 0)
        setNeedsDisplay()
    }
    
    func placeholderRectForBounds(bounds: CGRect) -> CGRect {
   
        var x : CGFloat = 5
        var y = contentInset.top
        let w = frame.size.width - contentInset.left - contentInset.right - 16.0
        let h = frame.size.height - contentInset.top - contentInset.bottom 
        
        if let style = self.typingAttributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle {
            x += style.headIndent
            y += style.firstLineHeadIndent
        }
        return CGRect(x: x, y: y, width: w, height: h)
        
    }
    
    override open func draw(_ rect: CGRect) {
        if text!.isEmpty && !placeholderText.isEmpty {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = textAlignment
            let attributes: [NSAttributedString.Key: Any] = [
                NSAttributedString.Key(rawValue: NSAttributedString.Key.font.rawValue) : GlobalFunction.overrideFontSize(fontName: .SFProText_Regular, fontSize: iPhoneFontSize),
                NSAttributedString.Key(rawValue: NSAttributedString.Key.foregroundColor.rawValue) : placeholderColor,
                NSAttributedString.Key(rawValue: NSAttributedString.Key.paragraphStyle.rawValue)  : paragraphStyle]
            
            placeholderText.draw(in: placeholderRectForBounds(bounds: bounds), withAttributes: attributes)
        }
        super.draw(rect)
    }
   
    @IBInspectable var setMaxValue: Bool = false
    @IBInspectable var MaxValue: NSInteger = 5
    
    
}
