//
//  UIView+Extension.swift
//  
//
//  Created by Tristate on 11/18/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import Foundation
import UIKit

class BaseViewValue:UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension UIView {
    func addColors(colors: [UIColor?]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds

        var colorsArray: [CGColor] = []
        var locationsArray: [NSNumber] = []
        for (index, color) in colors.enumerated() {
            // append same color twice
            colorsArray.append(color!.cgColor)
            colorsArray.append(color!.cgColor)
            locationsArray.append(NSNumber(value: (1.0 / Double(colors.count)) * Double(index)))
            locationsArray.append(NSNumber(value: (1.0 / Double(colors.count)) * Double(index + 1)))
        }

        gradientLayer.colors = colorsArray
        gradientLayer.locations = locationsArray

        self.backgroundColor = .clear
        self.layer.insertSublayer(gradientLayer, at: 0)

        // This can be done outside of this funciton
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.masksToBounds = true
    }
    
    func rotate360Degrees(duration: CFTimeInterval = 3) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Double.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
    
    func rotate() {
        let rotation : CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    private struct AssociatedKeys {
        static var descriptiveName = "AssociatedKeys.DescriptiveName.blurView"
    }
    
    private (set) var blurView: BlurView {
        get {
            if let blurView = objc_getAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName
                ) as? BlurView {
                return blurView
            }
            self.blurView = BlurView(to: self)
            return self.blurView
        }
        set(blurView) {
            objc_setAssociatedObject(
                self,
                &AssociatedKeys.descriptiveName,
                blurView,
                .OBJC_ASSOCIATION_RETAIN_NONATOMIC
            )
        }
    }
    
    class BlurView {
        
        private var superview: UIView
        private var blur: UIVisualEffectView?
        private var editing: Bool = false
        private (set) var blurContentView: UIView?
        private (set) var vibrancyContentView: UIView?
        
        var animationDuration: TimeInterval = 0.1
        
        /**
         * Blur style. After it is changed all subviews on
         * blurContentView & vibrancyContentView will be deleted.
         */
        var style: UIBlurEffect.Style = .light {
            didSet {
                guard oldValue != style,
                    !editing else { return }
                applyBlurEffect()
            }
        }
        /**
         * Alpha component of view. It can be changed freely.
         */
        var alpha: CGFloat = 0 {
            didSet {
                guard !editing else { return }
                if blur == nil {
                    applyBlurEffect()
                }
                let alpha = self.alpha
                UIView.animate(withDuration: animationDuration) {
                    self.blur?.alpha = alpha
                }
            }
        }
        
        init(to view: UIView) {
            self.superview = view
        }
        
        func setup(style: UIBlurEffect.Style, alpha: CGFloat) -> Self {
            self.editing = true
            
            self.style = style
            self.alpha = alpha
            
            self.editing = false
            
            return self
        }
        
        func enable(isHidden: Bool = false) {
            if blur == nil {
                applyBlurEffect()
            }
            
            self.blur?.isHidden = isHidden
        }
        
        private func applyBlurEffect() {
            blur?.removeFromSuperview()
            
            applyBlurEffect(
                style: style,
                blurAlpha: alpha
            )
        }
        
        private func applyBlurEffect(style: UIBlurEffect.Style,
                                     blurAlpha: CGFloat) {
            superview.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: style)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
            let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
            blurEffectView.contentView.addSubview(vibrancyView)
            
            blurEffectView.alpha = blurAlpha
            
            superview.insertSubview(blurEffectView, at: 0)
            
            blurEffectView.addAlignedConstrains()
            vibrancyView.addAlignedConstrains()
            
            self.blur = blurEffectView
            self.blurContentView = blurEffectView.contentView
            self.vibrancyContentView = vibrancyView.contentView
        }
    }
    
    private func addAlignedConstrains() {
        translatesAutoresizingMaskIntoConstraints = false
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.top)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.leading)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.trailing)
        addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute.bottom)
    }
    
    private func addAlignConstraintToSuperview(attribute: NSLayoutConstraint.Attribute) {
        superview?.addConstraint(
            NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: superview,
                attribute: attribute,
                multiplier: 1,
                constant: 0
            )
        )
    }
}
extension UIView {
    
