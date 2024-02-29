//
//  CommonHeader.swift
//  
//
//  Created by Tristate Technology on 19/12/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import UIKit

class CommonHeaderLabel : UILabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        font = .heavy(ofSize: 26.0)
        minimumScaleFactor = 0.5
        adjustsFontSizeToFitWidth = true //Font Size Changes
        textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
}

class CommonHeaderView : UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = #colorLiteral(red: 0, green: 0.6710000038, blue: 0.949000001, alpha: 1)
    }
}


class CommonButton : UIButton{
    public enum buttonState : Int {
        case normal,Loading,inActive
    }
    
    open var spinner = UIActivityIndicatorView()
    open var viewForSpinner = UIView()
    
    var currentState : buttonState = .normal{
        didSet{
            switch currentState {
                
            case .normal:
                backgroundColor = #colorLiteral(red: 0, green: 0.6710000038, blue: 0.949000001, alpha: 1)
                titleLabel?.font = .heavy(ofSize: 24.0)
                let textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                setTitleColor(textColor, for: .normal)
                stopLoadingBtn()
            case .Loading:
                loadingBtn()
            case .inActive:
                backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9490196078, blue: 0.9725490196, alpha: 1)
                let textColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6823529412, alpha: 1)
                setTitleColor(textColor, for: .normal)
            }
        }
    }
    
    var isDisable : Bool = false
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = #colorLiteral(red: 0, green: 0.6710000038, blue: 0.949000001, alpha: 1)
        titleLabel?.font = .heavy(ofSize: 24.0)
        let textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        setTitleColor(textColor, for: .normal)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupSpinner()
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            layer.cornerRadius = frame.height / 2
            layer.masksToBounds = true
//            layer.masksToBounds = true
            shadowRadius = 3
            shadowColor = UIColor.appTheme
            shadowOpacity = 0.2
            shadowOffset = CGSize(width: 0, height: 5)
            generateOuterShadow(isDisable : isDisable)
//        }
        
        
    }
    
    open func generateOuterShadow(isDisable : Bool = false) {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = layer.cornerRadius
        view.layer.shadowRadius = layer.shadowRadius
        view.layer.shadowOpacity = layer.shadowOpacity
        view.layer.shadowColor = layer.shadowColor
        view.layer.shadowOffset = layer.shadowOffset
        view.clipsToBounds = false
        view.backgroundColor = .white
        
        if isDisable{
            view.layer.shadowColor = UIColor.gray.cgColor
        }
        
        superview?.insertSubview(view, belowSubview: self)
        
        let constraints = [
            NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0),
            NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0),
        ]
        superview?.addConstraints(constraints)
    }
    
    private func setupSpinner(){
        spinner = UIActivityIndicatorView(style: .whiteLarge)
        spinner.color = UIColor.appTheme
        spinner.frame.size = CGSize(width: 40.0, height: 40.0)
        spinner.center = center
        viewForSpinner.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9490196078, blue: 0.9725490196, alpha: 1)
        viewForSpinner.addSubview(spinner)
        addSubview(viewForSpinner)
        viewForSpinner.isHidden = true
    }
    
    private func loadingBtn(){
        viewForSpinner.isHidden = false
        viewForSpinner.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9490196078, blue: 0.9725490196, alpha: 1)
        viewForSpinner.frame.size = frame.size
        viewForSpinner.center = titleLabel?.center ?? CGPoint.zero
        spinner.center = viewForSpinner.center
        spinner.startAnimating()
    }
    
    private func stopLoadingBtn(){
        viewForSpinner.isHidden = true
        spinner.stopAnimating()
    }
}


class TextFieldSeparator : UILabel {
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    func setup(){
        backgroundColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6823529412, alpha: 1)
    }
}

class CommonTextField : UITextField{
    override func awakeFromNib() {
        super.awakeFromNib()
        textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        font = .regular(ofSize: 20)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
//        placeHolderColor = #colorLiteral(red: 0.6823529412, green: 0.6823529412, blue: 0.6823529412, alpha: 1)
    }
}

class ExtendedTextField: CommonTextField {
    override func awakeFromNib() {
        super.awakeFromNib()
        textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
}


class CommonButtonHeight : UIButton{
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = frame.height / 2
        layer.masksToBounds = true
    }
}

