//
//  IndexView.swift
//  poky
//
//  Created by Robin Augereau on 16/10/2025.
//

import SwiftUI

struct IndexView: View {
    @ObservedObject var mockData: MockData
    @State private var showingUserSheet = false
    @State private var selectedPokeRelation: PokeRelation?
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with liquid glass effect
                    VStack(spacing: 16) {
                        HStack {
                            Text("Poke Someone!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("Simply poke your friends")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                    }
                    .background(
                        LinearGradient(
                            colors: [.clear, .green.opacity(0.1)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    // Recent Pokes Section
                    if !mockData.pokes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Recent Pokes")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(mockData.pokes.count)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(.green.opacity(0.2))
                                    )
                            }
                            .padding(.horizontal, 20)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    ForEach(mockData.pokes.prefix(5)) { poke in
                                        RecentPokeCard(poke: poke)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    
                    // Poke Relations Section
                    if !mockData.pokeRelations.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Poke Relations")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(mockData.pokeRelations.count)")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(
                                        Capsule()
                                            .fill(.green.opacity(0.2))
                                    )
                            }
                            .padding(.horizontal, 20)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(mockData.pokeRelations) { pokeRelation in
                                    PokeRelationRow(
                                        pokeRelation: pokeRelation,
                                        onPoke: {
                                            mockData.sendPoke(from: mockData.currentUser, to: pokeRelation.otherUser)
                                        },
                                        onAvatarTap: {
                                            selectedPokeRelation = pokeRelation
                                            showingUserSheet = true
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.bottom, 100)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.8),
                        Color.green.opacity(0.05)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingUserSheet) {
            if let pokeRelation = selectedPokeRelation {
                UserActionSheet(
                    pokeRelation: pokeRelation,
                    onAnonymize: {
                        mockData.anonymizePokeRelation(pokeRelation)
                        showingUserSheet = false
                    },
                    onDelete: {
                        showingDeleteConfirmation = true
                    },
                    onDismiss: {
                        showingUserSheet = false
                    }
                )
            }
        }
        .confirmationDialog(
            "Delete Poke Relation",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let pokeRelation = selectedPokeRelation {
                    mockData.deletePokeRelation(pokeRelation)
                    showingUserSheet = false
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will permanently delete your poke history with \(selectedPokeRelation?.otherUser.displayName ?? "this user"). This action cannot be undone.")
        }
    }
}

// MARK: - Poke Relation Row
struct PokeRelationRow: View {
    let pokeRelation: PokeRelation
    let onPoke: () -> Void
    let onAvatarTap: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image - tappable
            Button(action: onAvatarTap) {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(.white.opacity(0.3), lineWidth: 2)
                        )
                    
                    Image(systemName: pokeRelation.otherUser.profileImage)
                        .font(.system(size: 20))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // User info
            VStack(alignment: .leading, spacing: 4) {
                Text(pokeRelation.otherUser.displayName)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Image(systemName: "calendar")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    
                    Text(timeAgoString(from: pokeRelation.lastPokeDate))
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Action buttons and count
            HStack(spacing: 12) {
                // Poke button (only show if it's your turn)
                if pokeRelation.isYourTurn {
                    Button(action: {
                        onPoke()
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isPressed = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                isPressed = false
                            }
                        }
                    }) {
                        Text("Poke")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.green)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(.green.opacity(0.4), lineWidth: 1)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(.green.opacity(0.15))
                                    )
                            )
                    }
                    .scaleEffect(isPressed ? 0.9 : 1.0)
                }
                
                // Poke count
                HStack(spacing: 4) {
                    Image(systemName: "bolt.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.green)
                    
                    Text("\(pokeRelation.count)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.primary)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86400))d ago"
        }
    }
}

// MARK: - Recent Poke Card
struct RecentPokeCard: View {
    let poke: Poke
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(.green.opacity(0.3), lineWidth: 2)
                    )
                
                Text("👆")
                    .font(.title2)
            }
            
            Text(poke.fromUser.displayName)
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(1)
            
            Text(timeAgoString(from: poke.timestamp))
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
        .frame(width: 100)
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            return "\(Int(interval / 60))m ago"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))h ago"
        } else {
            return "\(Int(interval / 86400))d ago"
        }
    }
}

// MARK: - Friend Poke Card
struct FriendPokeCard: View {
    let user: User
    let onPoke: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                
                Image(systemName: user.profileImage)
                    .font(.title2)
                    .foregroundStyle(.primary)
            }
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            
            VStack(spacing: 4) {
                Text(user.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(1)
                
                HStack(spacing: 4) {
                    Circle()
                        .fill(user.isOnline ? .green : .gray)
                        .frame(width: 6, height: 6)
                    Text(user.isOnline ? "Online" : "Offline")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            Button(action: {
                onPoke()
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
            }) {
                Text("Poke")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .fill(.green)
                            .overlay(
                                Capsule()
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    )
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - User Action Sheet
struct UserActionSheet: View {
    let pokeRelation: PokeRelation
    let onAnonymize: () -> Void
    let onDelete: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // User info header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 2)
                            )
                        
                        Image(systemName: pokeRelation.otherUser.profileImage)
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    
                    VStack(spacing: 4) {
                        Text(pokeRelation.otherUser.displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("\(pokeRelation.count) pokes")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.top, 20)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onAnonymize) {
                        HStack {
                            Image(systemName: "eye.slash")
                                .font(.title3)
                            Text("Anonymize in Leaderboard")
                                .font(.headline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .foregroundStyle(.green)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    Button(action: onDelete) {
                        HStack {
                            Image(systemName: "trash")
                                .font(.title3)
                            Text("Delete Poke Relation")
                                .font(.headline)
                                .fontWeight(.medium)
                            Spacer()
                        }
                        .foregroundStyle(.red)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 20)
                
                Spacer()
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemBackground).opacity(0.8)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    IndexView(mockData: MockData())
}
