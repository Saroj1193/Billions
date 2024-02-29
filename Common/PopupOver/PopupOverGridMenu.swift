//
//  PopupOverGridMenu.swift
//  BillionsApp
//
//  Created by tristate22 on 28.02.24.
//

import Foundation
import UIKit

public class PopupOverGridMenu {
    
    /**
     Defines direction from which menu appears
     - fromTop: Appears from the Top
     - fromLeft: Appears from the Left
     - fromRight: Appears from the Right
     */
    public enum PopupOverGridMenuAppear: Int {
        case fromTop
        case fromLeft
        case fromRight
    }
    
    /**
     Defines direction to which menu disappears
     - toBottom: Disappears to the Bottom
     - toLeft: Disappears to the Left
     - toRight: Disappears to the Right
     */
    public enum PopupOverGridMenuDismiss: Int {
        case toBottom
        case toLeft
        case toRight
    }
    
    /// private grid menu controller
    private var controller : PopupOverGridMenuController
    
    /// private init to use only fabric methods
    private init() {
        self.controller = PopupOverGridMenuController()
    }
    
    /**
     Present view controller with navigation controller from view controller
     - parameters:
     - fromViewController: View controller from which menu view controller is presented
     - appear: Defines direction from which menu appears
     - leftBarButtonItem: Bar button item from which menu is presented
     - rightBarButtonItem: Bar button item from which menu is presented
     - items: Array of menu items
     - itemSize: Size of menu item (width and height)
     - action: The action handler, occurs when item is selected
     - completion: The completion handler, will be invoked after menu dismissing
     */
    @discardableResult
    public static func present(_ fromViewController: UIViewController, appear: PopupOverGridMenuAppear, leftBarButtonItem: UIBarButtonItem?, rightBarButtonItem: UIButton?, items: [PopupMenuItem], itemSize: CGSize, action: ((PopupMenuItem) -> Swift.Void)? = nil, completion: (() -> Swift.Void)? = nil) -> PopupOverGridMenu {
        
        let menu = PopupOverGridMenu()
        menu.controller.items = items
        menu.controller.itemSize = itemSize
        menu.controller.appear = appear
        menu.controller.action = action
        menu.controller.completion = completion
        
        if let menuImage = leftBarButtonItem?.image {
            let leftBarButtonItem = UIBarButtonItem(image: menuImage, style: UIBarButtonItem.Style.plain, target: menu.controller.self, action: #selector(menu.controller.dismissMenu(sender:)))
            menu.controller.navigationItem.leftBarButtonItem = leftBarButtonItem
        }
        
//        if let menuImage = rightBarButtonItem?.image {
//            let rightBarButtonItem = UIBarButtonItem(image: menuImage, style: UIBarButtonItem.Style.plain, target: menu.controller.self, action: #selector(menu.controller.dismissMenu(sender:)))
//            menu.controller.navigationItem.rightBarButtonItem = rightBarButtonItem
//        }
        
        let navigationController = UINavigationController(rootViewController: menu.controller)
        navigationController.transitioningDelegate = menu.controller.self
        navigationController.modalPresentationStyle = UIModalPresentationStyle.custom
        
        fromViewController.present(navigationController, animated: true)
        
        return menu
    }
    
    /**
     Present popover from view controller
     - parameters:
     - fromViewController: View controller from which popover is presented
     - appear: Defines direction from which menu appears
     - sender: Bar button item from which popover is presented
     - items: Array of menu items
     - itemSize: Size of menu item (width and height)
     - contentSize: Size of popover content view (width and height)
     - action: The action handler, occurs when item is selected
     - completion: The completion handler, will be invoked after popover menu dismissing
     */
    @discardableResult
    public static func presentPopover(_ fromViewController: UIViewController, appear: PopupOverGridMenuAppear, sender: UIButton, items: [PopupMenuItem], itemSize: CGSize, direction: UIPopoverArrowDirection = .down, contentSize: CGSize, action: ((PopupMenuItem) -> Swift.Void)? = nil, completion: (() -> Swift.Void)? = nil) -> PopupOverGridMenu {
        
        let menu = PopupOverGridMenu()
        menu.controller.items = items
        menu.controller.itemSize = itemSize
        menu.controller.appear = appear
        menu.controller.isPopover = true
        menu.controller.action = action
        menu.controller.completion = completion
        menu.controller.modalPresentationStyle = UIModalPresentationStyle.popover
        menu.controller.popoverPresentationController?.permittedArrowDirections = direction
        menu.controller.popoverPresentationController?.delegate = menu.controller.self
        menu.controller.popoverPresentationController?.sourceView = sender
        menu.controller.preferredContentSize = contentSize
        
        fromViewController.present(menu.controller, animated: true)
        
        return menu
    }
    
    /**
     Dismiss view controller
     - parameters:
     - animated: Dismiss view with animation if true
     **/
    public func dismiss(animated flag: Bool = true) {
        self.controller.dismiss(animated: flag)
    }
}
