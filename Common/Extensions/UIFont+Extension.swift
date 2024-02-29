//
//  UIFont+Extension.swift
//  
//
//  Created by Tristate Technology on 19/12/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import Foundation
import UIKit

extension UIFont{
    class func regular(ofSize size: CGFloat) -> UIFont {
        guard let font =  UIFont(name: "AvenirLTStd-Book", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    class func medium(ofSize size: CGFloat) -> UIFont {
        guard let font =  UIFont(name: "AvenirLTStd-Medium", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    class func light(ofSize size: CGFloat) -> UIFont {
        guard let font =  UIFont(name: "AvenirLTStd-Light", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
  
    class func black(ofSize size: CGFloat) -> UIFont {
        guard let font =  UIFont(name: "AvenirLTStd-Black", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
    
    class func heavy(ofSize size: CGFloat) -> UIFont {
        guard let font =  UIFont(name: "Avenir-Heavy", size: size) else {
            return UIFont.systemFont(ofSize: size)
        }
        return font
    }
}
