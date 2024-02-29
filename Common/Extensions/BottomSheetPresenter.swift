//
//  BottomSheetPresenter.swift
//  
//
//  Created by Tristate on 12/9/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import Foundation

import UIKit

class BottomSheetPresenter: NSObject , UIViewControllerAnimatedTransitioning {
    public private(set) var isPresenting: Bool = false
    public private(set) var sheetHeight: CGFloat = 0
    public private(set) var transitionDuration : TimeInterval = 0.0
    public init(isPresenting: Bool,transitionDuration : TimeInterval ,sheetHeight: CGFloat = 200) {
        self.isPresenting = isPresenting
        self.sheetHeight = sheetHeight
        self.transitionDuration = transitionDuration
    }
    
    private var dimmingView: UIView?
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView = transitionContext.view(forKey: .from)
        let toView = transitionContext.view(forKey: .to)
        
        let duration = self.transitionDuration(using: transitionContext)
        let screenHeight = UIScreen.main.bounds.height
        
        if isPresenting, let toView = toView {
            let dimmingView = UIView(frame: UIScreen.main.bounds)
            dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            dimmingView.alpha = 0.0
            transitionContext.containerView.addSubview(dimmingView)
            self.dimmingView = dimmingView
            
            toView.frame.origin.y = screenHeight
            transitionContext.containerView.addSubview(toView)
            
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
                toView.frame.origin.y = screenHeight - self.sheetHeight
                dimmingView.alpha = 1.0
            }, completion: { (finished) in
                transitionContext.completeTransition(finished)
            })
        }
        else if let fromView = fromView {
            UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
                fromView.frame.origin.y = screenHeight
                self.dimmingView?.alpha = 0.0
            }, completion: { (finished) in
                transitionContext.completeTransition(finished)
            })
        }
    }
}
