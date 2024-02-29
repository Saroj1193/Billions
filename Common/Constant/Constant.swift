//
//  Constant.swift
//  
//
//  Created by Tristate on 11/18/19.
//  Copyright © 2019 Tristate. All rights reserved.
//

import Foundation
import UIKit


//MARK:- Font Name
class CONSTANT_FONT_NAME {
    public static let AVENIR_HEAVY = "Avenir-Heavy.ttf"
    public static let AVENIRLTSTD_BLACK = "AvenirLTStd-Black.ttf"
    public static let AVENIRLTSTD_BOOK = "AvenirLTStd-Book.ttf"
    public static let AVENIRLTSTD_LIGHT = "AvenirLTStd-Light.ttf"
    public static let AVENIRLTSTD_MEDIUM = "AvenirLTStd-Medium.ttf"
}


struct APPData  {
    public static let APP_NAME = "ChatOut"
    
    public static let appDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    public static let APP_VERSION = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    public static let OS_VERSION = UIDevice.current.systemVersion
    public static let DEVICE_UUID = UIDevice.current.identifierForVendor!.uuidString
    public static let buildVersion = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    public static let DEVICE_MODEL = UIDevice.current.model
    public static let appVersion =  buildVersion
    public static let DEVICE_NAME  = UIDevice.current.systemName
    public static let Itunes_App_URL  = ""
    public static let App_URL  = ""
    public static let REFRESH_TOKEN_FIRST_TIME = "FKDFJSDLFJSDLFJSDLFJSDjmLVF6G9Aarypa9y5AhG3JpwQXanNRWBgaaTfU3dQY"
    public static var Auth_TOKEN_FIRST_TIME = "@#Slsjpoq$S1o08#MnbAiB%UVUV&Y*5EU@exS1o!08L9TSlsjpo#FKDFJSDLFJSDLFJSDLFJSDQY"
    
    public static let userDefault : UserDefaults = UserDefaults.standard
    
    
    public struct ResposeCode {
        public static let RESPONSE_CODE_SUSPENDED_USER = "403"
        public static let RESPONSE_CODE_APP_VERSION = "102"
        public static let RESPONSE_CODE_ACCESS_RESTRICTED = "105"
        public static let RESPONSE_CODE_TOKEN_NOT_AVAILABLE = "103"
        public static let RESPONSE_CODE_TOKEN_NOT_PASSED = "104"
        public static let RESPONSE_CODE_TOKEN_NOT_PRESENT = "403"
    }
    
    
    public struct UserDefaultKeys {
        public static let AUTH_TOKEN = "auth_token"
        public static let REFRESH_TOKEN = "refresh_token"
        public static let USER_ID = "user_id"
        public static let DEVICE_TOKEN = "deviceToken"
        public static let CURRENT_LANGUAGE = "current_language"
    }
    
    public struct NotificationName {
        public static let ALERT_CONNECTION_ERROR = "socketConnectionError"
        public static let SERVER_CONNECT_NOTIFY = "socketConnected"
    }
    
    //MARK:- Location
    static var locationSyncing: LocationSynching?

}

//Extension For Notification
extension Notification.Name {
    public static let USER_TYPE_CHANGED = Notification.Name("UserTypeChanged")
    public static let StopPlayer = NSNotification.Name.init("StopPlayer")
}


//MARK:- Check device Type
struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}


//MARK:- DeviceType Check
struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPHONE_X         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 812.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

extension UIDevice {
        var modelName: String {
            var systemInfo = utsname()
            uname(&systemInfo)
            let machineMirror = Mirror(reflecting: systemInfo.machine)
            let identifier = machineMirror.children.reduce("") { identifier, element in
                guard let value = element.value as? Int8, value != 0 else { return identifier }
                return identifier + String(UnicodeScalar(UInt8(value)))
            }
            return identifier
        }
    }
