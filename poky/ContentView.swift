//
//  ContentView.swift
//  poky
//
//  Created by Robin Augereau on 16/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var mockData = MockData()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            // Index Tab
            IndexView(mockData: mockData)
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)

            // Add Tab
            AddView(mockData: mockData)
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "magnifyingglass.circle.fill" : "magnifyingglass.circle")
                    Text("Add")
                }
                .tag(1)

            // Leaderboard Tab
            LeaderboardView(mockData: mockData)
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "trophy.fill" : "trophy")
                    Text("Leaderboard")
                }
                .tag(2)

            // Account Tab
            AccountView(mockData: mockData)
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "person.circle.fill" : "person.circle")
                    Text("Account")
                }
                .tag(3)
        }
        .accentColor(.primary)
        .onAppear {
            // Customize tab bar appearance for iOS 26 liquid glass effect
            let appearance = UITabBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)

            // Add blur effect for liquid glass
            let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100)

            // Apply the appearance
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance

            // Add subtle shadow for depth
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundImage = UIImage()
        }
    }
}

#Preview {
    ContentView()
}
