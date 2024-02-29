//
//  VerifyOTPVC.swift
//
//
//  Created by  on 01/10/20.
//  Copyright © 2020 . All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import SwiftyJSON
import FirebaseAnalytics
import Firebase
import FirebaseAuth

class VerifyOTPVC: BaseViewController {
    @IBOutlet var lblTitle: CustomLblSFPDBold!
    @IBOutlet weak var txtWhite: CustomeTextField!
    @IBOutlet var viewResend: UIView!
    @IBOutlet var btnResend: CustomBtnSFPDBold!
    
    var number = ""
    var intTimer = 120
    var timer = Timer()
    var isTimerRunning = false
    let userExistenceChecker = UserExistenceChecker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setViewLayout()
        self.navigationItem.hidesBackButton = true
        navigationItem.title = strVerification
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    func setViewLayout(){
        self.btnResend.setTitleColor(.bwColor, for: .normal)
        self.txtWhite.font = GlobalFunction.overrideFontSize(fontName: .SFProDisplay_Bold, fontSize: 20)
        if !txtWhite.isFirstResponder {
            txtWhite.becomeFirstResponder()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    //MARK: - Button Action
    @IBAction func btnNextAction(_ sender: Any) {
        txtWhite.resignFirstResponder()
        view.endEditing(true)
        checkValidation()
    }
    
    @IBAction func btnResendAction(_ sender: Any) {
        txtWhite.text = ""
        self.sendSMSConfirmation()
    }
    
    //MARK:- Check Validation
    func checkValidation() {
        self.view.endEditing(true)
        if txtWhite.text?.count == 0{
            self.view.makeToast(AlertMessage.ALERT_OTP_EMPTY)
        }else {
            self.authenticate()
        }
    }
    
    @objc fileprivate func sendSMSConfirmation () {
        if currentReachabilityStatus == .notReachable {
            self.view.makeToast(noInternetError)
            return
        }
        
        self.btnResend.isEnabled = false
        
        let phoneNumberForVerification = number
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberForVerification, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                basicErrorAlertWith(title: "Error", message: error.localizedDescription + "\nPlease try again later.", controller: self)
                return
            }
            self.btnResend.isEnabled = false
            userDefaults.updateObject(for: userDefaults.authVerificationID, with: verificationID)
            self.runTimer()
        }
    }
    
    func runTimer() {
        self.btnResend.isEnabled = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(updateTimer)), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        if intTimer < 1 {
            resetTimer()
            self.btnResend.isEnabled = true
        } else {
            intTimer -= 1
        }
    }
    
    func resetTimer() {
        timer.invalidate()
        intTimer = 120
    }
    
    func authenticate() {
        if currentReachabilityStatus == .notReachable {
            basicErrorAlertWith(title: "No internet connection", message: noInternetError, controller: self)
            return
        }
        
        guard let verificationID = userDefaults.currentStringObjectState(for: userDefaults.authVerificationID) else { return  }
        
        let verificationCode = self.txtWhite.text!
        
        if currentReachabilityStatus == .notReachable {
            basicErrorAlertWith(title: "No internet connection", message: noInternetError, controller: self)
        }
        
        self.showSpinner()
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (_, error) in
            if error != nil {
                self.hideSpinner()
                basicErrorAlertWith(title: "Error",
                                    message: error?.localizedDescription ?? "Oops! Something happened, try again later.",
                                    controller: self)
                return
            }
            NotificationCenter.default.post(name: .authenticationSucceeded, object: nil)
            self.userExistenceChecker.delegate = self
            self.userExistenceChecker.checkIfUserDataExists()
        }
    }

}

//MARK: - UITextField Delegate
extension VerifyOTPVC : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension VerifyOTPVC: UserExistenceDelegate {
    func user(isAlreadyExists: Bool, name: String?, bio: String?, image: UIImage?) {
        let destination = GlobalFunction.fetchViewControllerWithName("UserProfileVC", storyBoardName: AppStoryboard.registration.rawValue) as! UserProfileVC
        destination.number = number

        self.hideSpinner()
        if !isAlreadyExists {
            self.navigationController?.pushViewController(destination, animated: true)
        } else {
            if Messaging.messaging().fcmToken != nil {
                setUserNotificationToken(token: Messaging.messaging().fcmToken!)
            }
            setOnlineStatus()
            let destination = GlobalFunction.fetchViewControllerWithName("ChatListVC", storyBoardName: AppStoryboard.registration.rawValue) as! ChatListVC
            self.navigationController?.pushViewController(destination, animated: true)
        }
    }
}
