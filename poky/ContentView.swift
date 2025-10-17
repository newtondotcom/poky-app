//
//  ContentView.swift
//  poky
//
//  Created by Robin Augereau on 16/10/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var mockData = MockData()
    @State private var selectedTab : Int = 0

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                IndexView(mockData: mockData)
            }
            Tab("Leaderboard", systemImage: "trophy") {
                LeaderboardView(mockData: mockData)
            }
            Tab("Account", systemImage: "person.circle") {
                AccountView(mockData: mockData)
            }
            Tab(role: .search) {
                PokeRelationSearchView(mockData: mockData)
            }
        }
        .accentColor(.primary)
        .tabBarMinimizeBehavior(.onScrollDown)
        .tabViewBottomAccessory {
          Button("Add exercise") {
            // Action to add an exercise
          }
        }
    }
}

#Preview {
    ContentView()
}
