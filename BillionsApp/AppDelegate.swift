//
//  AppDelegate.swift
//  BillionsApp
//
//  Created by Tristate on 20.10.21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseMessaging
import FirebaseCore
import UserNotifications
import FirebaseAnalytics
import FirebaseFirestoreSwift
import FirebaseFirestore
import WidgetKit
import ActivityKit

extension Dictionary {
    var jsonStringRepresentation: String? {
        guard let theJSONData = try? JSONSerialization.data(withJSONObject: self,
                                                            options: [.prettyPrinted]) else {
            return nil
        }

        return String(data: theJSONData, encoding: .ascii)
    }
}

func setUserNotificationToken(token: String) {
    guard let uid = Auth.auth().currentUser?.uid else { return }
    Firestore.firestore().collection(usersCollection).document(uid).updateData(["notificationTokens": token])
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var loginUserData : [UserData] = []
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseConfiguration.shared.setLoggerLevel(.min)
        FirebaseApp.configure()
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
//        do {
//            try Auth.auth().signOut()
//        } catch { }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.unknown)
        Auth.auth().setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        setOnlineStatus()
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        setOnlineStatus()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        guard Auth.auth().currentUser != nil, let currentUID = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection(usersCollection).document(currentUID).updateData(["OnlineStatus" : FieldValue.serverTimestamp()])
    }
    
    var backgroundTaskIdentifier: UIBackgroundTaskIdentifier!
    func applicationDidEnterBackground(_ application: UIApplication) {
        guard Auth.auth().currentUser != nil, let currentUID = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection(usersCollection).document(currentUID).updateData(["OnlineStatus" : FieldValue.serverTimestamp()])
        
       backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: {
           UIApplication.shared.endBackgroundTask(self.backgroundTaskIdentifier)
       })
       _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.doSomething), userInfo: nil, repeats: true)
    }

    @objc func doSomething() {
       print("I'm running")
        WidgetCenter.shared.reloadAllTimelines()
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        setUserNotificationToken(token: fcmToken ?? "")
    }
}
