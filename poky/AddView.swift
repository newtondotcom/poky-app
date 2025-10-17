//
//  AddView.swift
//  poky
//
//  Created by Robin Augereau on 16/10/2025.
//

import SwiftUI

struct AddView: View {
    @ObservedObject var mockData: MockData
    @State private var AddText = ""
    @State private var selectedUser: User?
    @State private var showingUserProfile = false

    var filteredUsers: [User] {
        if AddText.isEmpty {
            return mockData.users
        } else {
            return mockData.users.filter { user in
                user.username.localizedCaseInsensitiveContains(AddText) ||
                user.displayName.localizedCaseInsensitiveContains(AddText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Add Header with liquid glass effect
                VStack(spacing: 16) {
                    HStack {
                        Text("Add Users")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Spacer()

                        // Add stats
                        Text("\(mockData.users.count) users")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                                    .overlay(
                                        Capsule()
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)

                    // Add bar with liquid glass and adaptive material
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)

                        TextField("Add by name or username...", text: $AddText)
                            .textFieldStyle(PlainTextFieldStyle())

                        if !AddText.isEmpty {
                            Button(action: {
                                AddText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
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
                                    .stroke(.secondary.opacity(0.15), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                }
                .background(
                    LinearGradient(
                        colors: [.clear, .purple.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

                // Add Results
                if filteredUsers.isEmpty && !AddText.isEmpty {
                    // No results found
                    VStack(spacing: 20) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundStyle(.secondary)

                        VStack(spacing: 8) {
                            Text("No users found")
                                .font(.headline)
                                .fontWeight(.semibold)

                            Text("Try Adding with a different name or username")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Users list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(filteredUsers) { user in
                                UserAddCard(
                                    user: user,
                                    onTap: {
                                        selectedUser = user
                                        showingUserProfile = true
                                    },
                                    onPoke: {
                                        mockData.sendPoke(from: mockData.currentUser, to: user)
                                    }
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
                                Color.purple.opacity(0.05)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingUserProfile) {
            if let user = selectedUser {
                UserProfileSheet(
                    user: user,
                    currentUser: mockData.currentUser,
                    onPoke: {
                        mockData.sendPoke(from: mockData.currentUser, to: user)
                        showingUserProfile = false
                    }
                )
            }
        }
    }
}

// MARK: - User Add Card
struct UserAddCard: View {
    let user: User
    let onTap: () -> Void
    let onPoke: () -> Void
    @State private var isPressed = false

    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                            .stroke(.white.opacity(0.18), lineWidth: 1)
                    )

                Image(systemName: user.profileImage)
                    .font(.title3)
                    .foregroundStyle(.primary)

                // Online indicator
                if user.isOnline {
                    Circle()
                        .fill(.green)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 2)
                        )
                        .offset(x: 18, y: 18)
                }
            }

            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text(user.displayName)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)

                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Image(systemName: "hand.point.up.fill")
                            .font(.caption)
                        Text("\(user.pokeCount)")
                            .font(.caption)
                            .fontWeight(.medium)
                    }
                    .foregroundStyle(.green)

                    Text("•")
                        .foregroundStyle(.secondary)

                    Text(lastSeenText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Action Buttons
            HStack(spacing: 8) {
                Button(action: {
                    onTap()
                }) {
                    Image(systemName: "person.circle")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.21), lineWidth: 1)
                                )
                        )
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
                        .padding(.vertical, 8)
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
        .onTapGesture {
            onTap()
        }
    }

    private var lastSeenText: String {
        let interval = Date().timeIntervalSince(user.lastSeen)

        if user.isOnline {
            return "Online"
        } else if interval < 60 {
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


// MARK: - User Profile Sheet
struct UserProfileSheet: View {
    let user: User
    let currentUser: User
    let onPoke: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Circle()
                                        .stroke(.white.opacity(0.19), lineWidth: 2)
                                )

                            Image(systemName: user.profileImage)
                                .font(.system(size: 40))
                                .foregroundStyle(.primary)

                            // Online indicator
                            if user.isOnline {
                                Circle()
                                    .fill(.green)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 3)
                                    )
                                    .offset(x: 35, y: 35)
                            }
                        }

                        VStack(spacing: 8) {
                            Text(user.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(.primary)

                            Text("@\(user.username)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 16) {
                                VStack {
                                    Text("\(user.pokeCount)")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(.green)
                                    Text("Pokes")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                VStack {
                                    Text(user.isOnline ? "Online" : "Offline")
                                        .font(.headline)
                                        .fontWeight(.bold)
                                        .foregroundStyle(user.isOnline ? .green : .secondary)
                                    Text("Status")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                    .padding(.top, 20)

                    // Poke Button (no type selection)
                    Button(action: {
                        onPoke()
                    }) {
                        HStack(spacing: 12) {
                            Text("👆")
                                .font(.title2)
                            Text("Send Poke")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 20)
                }
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
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddView(mockData: MockData())
}
