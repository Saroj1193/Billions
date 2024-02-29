//
//  UpdateLayoutConstraint.swift
//  
//
//  Created by Tristate on 11/19/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import UIKit

class UpdateLayoutConstraint: NSLayoutConstraint {
    @IBInspectable var iPhone4 : CGFloat = 0.0 {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhone35:
                    self.constant = iPhone4
                    break
                default:
                    break
                }
            }
        }
    }
    
    
    
    @IBInspectable var iPhone5 : CGFloat = 0.0 {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhone40:
                    self.constant = iPhone5
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBInspectable var iPhone6 : CGFloat = 0.0 {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhone47:
                    self.constant = iPhone6
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBInspectable var iPhone6Plus : CGFloat = 0.0 {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhone55:
                    self.constant = iPhone6Plus
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBInspectable var iPhoneX : CGFloat = 0.0 {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhoneX:
                    self.constant = iPhoneX
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBInspectable var iPhoneXR : CGFloat = 0.0 {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhoneXR:
                    self.constant = iPhoneXR
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBInspectable var iPad : CGFloat = 0.0 {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPad:
                    self.constant = iPad
                    break
                default:
                    break
                }
            }
        }
    }
    
    //MARK:- Active InActive Cons
    
    @IBInspectable var iPhone4Active : Bool = true {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhone35:
                    self.isActive = iPhone4Active
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBInspectable var iPhone5Active : Bool = true {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhone40:
                    self.isActive = iPhone5Active
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBInspectable var iPhone6Active : Bool = true {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhone47:
                    self.isActive = iPhone6Active
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBInspectable var iPhone6PlusActive : Bool = true {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhone55:
                    self.isActive = iPhone6PlusActive
                    break
                default:
                    break
                }
            }
        }
    }
    @IBInspectable var iPhoneXActive : Bool = true {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhoneX:
                    self.isActive = iPhoneXActive
                    break
                default:
                    break
                }
            }
        }
    }
    
    @IBInspectable var iPhoneXRActive : Bool = true {
        didSet {
            if let deviceType = UIDevice.current.deviceType{
                switch deviceType{
                    
                case .iPhoneXR:
                    self.isActive = iPhoneXRActive
                    break
                default:
                    break
                }
            }
        }
    }
}
