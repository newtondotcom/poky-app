//
//  LeaderboardView.swift
//  poky
//
//  Created by Robin Augereau on 16/10/2025.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var mockData: MockData

    var sortedLeaderboard: [LeaderboardEntry] {
        mockData.leaderboard.sorted { 
            ($0.totalPokes + $0.receivedPokes) > ($1.totalPokes + $1.receivedPokes) 
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
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                }
                .background(
                    LinearGradient(
                        colors: [.clear, Color.primary.opacity(0.04)],
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
                            Color.primary.opacity(0.04)
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

// MARK: - Leaderboard Card
struct LeaderboardCard: View {
    let entry: LeaderboardEntry
    let rank: Int
    let isCurrentUser: Bool

    private var rankColor: Color {
        switch rank {
        case 1: return .primary
        case 2: return .secondary
        case 3: return .gray
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

    private var totalCount: Int {
        entry.totalPokes + entry.receivedPokes
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
                                    .fill(.secondary.opacity(0.2))
                            )
                            .foregroundStyle(.secondary)
                    }
                }

                Text("@\(entry.user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Total Pokes display
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(totalCount)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(isCurrentUser ? .primary : .primary)

                Text("Total")
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
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
            )
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

// MARK: - Stats Summary Card (optional, only shows total)
struct StatsSummaryCard: View {
    let currentUserEntry: LeaderboardEntry

    private var currentRank: Int { currentUserEntry.rank }
    private var totalCount: Int {
        currentUserEntry.totalPokes + currentUserEntry.receivedPokes
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
                            .fill(.secondary.opacity(0.2))
                    )
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 20) {
                StatItem(
                    title: "Total",
                    value: totalCount,
                    icon: "trophy.fill",
                    color: .primary
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
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    LeaderboardView(mockData: MockData())
}
