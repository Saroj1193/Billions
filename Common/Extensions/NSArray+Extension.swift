//
//  NSArray+Extension.swift
//  
//
//  Created by Tristate on 12/19/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import UIKit

extension NSArray {
    
    //change null to Blank
    func arrayByReplacingNullsWithBlanks() -> [AnyObject] {
        var replaced :  [AnyObject] = (self as [AnyObject])
        let nul : AnyObject = NSNull()
        let blank = ""
        //print(self)
        for index in 0..<replaced.count {
            let object = replaced[index] as AnyObject
            
            if  object === nul {
                replaced[index] =  blank as AnyObject
            }
                
            else if object is [String : AnyObject] {
                replaced[index] = (object as! NSDictionary).dictionaryByReplacingNullsWithBlanks() as AnyObject
            }
            else if object is [AnyObject] {
                replaced[index] = (object as! NSArray).arrayByReplacingNullsWithBlanks as AnyObject
            }
        }
        return replaced as [AnyObject]
    }
    
}


extension Array
{
    mutating func appendAtBeginning(newItem : Element){
        let copy = self
        self = []
        self.append(newItem)
        self.append(contentsOf: copy)
    }
    
}

 extension NSObject{
    
    ///Retruns the name of the class
    class var className: String{
        return NSStringFromClass(self).components(separatedBy: ".").last!
    }
    ///Retruns the name of the class
    var className: String{
        return NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
    }
}
