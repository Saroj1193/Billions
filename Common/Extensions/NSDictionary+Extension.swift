//
//  NSDictionary+Extension.swift
//  
//
//  Created by Tristate on 12/19/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import UIKit

extension NSDictionary{
    
    //null to Blank
    func dictionaryByReplacingNullsWithBlanks() -> [String : AnyObject] {
        var replaced :  [String: Any] = (self as? [String : Any])!
        let nul : AnyObject = NSNull()
        let blank = ""
        //print(self)
        for (key,value) in self {
            
            if  value as AnyObject? === nul {
                replaced[key as! String] =  blank
            }
            else if value is [String : AnyObject] {
                replaced[key as! String] = (value as! NSDictionary).dictionaryByReplacingNullsWithBlanks()
            }
            else if value is [AnyObject] {
                replaced[key as! String] = (value as! NSArray).arrayByReplacingNullsWithBlanks()
            }
            
        }
        return replaced as [String : AnyObject]
    }
    
}

extension Dictionary {
    
    func dictionaryByReplacingNullsWithBlanks() -> [String : AnyObject] {
        var replaced :  [String: Any] = (self as? [String : Any])!
        let nul : AnyObject = NSNull()
        let blank = ""
        //print(self)
        for (key,value) in self {
            
            if  value as AnyObject? === nul {
                replaced[key as! String] =  blank
            }
            else if value is [String : AnyObject] {
                replaced[key as! String] = (value as! [String : AnyObject]).dictionaryByReplacingNullsWithBlanks()
            }
            else if value is [AnyObject] {
                replaced[key as! String] = (value as! NSArray).arrayByReplacingNullsWithBlanks()
            }
        }
        return replaced as [String : AnyObject]
    }
}
