//
//  PushNotification.swift

import UIKit
import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications

class PushNotification: NSObject,UNUserNotificationCenterDelegate {
    static let sharedInstance = PushNotification()
    
    func setupForPushNotiFication(application: UIApplication,_ isNotiGranted : @escaping (Bool) -> Swift.Void){
//        FirebaseApp.configure()
        self.tokenRefreshNotification()
        setUpFirebasePushNotification(application: application, isGranted: { (isAuthenticated) in
           isNotiGranted(isAuthenticated)
        })
    }
    
    func registerPushNotificationWithToken(deviceToken: Data){
        Messaging.messaging()
            .setAPNSToken(deviceToken, type: MessagingAPNSTokenType.unknown)
    }
    
    
    func setUpFirebasePushNotification(application: UIApplication,isGranted : @escaping (_ isAuthenticated : Bool)-> Swift.Void) -> Void {
        //Push Notification Register
        if #available(iOS 10.0, *) {
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (granted, error) in
                    guard error == nil else {
                        isGranted(false)
                        return
                    }
                isGranted(granted)
            }
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.tokenRefreshNotification),
                                               name: .MessagingRegistrationTokenRefreshed,
                                               object: nil)
    }
    
    @objc func tokenRefreshNotification() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let refreshedToken = token {

                UserDefaults.standard.setValue(refreshedToken, forKey: APPData.UserDefaultKeys.DEVICE_TOKEN)
                UserDefaults.standard.synchronize()
                
               
            }
        }

        connectToFcm()
    }
    
    
    
    
    func connectToFcm() {
        Messaging.messaging().token { token, error in
            if let error = error {
                print(error.localizedDescription)
            } else if let refreshedToken = token {

                UserDefaults.standard.setValue(refreshedToken, forKey: APPData.UserDefaultKeys.DEVICE_TOKEN)
                UserDefaults.standard.synchronize()
                
               
            }
        }
    }
    
    

}
