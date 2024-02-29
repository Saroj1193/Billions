//
//  BaseViewController.swift
//
//
//  Created by  on 11/18/19.
//  Copyright © 2019 . All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import AVFoundation
import CoreLocation
import Toast_Swift
import SwiftyJSON
import Photos

class BaseViewController: UIViewController {
    
    var viewSpinner: UIView = UIView()
    var activityIndicatorView: UIActivityIndicatorView?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let locationManager = CLLocationManager()
    var activityImage: UIImageView?
    
    enum alertType : Int{case success=0,error,info,media}
    
    //MARK:-View LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        isEnableIQKeyBoard()
        self.view.backgroundColor = UIColor.navColor
        logEvent(String(describing: type(of: self)), withData: [:])
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    var hideStatusBar: Bool = false {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return hideStatusBar
    }
    
    //MARK:- IBActions
    @IBAction func backButtonAction(sender: UIButton?) {
        if let navigationViewController = self.navigationController {
            navigationViewController.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK:-Location Function
    func setupLocation() -> CLLocationManager{
        locationManager.headingOrientation = .portrait
        locationManager.headingFilter = kCLHeadingFilterNone
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
            /*
             let locationService = checkLocationServiceStatus()
             if locationService.0{
             if locationService.1 == .authorizedWhenInUse{
             showLocationPermissionAlert(strLocation : "Allow always Authorization")
             }
             }else{
             showLocationPermissionAlert()
             }
             */
        }else {
            showLocationPermissionAlert()
        }
        
        return locationManager
    }
    
    var topInset: CGFloat{
        return view.safeAreaInsets.top
        
    }
    
    func checkLocationServiceStatus() -> (Bool,CLAuthorizationStatus){
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined : //Not choose
                return (false,.notDetermined)
            case .restricted : //Not Authorized
                return (false,.restricted)
            case .denied : //User Denied
                return (false,.denied)
            case .authorizedAlways : //Use for anytime
                return (true,.authorizedAlways)
            case .authorizedWhenInUse: //While they are using app.
                return (true,.authorizedWhenInUse)
            default:
                return (false,.notDetermined)
            }
        } else {
            print("Location services are not enabled")
            return (false,.notDetermined)
        }
    }
    
    func showLocationPermissionAlert(strLocation : String = "Please allow access to location Permission."){
        let alert : UIAlertController = UIAlertController.init(title: "Location Permisson", message: strLocation, preferredStyle: UIAlertController.Style.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
        let okAction = UIAlertAction(title: "Settings", style: UIAlertAction.Style.destructive) {
            UIAlertAction in
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    
}

//MARK:- FaceBook Login


//MARK:- CrashLytics Crash Reporting
extension BaseViewController {
    func logEvent(_ vcName: String, withData data: [String: CustomStringConvertible]) {
        let dataString = data.reduce("Event: \(vcName): ", { (result, element: (key: String, value: CustomStringConvertible)) -> String in
            return result + " (" + element.key + ": " + String(describing: element.value) + " )"
        })
        logEvent(dataString)
    }
    
    private func logEvent(_ message: String) {
        //        CLSLogv("%@", getVaList([message]))
    }
}

//UserDefault Key Contains
extension BaseViewController {
    func isKeyPresentInUserDefaults(key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
    
    func removeKeyFromUserDefaults(key: String){
        UserDefaults.standard.removeObject(forKey: key)
    }
}

//MARK:- Most Used Fucntions
extension BaseViewController {
    //MARK:- Navigation Functions
    func popToPerticularViewController(toVC:AnyClass) ->Void{
        let allViewController = self.navigationController!.viewControllers
        for aviewcontroller : UIViewController in allViewController
        {
            if aviewcontroller.isKind(of: toVC.self)
            {
                _ = self.navigationController?.popToViewController(aviewcontroller, animated: true)
                return
            }
        }
    }
    
    func isContainsVC(nav : UINavigationController,controller : AnyClass) -> Bool{
        let allViewController = self.navigationController!.viewControllers
        for aviewcontroller : UIViewController in allViewController
        {
            if aviewcontroller.isKind(of: controller.self)
            {
                return true
            }
        }
        return false
    }
    
    func logout() {
        
    }
    
}

//MARK:- KeyBoard Functions
extension BaseViewController {
    //IQKeyBoard
    func isEnableIQKeyBoard(_ enable : Bool = true,_ isOTPField : Bool = false){
        if enable{
            IQKeyboardManager.shared.enable = true
            IQKeyboardManager.shared.enableAutoToolbar = true
            if isOTPField{
                IQKeyboardManager.shared.toolbarConfiguration.placeholderConfiguration.showPlaceholder = false
            }
        }else{
            IQKeyboardManager.shared.enable = false
            IQKeyboardManager.shared.enableAutoToolbar = false
        }
    }
    
    //KeyBoard Observer
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                //                self.view.frame.origin.y -= keyboardSize.height //20 XR
                if let deviceType = UIDevice.current.deviceType{
                    switch deviceType {
                    case .iPhoneXR:
                        self.view.frame.origin.y -= 20
                        break;
                    case .iPhoneX:
                        self.view.frame.origin.y -= 20
                        break;
                    case .iPhone40:
                        self.view.frame.origin.y -= keyboardSize.height
                        break;
                    case .iPhone47:
                        self.view.frame.origin.y -= 90
                        break;
                    case .iPhone55:
                        self.view.frame.origin.y -= keyboardSize.height
                        break;
                    default:
                        self.view.frame.origin.y -= keyboardSize.height //KeyBoard Height
                        break
                    }
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    //KeyBoard Reset
    func emptyTextField(textField : [UITextField]){
        let _ = textField.map({$0.text = ""})
        view.endEditing(true)
    }
}


//MARK:- Medium Used Functions
extension BaseViewController {
    //MARK:- Validations
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidUrl(url: String) -> Bool {
        let urlRegEx = "^(https?://)?(www\\.)?([-a-z0-9]{1,63}\\.)*?[a-z0-9][-a-z0-9]{0,61}[a-z0-9]\\.[a-z]{2,6}(/[-\\w@\\+\\.~#\\?&/=%]*)?$"
        let urlTest = NSPredicate(format:"SELF MATCHES %@", urlRegEx)
        let result = urlTest.evaluate(with: url)
        return result
    }
    
    func trimString(string : String) -> String {
        let trimmedString = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return trimmedString
    }
    
    func isValidEmailEntered(strEmail : String) -> Bool{
        if strEmail.trimSpaces().count == 0 {
            self.view.makeToast(AlertMessage.ALERT_EMAIL_EMPTY)
            return false
        }else if !isValidEmail(testStr: strEmail.trimSpaces()){
            self.view.makeToast(AlertMessage.ALERT_VALID_EMAIL)
            return false
        }else{
            return true
        }
    }
    
    func setFlowLayOut(lineSpace : CGFloat = 0, itemSpacing : CGFloat = 0,sectionInset : UIEdgeInsets = .zero,scrollDirection : UICollectionView.ScrollDirection = .horizontal) -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = sectionInset
        flowLayout.minimumLineSpacing = lineSpace
        flowLayout.minimumInteritemSpacing = itemSpacing
        flowLayout.scrollDirection = scrollDirection
        return flowLayout
    }
}

//MARK:-Low Priority Function
extension BaseViewController {
    //MARK:- Netwok Rechability and Acticity Indicator
    func showSpinner(color: UIColor = .white) -> Void {
                if self.activityIndicatorView != nil {
                    self.activityIndicatorView?.removeFromSuperview()
                }
        
                if #available(iOS 13.0, *) {
                    self.activityIndicatorView = UIActivityIndicatorView(style: .large)
                } else {
                    self.activityIndicatorView = UIActivityIndicatorView(style: .white)
                }
                self.activityIndicatorView?.center =  CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: UIScreen.main.bounds.size.height / 2.0) //self.view.center
                self.activityIndicatorView?.color = color
                self.activityIndicatorView?.hidesWhenStopped = true
                self.activityIndicatorView?.startAnimating()
                APPData.appDelegate.window!.addSubview(self.activityIndicatorView!)
        
        
    }
    
    func showBottomSpinner(y: CGFloat, color: UIColor = .white) -> Void {
                if self.activityIndicatorView != nil {
                    self.activityIndicatorView?.removeFromSuperview()
                }
        
                if #available(iOS 13.0, *) {
                    self.activityIndicatorView = UIActivityIndicatorView(style: .large)
                } else {
                    self.activityIndicatorView = UIActivityIndicatorView(style: .white)
                }
                self.activityIndicatorView?.center =  CGPoint(x: UIScreen.main.bounds.size.width / 2.0, y: UIScreen.main.bounds.size.height / 2.0) //self.view.center
                self.activityIndicatorView?.color = color
                self.activityIndicatorView?.hidesWhenStopped = true
                self.activityIndicatorView?.startAnimating()
                APPData.appDelegate.window!.addSubview(self.activityIndicatorView!)
        
        
        
    }
    
    func hideSpinner() -> Void {
                self.activityIndicatorView?.startAnimating()
                if self.activityIndicatorView != nil {
                    self.activityIndicatorView?.removeFromSuperview()
                }
        
        
    }
    
    func isConnectedToNetwork() -> Bool {
        if (currentReachabilityStatus == ReachabilityStatus.reachableViaWiFi || currentReachabilityStatus == ReachabilityStatus.reachableViaWWAN) {
            return true
        }else{
            return false
        }
    }
       
    //MARK:- Alerts
    func showAlert(string : String, handler: ((UIAlertAction)->Void)? = nil) {
        let alertWarning = UIAlertController(title: APPData.APP_NAME, message: string, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "Okay", style: .cancel, handler: handler)
        alertWarning.addAction(defaultAction)
        self.present(alertWarning, animated: true, completion: nil)
    }
    
    func showAlertOKHandler(message : String,completion : ((() -> Void)?)) {
        let alertVC = UIAlertController(title: APPData.APP_NAME, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { (okAction) in
            NSLog("OK Pressed")
            self.dismiss(animated: true) {
//                userInfoManager.removeUserInfo()
//                let vc = GlobalFunction.fetchViewControllerWithName("LoginMainVC", storyBoardName: AppStoryboard.registration.rawValue) as! LoginMainVC
//                vc.hidesBottomBarWhenPushed = true
//                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    
    //MARK:- Open Torch For Camera
    func openTorch(torch: Bool) {
        let captureDeviceClass: AnyClass? = NSClassFromString("AVCaptureDevice")
        if captureDeviceClass != nil {
            let device = AVCaptureDevice.default(for: .video)
            if device?.hasTorch ?? false && device?.hasFlash ?? false {
                
                ((try? device?.lockForConfiguration()) as ()??)
                if device?.torchMode == .off {
                    device?.torchMode = .on
                } else {
                    device?.torchMode = .off
                }
                device?.unlockForConfiguration()
            }
        }
    }
    
    //MARK:- Attributed String
    func getAttributedString(strText: String, arrReplaceString: [String], color : [UIColor],fontSize : CGFloat,fontOther:UIFont? = nil,attrFont:UIFont? = nil) -> NSMutableAttributedString {
        let strAttr = NSMutableAttributedString.init(string: strText)
        
        let font : UIFont = fontOther == nil ? .regular(ofSize: fontSize) : fontOther! //Attr Font
        let font2 : UIFont = attrFont == nil ? .regular(ofSize: fontSize) : attrFont! //Not Attr Font
        strAttr.addAttribute(NSAttributedString.Key.font, value: font2, range: NSRange(location: 0,length: strAttr.length))
        for (index,strReplaceString) in arrReplaceString.enumerated(){
            if !strReplaceString.isEmpty{
                if let rangeOfStr = strText.range(of: strReplaceString){
                    let range  = strText.nsRange(from: rangeOfStr) //let range1 = NSRange(rangeOfStr, in: strText)
                    strAttr.addAttribute(NSAttributedString.Key.font, value: font, range: range)
                    strAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: color[index] , range: range)
                }
            }
        }
        
        let style = NSMutableParagraphStyle()
        
        style.lineSpacing = 2
        style.alignment = .center
        strAttr.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: NSRange(location: 0,length: strAttr.length))
        
        return strAttr
    }
}

//MARK:- Rare Used Functions
extension BaseViewController {
    
    func superScript(label : UILabel,string: String) {
        let font:UIFont? = .heavy(ofSize: 46)
        let fontSuper:UIFont? = .regular(ofSize: 30)
        let attString:NSMutableAttributedString = NSMutableAttributedString(string: string, attributes: [.font:font!])
        attString.setAttributes([.font:fontSuper!,.baselineOffset:10,NSAttributedString.Key.foregroundColor : UIColor(109,114,120)], range: NSRange(location:0,length:1))
        label.attributedText = attString
    }
    
    func setPhoneByFormat(phone:String) -> String{ //Phone Format 412 231 1111
        //MARK: - Phone Data Format
        if phone.count == 10{
            
            let myString1 = phone.mid(0, amount: 4)
            let myString2 = phone.mid(4, amount: 3)
            let myString3 = phone.mid(7, amount: 3)
            
            /* Using Range
             let str = phone
             let index = str.index(str.startIndex, offsetBy: 4)
             let mySubstring = str[..<index]
             let myString1 = String(mySubstring)
             
             let start = str.index(str.startIndex, offsetBy: 4)
             let end = str.index(str.endIndex, offsetBy: -3)
             let range = start..<end
             let mySubstring2 = str[range]
             
             let start1 = str.index(str.startIndex, offsetBy: 7)
             let end1 = str.index(str.endIndex, offsetBy: 0)
             let range1 = start1..<end1
             let mySubstring3 = str[range1]
             */
            
            let formattedPhone = myString1+" "+myString2+" "+myString3
            return formattedPhone
        }else{
            return phone
        }
    }
    
    //MARK:- Other Common Functions
    
    //Use for static lat-long for clustering
    func getJsonDatafromFile(fileName : String) -> Array<Dictionary<String,Any>> {
        var arrData : Array<Dictionary<String,Any>> = []
        
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            print("Path Is Not Found")
            return arrData
        }
        
        do {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? Array<Dictionary<String,Any>> ?? [] else {
                return arrData
            }
            arrData =  json.map({$0})
            return arrData
        }catch {
            print("Error Is",error.localizedDescription)
        }
        return arrData
    }
    
}


//MARK:- Not Used Functions
extension BaseViewController {
    func getVariablefromModel(model : Any) {
        let mirror = Mirror(reflecting: model)
        for (index, attr) in mirror.children.enumerated() {
            print("Index \(index)  Variables \(String(describing:attr.label))")
        }
    }
}

