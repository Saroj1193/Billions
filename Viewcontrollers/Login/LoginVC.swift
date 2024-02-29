//
//  ViewController.swift
//  BillionsApp
//
//  Created by Tristate on 20.10.21.
//

import UIKit
import CountryPicker
import Firebase
import SafariServices


class LoginVC: BaseViewController {
    // MARK: - Variable
    @IBOutlet var imgFlag: UIImageView!
    @IBOutlet var btnCountryCode: UIButton!
    @IBOutlet var txtCountryCode: CustomeTextField!
    @IBOutlet var txtPhone: CustomeTextField!
    @IBOutlet var btnLogin: CustomBtnSFPDBold!
    @IBOutlet weak var lblTitle: CustomLblSFPDBold!

    var Countrypicker = CountryPicker()
    var isVerificationSent = false
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setCountryPicker()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationBarWith(.withTitle, title: strLogin)
    }
    
    // MARK: - Country Picker
    func setCountryPicker() ->Void {
        let locale = Locale.current
        let code = (locale as NSLocale).object(forKey: NSLocale.Key.countryCode) as! String?
        Countrypicker.countryPickerDelegate = self
        Countrypicker.showPhoneNumbers = true
        Countrypicker.setCountry(code!)
        
        let pickerViewToolBar = UIToolbar()
        pickerViewToolBar.barStyle = UIBarStyle.default
        pickerViewToolBar.isTranslucent = true
        pickerViewToolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: ConstantText.lngDone, style: UIBarButtonItem.Style.plain, target: self, action: #selector(donePicker))
        doneButton.tintColor = UIColor.bwColor
        pickerViewToolBar.setItems([doneButton], animated: true)
        pickerViewToolBar.isUserInteractionEnabled = true
        Countrypicker.backgroundColor = .whiteColor
        pickerViewToolBar.backgroundColor = UIColor.gray1Color
        txtCountryCode.inputView = self.Countrypicker
        txtCountryCode.inputAccessoryView = pickerViewToolBar
        txtCountryCode.tintColor = .clear
    }
    // MARK: - Button Action
    @IBAction func btnCountryCodeAction(_ sender: Any) {
    }
    
    @objc func donePicker() ->Void { //action
        self.txtCountryCode.resignFirstResponder()
        txtCountryCode.inputAccessoryView?.removeFromSuperview()
    }
    
    @IBAction func btnLoginAction(_ sender: Any) {
        if currentReachabilityStatus == .notReachable {
            self.view.makeToast(noInternetError)
          return
        }
        if !isVerificationSent && checkValidation() {
          sendSMSConfirmation()
        } else {
            self.view.makeToast("verification has already been sent once")
        }
    }
    
    // MARK: -  Validation
    func checkValidation() -> Bool {
        if txtPhone.text!.trimSpaces().isEmpty {
            self.view.makeToast("Please enter phone number")
            return false
        } else {
            return true
        }
    }
    
   
    func sendSMSConfirmation() {
        let phoneNumberForVerification = "\(self.btnCountryCode.titleLabel?.text! ?? "")\(self.txtPhone.text!)"

      PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumberForVerification, uiDelegate: nil) { (verificationID, error) in
        if let error = error {
            self.view.makeToast(error.localizedDescription)
          return
        }
        self.isVerificationSent = true
        userDefaults.updateObject(for: userDefaults.authVerificationID, with: verificationID)
        userDefaults.updateObject(for: userDefaults.changeNumberAuthVerificationID, with: verificationID)
        
        let vc = GlobalFunction.fetchViewControllerWithName("VerifyOTPVC", storyBoardName: AppStoryboard.registration.rawValue) as! VerifyOTPVC
        vc.number = phoneNumberForVerification
        self.navigationController?.pushViewController(vc, animated: true)
      }
    }
}

// MARK: - CountryPickerDelegate delegate
extension LoginVC: CountryPickerDelegate{
    func countryPhoneCodePicker(_ picker: CountryPicker, didSelectCountryWithName name: String, countryCode: String, phoneCode: String, flag: UIImage) {
        self.btnCountryCode.setTitle("\(phoneCode)", for: .normal)
        self.imgFlag.image = flag
    }
}
// MARK: - UITextFieldDelegate
extension LoginVC : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case txtCountryCode:
            return false
            
        default:
            return true
        }
    }
}
