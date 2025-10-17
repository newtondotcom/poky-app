//
//  pokyApp.swift
//  poky
//
//  Created by Robin Augereau on 16/10/2025.
//

import SwiftUI

@main
struct pokyApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
                case .active:
                    // Called when the scene has moved from an inactive state to an active state.
                    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
                    print("scene is now active!")
                case .inactive:
                    // Called when the scene will move from an active state to an inactive state.
                    // This may occur due to temporary interruptions (ex. an incoming phone call).
                    print("scene is now inactive!")
                case .background:
                    // Called as the scene transitions from the foreground to the background.
                    // Use this method to save data, release shared resources, and store enough scene-specific state information
                    // to restore the scene back to its current state.
                    print("scene is now in the background!")
                @unknown default:
                    print("Apple must have added something new!")
            }
        }
    }
}
