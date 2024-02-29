//
//  PopupOverMenuTransitionController.swift
//  BillionsApp
//
//  Created by tristate22 on 28.02.24.
//

import Foundation
import UIKit

class PopupOverMenuTransitionController: NSObject {
    var isPresenting = false
}

// MARK: - UIViewControllerAnimatedTransitioning

extension PopupOverMenuTransitionController: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
        let toViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
        let containerView = transitionContext.containerView
        
        if self.isPresenting {
            let navigationController = toViewController as! UINavigationController
            let menuController = navigationController.topViewController as! PopupOverGridMenuController
            
            navigationController.view.frame = containerView.bounds
            containerView.addSubview(navigationController.view)
            
            OperationQueue.main.addOperation({
                menuController.enterTheStage({
                    transitionContext.completeTransition(true)
                })
            })
        } else {
            let navigationController = fromViewController as! UINavigationController
            let menuController = navigationController.topViewController as! PopupOverGridMenuController
            
            menuController.leaveTheStage({
                navigationController.view.removeFromSuperview()
                transitionContext.completeTransition(true)
            })
        }
    }
}
