//
//  PopupMenuItem.swift
//  BillionsApp
//
//  Created by tristate22 on 28.02.24.
//

import Foundation
import UIKit

public class PopupMenuItem {
    var text: String
    var attributedText: NSAttributedString
    var image: String
    var isSelected = false
    var colors: [UIColor?]
    
    public init(text: String, image: String, selected: Bool, colors: [UIColor?] = []) {
        
        self.text = text
        self.attributedText = NSAttributedString()
        self.image = image
        self.isSelected = selected
        self.colors = colors
    }
    
    public init(attributedText: NSAttributedString, image: String, selected: Bool, colors: [UIColor?]) {
        
        self.text = String()
        self.attributedText = attributedText
        self.image = image
        self.isSelected = selected
        self.colors = colors
    }
}
