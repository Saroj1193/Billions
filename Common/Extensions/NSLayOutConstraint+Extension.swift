//
//  NSLayOutConstraint+Extension.swift
//  
//
//  Created by Tristate on 12/13/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import Foundation
import UIKit

//Set up Multiplier
extension NSLayoutConstraint {
    func constraintWithMultiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: self.firstItem!, attribute: self.firstAttribute, relatedBy: self.relation, toItem: self.secondItem, attribute: self.secondAttribute, multiplier: multiplier, constant: self.constant)
    }
}

/*
let newConstraint = constraintToChange.constraintWithMultiplier(0.75)
view.removeConstraint(constraintToChange)
view.addConstraint(newConstraint)
view.layoutIfNeeded()
constraintToChange = newConstraint
*/
