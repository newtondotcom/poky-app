//
//  LeaderboardView.swift
//  poky
//
//  Created by Robin Augereau on 16/10/2025.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var mockData: MockData
    @State private var selectedTab: LeaderboardTab = .sent
    
    enum LeaderboardTab: String, CaseIterable {
        case sent = "Sent"
        case received = "Received"
        case total = "Total"
        
        var icon: String {
            switch self {
            case .sent: return "hand.point.up.fill"
            case .received: return "hand.point.down.fill"
            case .total: return "trophy.fill"
            }
        }
    }
    
    var sortedLeaderboard: [LeaderboardEntry] {
        switch selectedTab {
        case .sent:
            return mockData.leaderboard.sorted { $0.totalPokes > $1.totalPokes }
        case .received:
            return mockData.leaderboard.sorted { $0.receivedPokes > $1.receivedPokes }
        case .total:
            return mockData.leaderboard.sorted { ($0.totalPokes + $0.receivedPokes) > ($1.totalPokes + $1.receivedPokes) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header with liquid glass effect
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Leaderboard")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            
                            Text("Top pokers in your network")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        // Trophy icon with liquid glass
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .frame(width: 50, height: 50)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                            
                            Image(systemName: "trophy.fill")
                                .font(.title2)
                                .foregroundStyle(.yellow)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Tab Selector with liquid glass
                    HStack(spacing: 0) {
                        ForEach(LeaderboardTab.allCases, id: \.self) { tab in
                            TabButton(
                                tab: tab,
                                isSelected: selectedTab == tab
                            ) {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedTab = tab
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .background(
                    LinearGradient(
                        colors: [.clear, .orange.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                
                // Leaderboard Content
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(sortedLeaderboard.enumerated()), id: \.element.id) { index, entry in
                            LeaderboardCard(
                                entry: entry,
                                rank: index + 1,
                                selectedTab: selectedTab,
                                isCurrentUser: entry.user.id == mockData.currentUser.id
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                }
                .background(
                    LinearGradient(
                        colors: [
                            Color(.systemBackground),
                            Color(.systemBackground).opacity(0.8),
                            Color.orange.opacity(0.05)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .navigationBarHidden(true)
        }
    }
}

// MARK: - Tab Button
struct TabButton: View {
    let tab: LeaderboardView.LeaderboardTab
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: tab.icon)
                    .font(.caption)
                    .foregroundStyle(isSelected ? .white : .primary)
                
                Text(tab.rawValue)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? .orange.opacity(0.3) : .white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Leaderboard Card
struct LeaderboardCard: View {
    let entry: LeaderboardEntry
    let rank: Int
    let selectedTab: LeaderboardView.LeaderboardTab
    let isCurrentUser: Bool
    
    private var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return .gray
        case 3: return .brown
        default: return .secondary
        }
    }
    
    private var rankIcon: String {
        switch rank {
        case 1: return "crown.fill"
        case 2: return "medal.fill"
        case 3: return "medal.fill"
        default: return "\(rank)"
        }
    }
    
    private var displayValue: Int {
        switch selectedTab {
        case .sent: return entry.totalPokes
        case .received: return entry.receivedPokes
        case .total: return entry.totalPokes + entry.receivedPokes
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank indicator
            ZStack {
                if rank <= 3 {
                    Circle()
                        .fill(rankColor.opacity(0.2))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(rankColor.opacity(0.3), lineWidth: 2)
                        )
                    
                    Image(systemName: rankIcon)
                        .font(.title3)
                        .foregroundStyle(rankColor)
                } else {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.2), lineWidth: 1)
                        )
                    
                    Text("\(rank)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                }
            }
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(entry.user.displayName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)
                    
                    if isCurrentUser {
                        Text("(You)")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(.green.opacity(0.2))
                            )
                            .foregroundStyle(.green)
                    }
                }
                
                Text("@\(entry.user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.point.up.fill")
                            .font(.caption)
                        Text("\(entry.totalPokes)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.green)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "hand.point.down.fill")
                            .font(.caption)
                        Text("\(entry.receivedPokes)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.green)
                }
            }
            
            Spacer()
            
            // Score display
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(displayValue)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(isCurrentUser ? .green : .primary)
                
                Text(selectedTab.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCurrentUser ? .green.opacity(0.3) : .white.opacity(0.2), lineWidth: 1)
                    )
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isCurrentUser ? .green.opacity(0.2) : .white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Stats Summary Card
struct StatsSummaryCard: View {
    let currentUserEntry: LeaderboardEntry
    let selectedTab: LeaderboardView.LeaderboardTab
    
    private var currentRank: Int {
        // This would be calculated based on the current leaderboard
        return currentUserEntry.rank
    }
    
    private var displayValue: Int {
        switch selectedTab {
        case .sent: return currentUserEntry.totalPokes
        case .received: return currentUserEntry.receivedPokes
        case .total: return currentUserEntry.totalPokes + currentUserEntry.receivedPokes
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Your Stats")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text("Rank #\(currentRank)")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.green.opacity(0.2))
                    )
                    .foregroundStyle(.green)
            }
            
            HStack(spacing: 20) {
                StatItem(
                    title: "Sent",
                    value: currentUserEntry.totalPokes,
                    icon: "hand.point.up.fill",
                    color: .green
                )
                
                StatItem(
                    title: "Received",
                    value: currentUserEntry.receivedPokes,
                    icon: "hand.point.down.fill",
                    color: .green
                )
                
                StatItem(
                    title: "Total",
                    value: currentUserEntry.totalPokes + currentUserEntry.receivedPokes,
                    icon: "trophy.fill",
                    color: .orange
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct StatItem: View {
    let title: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            
            Text("\(value)")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LeaderboardView(mockData: MockData())
}
