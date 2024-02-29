//
//  GradientView.swift
//  
//
//  Created by Tristate Technology on 09/12/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import UIKit

class GradientView: UIView {

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        createGradientLayer()
    }
    
    func createGradientLayer() {
        let gradientLayer = CAGradientLayer()
     
        gradientLayer.frame = self.bounds
     
        gradientLayer.colors = [UIColor(hex: "01A1E3").cgColor, UIColor(hex: "C3EEFF").cgColor]
        self.layer.cornerRadius = self.cornerRadius
        self.layer.addSublayer(gradientLayer)
    }

}
