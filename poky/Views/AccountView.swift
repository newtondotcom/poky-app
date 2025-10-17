//
//  AccountView.swift
//  poky
//
//  Created by Robin Augereau on 16/10/2025.
//

import SwiftUI
import SafariServices

struct AccountView: View {
    @ObservedObject var mockData: MockData
    @State private var showingSettings = false
    @State private var showingAbout = false
    @State private var showingHapticsTest = false
    @State private var showingHelpSupport = false
    @State private var showingLogoutConfirmation = false

    var currentUserStats: LeaderboardEntry? {
        mockData.leaderboard.first { $0.user.id == mockData.currentUser.id }
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Header with liquid glass effect
                    VStack(spacing: 20) {
                        // Profile Picture and Basic Info
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 100, height: 100)
                                    .overlay(
                                        Circle()
                                            .stroke(.white.opacity(0.2), lineWidth: 2)
                                    )

                                Image(systemName: mockData.currentUser.profileImage)
                                    .font(.system(size: 40))
                                    .foregroundStyle(.primary)

                                // Online indicator
                                Circle()
                                    .fill(.secondary)
                                    .frame(width: 20, height: 20)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 3)
                                    )
                                    .offset(x: 35, y: 35)
                            }

                            VStack(spacing: 8) {
                                Text(mockData.currentUser.displayName)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(.primary)

                                Text("@\(mockData.currentUser.username)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)

                                Text("Always online and ready to poke!")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                        }

                        // Stats Cards
                        if let stats = currentUserStats {
                            HStack(spacing: 16) {
                                StatCard(
                                    title: "Sent",
                                    value: stats.totalPokes,
                                    icon: "hand.point.up.fill",
                                    color: .primary
                                )

                                StatCard(
                                    title: "Received",
                                    value: stats.receivedPokes,
                                    icon: "hand.point.down.fill",
                                    color: .primary
                                )

                                StatCard(
                                    title: "Rank",
                                    value: stats.rank,
                                    icon: "trophy.fill",
                                    color: .secondary
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .background(
                        LinearGradient(
                            colors: [.clear, Color.black.opacity(0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                    // Menu Options
                    VStack(spacing: 12) {

                        MenuRow(
                            icon: "gear",
                            title: "Settings",
                            subtitle: "App preferences and notifications",
                            color: .secondary
                        ) {
                            showingSettings = true
                        }

                        MenuRow(
                            icon: "bell",
                            title: "Notifications",
                            subtitle: "Manage your poke alerts",
                            color: .primary
                        ) {
                            // Handle notifications
                        }

                        MenuRow(
                            icon: "iphone.radiowaves.left.and.right",
                            title: "Haptics Test",
                            subtitle: "Test different haptic feedback types",
                            color: .secondary
                        ) {
                            showingHapticsTest = true
                        }

                        MenuRow(
                            icon: "questionmark.circle",
                            title: "Help & Support",
                            subtitle: "Get help and contact support",
                            color: .secondary
                        ) {
                            showingHelpSupport = true
                        }

                        MenuRow(
                            icon: "info.circle",
                            title: "About",
                            subtitle: "App version and information",
                            color: .secondary
                        ) {
                            showingAbout = true
                        }
                    }
                    .padding(.horizontal, 20)

                    // Sign Out Button
                    Button(action: {
                        showingLogoutConfirmation = true
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .font(.title3)
                            Text("Sign Out")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(.ultraThinMaterial)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.8),
                        Color.black.opacity(0.04)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
            .alert("Sign Out", isPresented: $showingLogoutConfirmation) {
                Button("Sign Out", role: .destructive) {
                    // Handle actual sign out logic here
                    print("User signed out")
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to sign out? You'll need to sign in again to access your poke data.")
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsSheet()
        }
        .sheet(isPresented: $showingAbout) {
            AboutSheet()
        }
        .sheet(isPresented: $showingHapticsTest) {
            HapticsTestSheet()
        }
        .fullScreenCover(isPresented: $showingHelpSupport) {
            SafariView(url: URL(string: "https://google.com")!)
        }
    }
}

// MARK: - Stat Card
struct StatCard: View {
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

// MARK: - Activity Card
struct ActivityCard: View {
    let poke: Poke
    let isCurrentUserSender: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Circle()
                    )
            }

            Text(isCurrentUserSender ? "Poked" : "Received")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)

            Text(isCurrentUserSender ? poke.toUser.displayName : poke.fromUser.displayName)
                .font(.caption2)
                .lineLimit(1)
                .foregroundStyle(.primary)

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

// MARK: - Menu Row
struct MenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 40, height: 40)

                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(color)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
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
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Settings Sheet
struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var vibrationEnabled = true

    var body: some View {
        NavigationView {
            List {
                Section("Notifications") {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    Toggle("Sound Effects", isOn: $soundEnabled)
                    Toggle("Vibration", isOn: $vibrationEnabled)
                }

                Section("Privacy") {
                    NavigationLink("Blocked Users") {
                        Text("Blocked Users")
                    }
                    NavigationLink("Privacy Settings") {
                        Text("Privacy Settings")
                    }
                }

                Section("App") {
                    NavigationLink("Appearance") {
                        Text("Appearance")
                    }
                    NavigationLink("Language") {
                        Text("Language")
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - About Sheet
struct AboutSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 16) {
                    Image(systemName: "hand.point.up.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.primary)

                    Text("Poky")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("Version 1.0.0")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 40)

                VStack(alignment: .leading, spacing: 16) {
                    Text("About Poky")
                        .font(.headline)
                        .fontWeight(.semibold)

                    Text("Poky is a fun social app that lets you poke your friends and see who's the most active poker in your network. Send different types of pokes and climb the leaderboard!")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 20)

                Spacer()
            }
            .background(Color(.systemBackground))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Haptics Test Sheet
struct HapticsTestSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 16) {
                    Text("Haptics Test")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Test different types of haptic feedback")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)

                // Haptic Test Buttons
                VStack(spacing: 16) {
                    HapticTestButton(
                        title: "Light Impact",
                        subtitle: "Gentle tap feedback",
                        icon: "hand.tap",
                        hapticType: .light
                    )

                    HapticTestButton(
                        title: "Medium Impact",
                        subtitle: "Standard tap feedback",
                        icon: "hand.point.up",
                        hapticType: .medium
                    )

                    HapticTestButton(
                        title: "Heavy Impact",
                        subtitle: "Strong tap feedback",
                        icon: "hand.raised",
                        hapticType: .heavy
                    )

                    HapticTestButton(
                        title: "Success",
                        subtitle: "Success notification",
                        icon: "checkmark.circle",
                        hapticType: .success
                    )

                    HapticTestButton(
                        title: "Warning",
                        subtitle: "Warning notification",
                        icon: "exclamationmark.triangle",
                        hapticType: .warning
                    )

                    HapticTestButton(
                        title: "Error",
                        subtitle: "Error notification",
                        icon: "xmark.circle",
                        hapticType: .error
                    )

                    HapticTestButton(
                        title: "Selection",
                        subtitle: "Selection feedback",
                        icon: "cursorarrow.click",
                        hapticType: .selection
                    )
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
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Haptic Test Button
struct HapticTestButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let hapticType: HapticType

    @State private var isPressed = false

    enum HapticType {
        case light
        case medium
        case heavy
        case success
        case warning
        case error
        case selection
    }

    var body: some View {
        Button(action: {
            triggerHaptic()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.secondary.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "play.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
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
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
    }

    private func triggerHaptic() {
        switch hapticType {
        case .light:
            let impactFeedback = UIImpactFeedbackGenerator(style: .light)
            impactFeedback.impactOccurred()
        case .medium:
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        case .heavy:
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        case .success:
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.success)
        case .warning:
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.warning)
        case .error:
            let notificationFeedback = UINotificationFeedbackGenerator()
            notificationFeedback.notificationOccurred(.error)
        case .selection:
            let selectionFeedback = UISelectionFeedbackGenerator()
            selectionFeedback.selectionChanged()
        @unknown default:
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
}

// MARK: - Safari View
struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        let safariVC = SFSafariViewController(url: url)
        safariVC.modalPresentationStyle = .fullScreen
        return safariVC
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        // Nothing needed here
    }
}

#Preview {
    AccountView(mockData: MockData())
}