    func takeScreenshot(size:CGSize) -> UIImage {
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
}

extension UIButton {
    func loadingIndicator(_ show: Bool) {
        let tag = 808404
        if show {
            self.isEnabled = false
            self.alpha = 0.5
            let indicator = UIActivityIndicatorView()
            let buttonHeight = self.bounds.size.height
            let buttonWidth = self.bounds.size.width
            indicator.center = CGPoint(x: buttonWidth/2, y: buttonHeight/2)
            indicator.tag = tag
            indicator.style = .gray
            self.addSubview(indicator)
            indicator.startAnimating()
        } else {
            DispatchQueue.main.async {
                self.isEnabled = true
                self.alpha = 1.0
                if let indicator = self.viewWithTag(tag) as? UIActivityIndicatorView {
                    indicator.stopAnimating()
                    indicator.removeFromSuperview()
                }
            }
        }
    }
}

extension UIView {
    
    // return the view through string
    class func viewFromNibName(name: String) -> UIView? {
        
        let views = Bundle.main.loadNibNamed(name, owner: self, options: nil)
        return views!.first as? UIView
    }
    
    func applyGradient(colours: [UIColor] , angle:CGFloat) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.reversed().map { $0.cgColor }
        //        let x : CGFloat = angle / 360.0
        //
        //        let a : CGFloat = pow(sin((CGFloat(2 * Double.pi) * (( x + 0.75) / 2))), 2)
        //        let b : CGFloat = pow(sin((CGFloat(2 * Double.pi) * (( x + 0.0) / 2))), 2)
        //        let c : CGFloat = pow(sin((CGFloat(2 * Double.pi) * (( x + 0.25) / 2))), 2)
        //        let d : CGFloat = pow(sin((CGFloat(2 * Double.pi) * (( x + 0.5) / 2))), 2)
        
        gradient.startPoint = CGPoint(x: 0, y: 1)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = self.cornerRadius
        self.layer.insertSublayer(gradient, at: 0)
        //        self.layer.addSublayer(gradient)
    }
    
