//
//  UITextField+Extension.swift
//  
//
//  Created by Tristate on 12/19/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    
    public func setImageAtLeftSideTf(imgViewIcon : UIImageView!) {
        self.leftViewMode = .always
        self.leftView = imgViewIcon
    }
    public func paddingLeftView(frame: CGRect, returnType: UIReturnKeyType){
        self.leftView = UIView(frame: frame)
        self.leftViewMode = UITextField.ViewMode.always
        self.returnKeyType = returnType
    }
    public func setBtnAtRightSideTf(btn: UIButton){
        self.rightViewMode = UITextField.ViewMode.always
        self.rightView = btn
    }
    public func paddingRightView(frame: CGRect, returnType: UIReturnKeyType){
        self.rightView = UIView(frame: frame)
        self.rightViewMode = UITextField.ViewMode.always
        self.returnKeyType = returnType
    }
    public func setImageAtRightSideTf(imgViewIcon : UIImageView!) {
        self.rightViewMode = .always
        self.rightView = imgViewIcon
    }
    

    //    public func setImageAtLeftSideTf(imgViewIcon : UIImageView!) {
    //        self.leftViewMode = .always
    //        self.leftView = imgViewIcon
    //    }
    //
    //    public func setImageAtRightSideTf(imgViewIcon : UIImageView!) {
    //        self.rightViewMode = .always
    //        self.rightView = imgViewIcon
    //    }
        
        public func setRightPading(_ viewframe:CGRect){
            let paddingView = UIView()
            paddingView.frame = viewframe
            self.rightViewMode = .always
            self.rightView = paddingView
        }
        public func setLeftPading(_ viewframe:CGRect){
            let paddingView = UIView()
            paddingView.frame = viewframe
            self.leftViewMode = .always
            self.leftView = paddingView
        }
        
        public func setDefaultLeftPadding() {
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: self.frame.size.height))
            self.leftView = paddingView
            self.leftViewMode = .always
        }
        
        func addDoneButtonToKeyboard(){
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
            doneToolbar.barStyle = UIBarStyle.default
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.resignFirstResponder))
            
            var items = [UIBarButtonItem]()
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            
            self.inputAccessoryView = doneToolbar
        }
        
        func addDoneAndCancelButtonToKeyboard(){
            let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
            doneToolbar.barStyle = UIBarStyle.default
            
            let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
            let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneAction))
            let cancel: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.cancelAction))
            var items = [UIBarButtonItem]()
            items.append(cancel)
            items.append(flexSpace)
            items.append(done)
            
            doneToolbar.items = items
            doneToolbar.sizeToFit()
            
            self.inputAccessoryView = doneToolbar
        }
        
        @objc func cancelAction() {
            self.tag = 0
            self.resignFirstResponder()
        }
        
        @objc func doneAction() {
            self.tag = 1
            self.resignFirstResponder()
        }
    
//    @IBInspectable var placeHolderColor: UIColor?{
//        get {
//            return self.placeHolderColor
//        }
//        set {
//            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
//        }
//    }
   
}

extension UITextView {
    
    //    func addDoneButtonToKeyboard(target : Any,myAction:Selector?){
    func addDoneButtonToKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.resignFirstResponder))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    func addDoneAndCancelButtonToKeyboard(){
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 300, height: 40))
        doneToolbar.barStyle = UIBarStyle.default
        
        let flexSpace = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.doneAction))
        let cancel: UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.cancelAction))
        var items = [UIBarButtonItem]()
        items.append(cancel)
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func cancelAction() {
        self.tag = 0
        self.resignFirstResponder()
    }
    
    @objc func doneAction() {
        self.tag = 1
        self.resignFirstResponder()
    }
}
