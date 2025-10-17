import UIKit
import UserNotifications
import Foundation


extension Notification.Name {
    /// Notification posted when a poke is received from a remote push
    static let didReceivePoke = Notification.Name("didReceivePoke")
}


final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    // Called when the app finishes launching
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Register for remote notifications.
        application.registerForRemoteNotifications()
        return true
    }
    
    // MARK: - Remote Notification Registration
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenComponents = deviceToken.map { String(format: "%02.2hhx", $0) }
        let token = tokenComponents.joined()
        print("📲 Device Token:", token)
        forwardTokenToServer(token)
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications:", error.localizedDescription)
    }
    
    // MARK: - Handle Silent Push / Background Fetch
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // This should never be triggerd
        
        print("📩 NEVER __ Received remote notification:", userInfo)
        
        guard let type = userInfo["type"] as? String else {
            completionHandler(.noData)
            return
        }
        
        if type == "poke",
           let fromUser = userInfo["fromUser"] as? [String: Any],
           let displayName = fromUser["displayName"] as? String {
            
            // Post event for SwiftUI to react
            NotificationCenter.default.post(name: .didReceivePoke, object: nil, userInfo: ["name": displayName])
            print("⚡️ Poke received from \(displayName)")
            
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
    
    // MARK: - Helpers
    
    private func forwardTokenToServer(_ token: String) {
        guard let url = URL(string: "https://example.com/register?deviceToken=\(token)") else { return }
        URLSession.shared.dataTask(with: url).resume()
    }
}
