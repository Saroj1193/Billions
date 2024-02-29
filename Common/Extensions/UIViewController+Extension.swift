//
//  UIViewController+Extension.swift
//  
//
//  Created by Tristate on 14/05/18.
//  Copyright © 2019 Tristate. All rights reserved.
//

import Foundation
import UIKit

enum AppStoryboard: String {
    case registration = "Registration"
}

@IBDesignable
class CINavigationBar: UINavigationBar {
    
    //set NavigationBar's height
    @IBInspectable var customHeight : CGFloat = 66
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        
        return CGSize(width: UIScreen.main.bounds.width, height: customHeight)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //        self.tintColor = .black
        //        self.backgroundColor = .red
        
        for subview in self.subviews {
            var stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("UIBarBackground") {
                subview.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: customHeight)                
                //                subview.backgroundColor = .green
                //                subview.sizeToFit()
            }
            
            stringFromClass = NSStringFromClass(subview.classForCoder)
            
            //Can't set height of the UINavigationBarContentView
            if stringFromClass.contains("UINavigationBarContentView") {
                
                //Set Center Y
                //                let centerY = (customHeight - subview.frame.height) / 2.0
                subview.frame = CGRect(x: 0, y: 5, width: self.frame.width, height: customHeight)
                //                subview.backgroundColor = .yellow
                //                subview.sizeToFit()
                
            }
        }
        
        
    }
    
    
}

extension UIViewController {
    
    class func instantiate<T: UIViewController>(appStoryboard: AppStoryboard) -> T {
        let storyboard = UIStoryboard(name: appStoryboard.rawValue, bundle: nil)
        let identifier = String(describing: self)
        guard storyboard.instantiateViewController(withIdentifier: identifier) is T else {
            fatalError("ViewController with identifier \(identifier), not found in \(appStoryboard.rawValue)")
        }
        return storyboard.instantiateViewController(withIdentifier: identifier) as! T
    }
    
    class func pushVC(appStoryboard: AppStoryboard,navigationController : UINavigationController){
        let storyboard = UIStoryboard(name: appStoryboard.rawValue, bundle: nil)
        let identifier = String(describing: self)
        let vc = storyboard.instantiateViewController(withIdentifier: identifier)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func navigationBarWith(_ type: NavigationBarType, title: String){
        if type == .withTitle{
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.barTintColor = UIColor.navColor
            self.navigationController?.navigationBar.backgroundColor = UIColor.bgColor
            let sharedApplication = UIApplication.shared
              sharedApplication.delegate?.window??.tintColor = UIColor.bwColor

              if #available(iOS 13.0, *) {
                    let statusBar = UIView(frame: (sharedApplication.delegate?.window??.windowScene?.statusBarManager?.statusBarFrame)!)
                    statusBar.backgroundColor = UIColor.bgColor
                    sharedApplication.delegate?.window??.addSubview(statusBar)
                } else {
                    // Fallback on earlier versions
                    sharedApplication.statusBarView?.backgroundColor = UIColor.bgColor
              }
            self.navigationController?.navigationBar.tintColor = UIColor.bwColor
            self.navigationController?.navigationBar.isHidden = false
            self.navigationItem.title = title as String
            let textAttributes = [NSAttributedString.Key.foregroundColor: UIColor.bwColor, NSAttributedString.Key.font:  GlobalFunction.overrideFontSize(fontName: fontType.Hello_Valentina, fontSize: 40)] as [NSAttributedString.Key : Any]
            
            navigationController?.navigationBar.titleTextAttributes = textAttributes
            self.navigationController?.isNavigationBarHidden = false
            self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.plain, target:nil, action:nil)
        }else if type == .clearType {
            self.navigationController!.navigationBar.isTranslucent = true
            self.navigationController!.navigationBar.barTintColor = UIColor.clear
            self.navigationController!.navigationBar.barStyle = UIBarStyle.blackTranslucent
            self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController!.navigationBar.tintColor = .whiteColor
            self.navigationController?.navigationBar.isHidden = false
            self.navigationItem.title = title as String
            self.navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.whiteColor] as [NSAttributedString.Key : Any]
            self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        }else if type == .clearBlack {
            self.navigationController!.navigationBar.isTranslucent = true
            self.navigationController!.navigationBar.barTintColor = UIColor.clear
            self.navigationController!.navigationBar.barStyle = UIBarStyle.blackTranslucent
            self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController!.navigationBar.tintColor = .whiteColor
            self.navigationController?.navigationBar.isHidden = false
            self.navigationItem.title = title as String
            self.navigationController?.navigationBar.titleTextAttributes = [kCTForegroundColorAttributeName: UIColor.black] as [NSAttributedString.Key : Any]
            self.navigationController?.navigationBar.setValue(true, forKey: "hidesShadow")
        }else if type == .withLogo {
            self.navigationController!.navigationBar.isTranslucent = false
            self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
            self.navigationController!.navigationBar.barTintColor = UIColor.gray1Color
            self.navigationController!.navigationBar.tintColor = UIColor.whiteColor
            self.navigationController?.navigationBar.isHidden = false
            self.navigationItem.title = title as String
            let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.whiteColor, NSAttributedString.Key.font:  GlobalFunction.overrideFontSize(fontName: fontType.SFDIsplay_Semibold, fontSize: 18)] as [NSAttributedString.Key : Any]
            
            
            navigationController?.navigationBar.titleTextAttributes = textAttributes
            self.navigationController?.isNavigationBarHidden = false
        }
    }
    
    func setTitle(_ title: String, strurl: String , strName : String) {
        let titleLbl = UILabel()
        titleLbl.text = title
        titleLbl.textColor = UIColor.whiteColor
        titleLbl.font = GlobalFunction.overrideFontSize(fontName: fontType.SFDIsplay_Semibold, fontSize: 18)
        var imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        imageView.backgroundColor = .violetColor
        DispatchQueue.main.async {
            imageView.isRoundRect = true
//            imageView = GlobalFunction.setProfilePhoto(img: imageView, strbase: strurl, strImg: strName)
        }
        
        let titleView = UIStackView(arrangedSubviews: [imageView, titleLbl])
        titleView.axis = .horizontal
        titleView.spacing = 10.0
        navigationItem.titleView = titleView
    }
    
    func setViewLayout(view: UIView , frame: CGRect , cornerRadius: CGFloat ) -> UIView{
        view.frame = frame
        view.layer.cornerRadius = cornerRadius
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        view.clipsToBounds = true
        return view
    }
}

extension UIApplication {

var statusBarView: UIView? {
    return value(forKey: "statusBar") as? UIView
   }
}


