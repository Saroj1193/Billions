//
//  GlobalFunction.swift
//  
//
//  Created by  on 04/07/20.
//  Copyright © 2020 . All rights reserved.
//

import UIKit
import SDWebImage

class GlobalFunction {
    static func overrideFontSize(fontName: fontType,fontSize:CGFloat) -> UIFont {
        let currentFontName = fontName.rawValue
        let bounds = UIScreen.main.bounds
        let height = bounds.size.height
        switch height {
        case 480.0: //Iphone 3,4,SE => 3.5 inch
            return UIFont(name: currentFontName, size: fontSize * 0.6)!
        case 568.0: //iphone 5, 5s => 4 inch , SE
            return UIFont(name: currentFontName, size: fontSize * 0.7)!
        case 667.0: //iphone 6, 6s => 4.7 inch, iPhone 8, iPhone 6s Plus,iPhone 7
            return UIFont(name: currentFontName, size: fontSize * 0.8)!
        case 736.0: //iphone 6s+ 6+ => 5.5 inch, iPhone 8 Plus , iPhone 7 Plus
            return UIFont(name: currentFontName, size: fontSize*0.9)!
        case 812.0: //iphone x
            return UIFont(name: currentFontName, size: fontSize * 1)!
        case 896.0: //iphone XR , XS max
            return UIFont(name: currentFontName, size: fontSize * 1.1)!
        default:
            return UIFont(name: currentFontName, size: fontSize)!
        }
    }
    
    //MARK:- Time Ago
    class func timeAgo(_ createdAt: Int) -> String {
        let timeInterval:Double = Double(createdAt)
        let timeAt:TimeInterval =   timeInterval
        
        var calendar = NSCalendar.current
        calendar.timeZone = .current
        let date = Date(timeIntervalSince1970: timeAt)
        
        let second = Calendar.current.dateComponents([.second], from: date, to: Date()).second ?? 0
        
        let deltaSeconds = Double(second)
        let deltaMinutes:Double = deltaSeconds / 60
        
        var minutes: Int
        if deltaSeconds < 60 {
            return "Just now"
        }else if deltaSeconds < 120 {
            return String(format: "1m ago", deltaMinutes)
        }else if deltaMinutes < 60 {
            return String(format: "%.0fm ago", deltaMinutes)
        }
        else if deltaMinutes < 120 {
            return "1h ago"
        }
        else if deltaMinutes < (24 * 60) {
            minutes = Int(floor(deltaMinutes / 60))
            return "\(minutes)h ago"
        }else if deltaMinutes < (24 * 60 * 7) {
            minutes = Int(floor(deltaMinutes / (60 * 24)))
            if minutes == 1
            {
                return "\(minutes)d ago"
            }else{
                return "\(minutes)d ago"
            }
        }
        else if deltaMinutes < (24 * 60 * 14) {
            return "1w ago"
        }
        else if deltaMinutes < (24 * 60 * 31) {
            minutes = Int(floor(deltaMinutes / (60 * 24 * 7)))
            return "\(minutes)w ago"
        }
        else if deltaMinutes < (24 * 60 * 61) {
            return "1mo ago"
        }
        else if deltaMinutes < (24 * 60 * 365.25) {
            minutes = Int(floor(deltaMinutes / (60 * 24 * 30)))
            return "\(minutes)mo ago"
        }
        else if deltaMinutes < (24 * 60 * 731) {
            return "1y ago"
        }
        
        minutes = Int(floor(deltaMinutes / (60 * 24 * 365)))
        return "\(minutes)y ago"
        
    }
    
    
    class func shareText(view: UIViewController){
        let text = "Checkout this interesting App: "
        let url = URL.init(string: "https://apps.apple.com/us/app/chatout/id1568232526")
        let shareAll: [Any] = [text, url!]
        let activityViewController = UIActivityViewController(activityItems: shareAll, applicationActivities: nil)
        
        activityViewController.popoverPresentationController?.sourceView = view.view
        activityViewController.completionWithItemsHandler = { activity, success, items, error in
            if !success{
                return
            }
        }
        view.present(activityViewController, animated: true, completion: nil)

    }
    
   
    
    
    
    //MARK:- Time Ago
    class func ageYear(_ strDate: String) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        var datecheck = Date()
        
        if let date = dateFormatter.date(from: strDate.components(separatedBy: "T").first ?? ""){
            datecheck = date
        }
      
