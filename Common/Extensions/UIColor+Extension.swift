//
//  UIColor+Extension.swift
//  
//
//  Created by Tristate on 11/18/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    //MARK:- Shoping Cart Badge
    
    static let badgeColorWhite =  UIColor(red:0.00, green:0.00, blue:0.00, alpha:0.25)
    
    static let appTheme : UIColor = #colorLiteral(red: 0, green: 0.6710000038, blue: 0.949000001, alpha: 1)
    static let lightTheme:UIColor = UIColor(hex: "ffffff")
    static let greenColor : UIColor = UIColor(hex: "40d58b")
    
    convenience init(hex: String) {
        self.init(hex: hex, alpha:1)
    }
    
    /// Convenience initalizer for hex strings
    ///
    /// - Parameters:
    ///   - hex: hex value
    ///   - alpha: alpha value
    convenience init(hex: String, alpha: CGFloat) {
        var hexWithoutSymbol = hex
        if hexWithoutSymbol.hasPrefix("#") {
            hexWithoutSymbol = hex.substring(1)
        }
        
        let scanner = Scanner(string: hexWithoutSymbol)
        var hexInt: UInt32 = 0x0
        scanner.scanHexInt32(&hexInt)
        
        var r: UInt32!, g: UInt32!, b: UInt32!
        switch (hexWithoutSymbol.length) {
        case 3: // #RGB
            r = ((hexInt >> 4) & 0xf0 | (hexInt >> 8) & 0x0f)
            g = ((hexInt >> 0) & 0xf0 | (hexInt >> 4) & 0x0f)
            b = ((hexInt << 4) & 0xf0 | hexInt & 0x0f)
            break
        case 6: // #RRGGBB
            r = (hexInt >> 16) & 0xff
            g = (hexInt >> 8) & 0xff
            b = hexInt & 0xff
            break
        default:
            // TODO:ERROR
            break
        }
        
        self.init(
            red: (CGFloat(r)/255),
            green: (CGFloat(g)/255),
            blue: (CGFloat(b)/255),
            alpha:alpha)
    }
    
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
    
    convenience init(_ r:CGFloat,_ g:CGFloat,_ b:CGFloat,_ alpha : CGFloat = 1.0){
        self.init(red: (r/255),green: (g/255),blue: (b/255),alpha:alpha)
    }
}
