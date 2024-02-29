//
//  SplashVC.swift
//  BillionsApp
//
//  Created by tristate22 on 20.02.24.
//

import UIKit
import FirebaseAuth

class SplashVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = true
        if Auth.auth().currentUser != nil {
            let currentUID = Auth.auth().currentUser?.uid ?? ""
            FireStoreChat.shared.getUserDetails(docId: currentUID) { data in
                if data.count > 0 {
                    APPData.appDelegate.loginUserData = [UserData.init(dictionary: data[0])]
                    print(APPData.appDelegate.loginUserData)
                    let initialViewController : UIViewController = GlobalFunction.fetchViewControllerWithName("ChatListVC", storyBoardName: AppStoryboard.registration.rawValue) as! ChatListVC
                    let nav = UINavigationController.init(rootViewController: initialViewController)
                    APPData.appDelegate.window?.makeKeyAndVisible()
                    APPData.appDelegate.window?.rootViewController = nav
                } else {
                    let destination = GlobalFunction.fetchViewControllerWithName("UserProfileVC", storyBoardName: AppStoryboard.registration.rawValue) as! UserProfileVC
                    destination.number = Auth.auth().currentUser?.phoneNumber ?? ""
                    
                    let nav = UINavigationController.init(rootViewController: destination)
                    APPData.appDelegate.window?.makeKeyAndVisible()
                    APPData.appDelegate.window?.rootViewController = nav
                }
            }
        } else {
            let initialViewController : UIViewController = GlobalFunction.fetchViewControllerWithName("LoginVC", storyBoardName: AppStoryboard.registration.rawValue) as! LoginVC
            let nav = UINavigationController.init(rootViewController: initialViewController)
            APPData.appDelegate.window?.makeKeyAndVisible()
            APPData.appDelegate.window?.rootViewController = nav
            
        }
    }
}