    func setCorner(corners: CACornerMask, radius: CGFloat) {
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        self.layer.maskedCorners = corners
    }
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
        layer.backgroundColor = UIColor.red.cgColor
//        self.layoutIfNeeded()
//        self.setNeedsLayout()
//        self.setNeedsDisplay()
    }
    
    
    func dropShadow() {
        let shadowPath = UIBezierPath(rect: self.bounds)
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 4)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowPath = shadowPath.cgPath
    }
    
    var addSlope:Void{
        
        // Make path to draw traingle
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: 0))
        path.addLine(to: CGPoint(x: self.frame.width, y: self.frame.height))
        path.addLine(to: CGPoint(x: 0, y: 0))
        path.close()
        
        // Add path to the mask
        let mask = CAShapeLayer()
        mask.frame = self.bounds
        mask.path = path.cgPath
        
        self.layer.mask = mask
        
        // Adding shape to view's layer
        let shape = CAShapeLayer()
        shape.frame = self.bounds
        shape.path = path.cgPath
        shape.fillColor = UIColor.gray.cgColor
        
        self.layer.insertSublayer(shape, at: 1)
    }
    
    func setCircleShadow(shadowRadius: CGFloat = 2,
                         shadowOpacity: Float = 1,
                         shadowColor: CGColor = UIColor.blackColor.withAlphaComponent(0.15).cgColor,
                         shadowOffset: CGSize = CGSize(width: 0.0, height: 2.0)) {
        DispatchQueue.main.async {
            self.layer.cornerRadius = self.frame.size.height / 2
            self.layer.masksToBounds = false
            self.layer.shadowColor = shadowColor
            self.layer.shadowOffset = shadowOffset
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowOpacity = shadowOpacity
        }
    }
    
    func addShadow(offset: CGSize, color: UIColor, radius: CGFloat, opacity: Float) {
        layer.masksToBounds = false
        layer.shadowOffset = offset
        layer.shadowColor = color.cgColor
        layer.shadowRadius = radius
        layer.shadowOpacity = opacity
//        
//
//        let backgroundCGColor = backgroundColor?.cgColor
//        backgroundColor = nil
//        layer.backgroundColor =  backgroundCGColor
        layer.cornerRadius = 5
    }
    
    func setCornerShadow(shadowRadius: CGFloat = 2,
                         shadowOpacity: Float = 1,
                         shadowColor: CGColor = UIColor.blackColor.withAlphaComponent(0.15).cgColor,
                         shadowOffset: CGSize = CGSize(width: 0.0, height: 2.0), cornerRadius: CGFloat = 12) {
        DispatchQueue.main.async {
            self.layer.cornerRadius = cornerRadius
            self.layer.masksToBounds = false
            self.layer.shadowColor = shadowColor
            self.layer.shadowOffset = shadowOffset
            self.layer.shadowRadius = shadowRadius
            self.layer.shadowOpacity = shadowOpacity
            self.clipsToBounds = true
        }
    
        
    }
    
   func addInnerShadow(cornerRadius: CGFloat = 12) {
        let innerShadow = CALayer()
        innerShadow.frame = self.bounds
        
        // Shadow path (1pt ring around bounds)
        let radius = cornerRadius
        let path = UIBezierPath(roundedRect: innerShadow.bounds.insetBy(dx: -2, dy:-2), cornerRadius:radius)
        let cutout = UIBezierPath(roundedRect: innerShadow.bounds, cornerRadius:radius).reversing()
        
        
        path.append(cutout)
        innerShadow.shadowPath = path.cgPath
        innerShadow.masksToBounds = true
        // Shadow properties
        innerShadow.shadowColor = UIColor.black.cgColor
        innerShadow.shadowOffset = CGSize(width: 0, height: 4)
        innerShadow.shadowOpacity = 0.5
        innerShadow.shadowRadius = 4
        innerShadow.cornerRadius = cornerRadius
        layer.addSublayer(innerShadow)
    }
    
    func pushTransition(_ duration:CFTimeInterval) {
        let animation:CATransition = CATransition()
        animation.timingFunction = CAMediaTimingFunction(name:
            CAMediaTimingFunctionName.easeInEaseOut)
        animation.type = CATransitionType.push
        animation.subtype = CATransitionSubtype.fromBottom
        animation.duration = duration
        layer.add(animation, forKey: CATransitionType.push.rawValue)
    }
    
    
    /// adds shadow in the view
    func drawShadow(shadowColor:UIColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 0.798828125), shadowOpacity:Float = 1, shadowPath:UIBezierPath? = nil, shadowRadius:Float = 5, cornerRadius:Float = 6.0, offset: CGSize = CGSize(width: -1, height: 1)) {
        
        var shdwpath = shadowPath
        if shadowPath == nil {
            shdwpath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
        }
        self.layer.masksToBounds = false
        self.layer.shadowColor  = shadowColor.cgColor
        self.layer.shadowOpacity = shadowOpacity
        self.layer.shadowPath   = shdwpath!.cgPath
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = CGFloat(shadowRadius)
        self.layer.cornerRadius = CGFloat(cornerRadius)
    }
    
    
    func dottedBorder(_ color:String) {
        
        for layer in self.layer.sublayers! {
            if(layer is CAShapeLayer) {
                print("layout remove from layer")
                layer.removeFromSuperlayer()
            }
        }
        
        self.updateConstraints()
        
        self.layer.layoutSublayers()
        self.layer.layoutIfNeeded()
        self.layoutSubviews()
        self.layoutIfNeeded()
        self.setNeedsLayout()
        let yourViewBorder = CAShapeLayer()
        
        yourViewBorder.strokeColor = UIColor(hex: color).cgColor
        yourViewBorder.lineDashPattern = [1, 1]
        yourViewBorder.frame = self.bounds
        yourViewBorder.fillColor = nil
        let beziarPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 5)
        yourViewBorder.path = beziarPath.cgPath
        
        self.layer.addSublayer(yourViewBorder)
        self.updateConstraints()
        self.layer.layoutSublayers()
        self.layer.layoutIfNeeded()
        self.layoutSubviews()
        self.layoutIfNeeded()
        self.setNeedsLayout()
    }
    
    func setGradientBackground(colorTop: UIColor, colorBottom: UIColor,view : UIView) -> CAGradientLayer{
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorBottom.cgColor, colorTop.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.locations = [0, 1]
        gradientLayer.frame = view.bounds
        
        return gradientLayer
    }
    
    
    @IBInspectable var isRoundRect: Bool {
        get {
            return self.isRoundRect
        }
        set{
            if newValue{
                self.layer.cornerRadius = self.frame.height / 2
            }else{
                
            }
        }
    }
    
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColorSet: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
}