        let year = Calendar.current.dateComponents([.year], from: datecheck, to: Date()).year ?? 0
        
        
        return "\(year)"
        
    }
    
    static func dateFormatFromString(strDate: Date, formate: String) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formate //strDate.dateFormatWithSuffix()
        let date = dateFormatter.string(from: strDate)
        return date
    }
    
    
    static func dateFormatFromDate(strDate: String) -> Date{
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: strDate){
            return date
        }
        return Date()
    }
    
    //MARK: user defaults Methods
    class func getValueFromUserDefaultsForKey(keyName: String!) -> AnyObject? {
        
        if !self.checkIfStringContainsText(string: keyName) {
            return nil
        }
        
        let value: AnyObject? = UserDefaults.standard.object(forKey: keyName) as AnyObject?
        
        if value != nil {
            return value
        }else {
            return nil
        }
    }
    
    //MARK:- Set value to user defaults
    class func setValueToUserDefaultsForKey(keyName: String!, value: AnyObject!) {
        
        if !self.checkIfStringContainsText(string: keyName) {
            return
        }
        if value == nil {
            return
        }
        UserDefaults.standard.set(value, forKey: keyName)
        UserDefaults.standard.synchronize()
    }
    
    //MARK: Check For Empty String
    class func checkIfStringContainsText(string: String?) -> Bool {
        if let stringEmpty = string {
            let newString = stringEmpty.trimmingCharacters(in: CharacterSet.whitespaces)
            if (newString.isEmpty) {
                return false
            }
            return true
        }else {
            return false
        }
    }
    
   
    
    class func fetchViewControllerWithName(_ vcName: String, storyBoardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyBoardName, bundle: nil)
        let controller: UIViewController = storyboard.instantiateViewController(withIdentifier: vcName)
        return controller
    }
    
    class func apiCallForSetDeviceToken() {
        
        var dictParam : Dictionary<String,Any> = [:]
        
        APIController.requestForSetUserDeviceRelation(dictParam:dictParam) { (dictData, strError) in
            
        }
    }
    
    class func checkLogin()-> Bool{
        if (UserDefaults.standard.object(forKey: "isLogin") != nil) {
            if UserDefaults.standard.bool(forKey: "isLogin") == true{
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
  
}



import StoreKit

enum AppStoreReviewManager {
  static let minimumReviewWorthyActionCount = 3

  static func requestReviewIfAppropriate() {
    let defaults = UserDefaults.standard
    let bundle = Bundle.main

    let bundleVersionKey = bundle.infoDictionary!["CFBundleVersion"] as! String
    let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
    let lastVersion = defaults.string(forKey: .lastReviewRequestAppVersion)

    if lastVersion != nil || lastVersion != currentVersion {
        defaults.set(0, forKey: .reviewWorthyActionCount)
        defaults.set(currentVersion, forKey: .lastReviewRequestAppVersion)
    }
    
    var actionCount = defaults.integer(forKey: .reviewWorthyActionCount)
    actionCount += 1
    defaults.set(actionCount, forKey: .reviewWorthyActionCount)

    guard actionCount <= minimumReviewWorthyActionCount else {
        let alrt = UIAlertController.init(title: "", message: "", preferredStyle: .alert)
        alrt.addAction(UIAlertAction.init(title: "Ok", style: UIAlertAction.Style.default, handler: { (action:UIAlertAction) in
        }))
        APPData.appDelegate.window?.rootViewController!.present(alrt, animated: true, completion: nil)
      return
        
    }

    

    SKStoreReviewController.requestReview()

    
  }
}

extension Date {

    func dateFormatWithSuffix() -> String {
        return "dd'\(self.daySuffix())' MMM, yyyy"
    }

    func daySuffix() -> String {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self)
        let dayOfMonth = components.day
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
}

extension UserDefaults {
  enum Key: String {
    case reviewWorthyActionCount
    case lastReviewRequestAppVersion
  }

  func integer(forKey key: Key) -> Int {
    return integer(forKey: key.rawValue)
  }

  func string(forKey key: Key) -> String? {
    return string(forKey: key.rawValue)
  }

  func set(_ integer: Int, forKey key: Key) {
    set(integer, forKey: key.rawValue)
  }

  func set(_ object: Any?, forKey key: Key) {
    set(object, forKey: key.rawValue)
  }
}

extension UIApplication {
    class func getTopMostViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return getTopMostViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return getTopMostViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return getTopMostViewController(base: presented)
        }
        return base
    }
}
