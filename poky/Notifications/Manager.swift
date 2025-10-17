//
//  Notifications.swift
//  poky
//
//  Created by Robin Augereau on 17/10/2025.
//

import SwiftUI
import UserNotifications
import Combine

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    static let shared = NotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    /// Ask the user for notification permissions and register for remote notifications
    func requestNotificationPermissions() {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [
            .alert,
            .sound,
            .badge,
            .provisional,
            .providesAppNotificationSettings
        ]
        
        center.requestAuthorization(options: options) { granted, error in
            if let error = error {
                print("❌ Notification authorization error: \(error.localizedDescription)")
                return
            }
            
            if granted {
                print("✅ Notification permission granted")
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            } else {
                print("⚠️ Notification permission not granted")
            }
        }
    }
    
    // MARK: UNUserNotificationCenterDelegate methods
    
    // Show notifications even when app is in foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
         // completionHandler([.banner, .sound, .badge])
        
        /*
        // Access the payload
        let userInfo = notification.request.content.userInfo
        
        // Example: read a custom "type" field
        if let type = userInfo["type"] as? String {
            if type == "poke",
               let fromUser = userInfo["fromUser"] as? [String: Any],
               let displayName = fromUser["displayName"] as? String {
                
                // Post a SwiftUI notification to update the UI
                NotificationCenter.default.post(name: .didReceivePoke, object: nil, userInfo: ["name": displayName])
                
                print("⚡️ Poke received from \(displayName)")
            }
        }
         */
        
        // Do not show any alert
        completionHandler([])
    }
    
    // Handle user tapping on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        print("📩 Notification tapped: \(response.notification.request.content.userInfo)")
        completionHandler()
    }
}
