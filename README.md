# Poky - Social Pokes App

A modern iOS app similar to Facebook Pokes, built with SwiftUI and featuring iOS 26 liquid glass design elements.

## Features

### 🏠 Home Tab (Index)
- Send different types of pokes (Normal, Super, Mega)
- View recent poke activity
- Quick access to friends for poking
- Beautiful liquid glass UI with smooth animations

### 🔍 Search Tab
- Search users by name or username
- View user profiles with detailed information
- Send pokes directly from search results
- Online/offline status indicators

### 🏆 Leaderboard Tab
- View top pokers in your network
- Three different ranking categories:
  - **Sent**: Most pokes sent
  - **Received**: Most pokes received  
  - **Total**: Combined poke activity
- Your personal ranking and statistics
- Beautiful trophy icons for top performers

### 👤 Account Tab
- Personal profile with statistics
- Recent activity feed
- App settings and preferences
- Edit profile functionality
- Help and support options

## Design Features

### iOS 26 Liquid Glass Design
- **Ultra-thin material backgrounds** with subtle transparency
- **Gradient overlays** for depth and visual hierarchy
- **Smooth animations** and spring physics
- **Rounded corners** and modern card layouts
- **Color-coded poke types** with visual feedback
- **Glassmorphism effects** throughout the interface

### Poke Types
- **Normal Poke** 👆 - Gentle attention grabber (green)
- **Super Poke** 💥 - More energetic poke (Orange)
- **Mega Poke** 🚀 - Ultimate poke experience (Purple)

## Technical Implementation

### Architecture
- **SwiftUI** for modern declarative UI
- **MVVM pattern** with ObservableObject for data management
- **Modular design** with separate view files for each tab
- **Mock data system** for development and testing

### Key Components
- `Models.swift` - Data models for User, Poke, and Leaderboard
- `IndexView.swift` - Home screen with poke functionality
- `SearchView.swift` - User search and discovery
- `LeaderboardView.swift` - Rankings and statistics
- `AccountView.swift` - User profile and settings
- `ContentView.swift` - Main TabView navigation

### Data Models
```swift
struct User {
    let username: String
    let displayName: String
    let profileImage: String
    var pokeCount: Int
    var isOnline: Bool
}

struct Poke {
    let fromUser: User
    let toUser: User
    let timestamp: Date
    let pokeType: PokeType
}

enum PokeType {
    case normal, superPoke, megaPoke
}
```

## Getting Started

1. Open the project in Xcode
2. Build and run on iOS Simulator or device
3. Explore the different tabs and poke functionality
4. Customize the mock data in `Models.swift` for testing

## Requirements

- iOS 17.0+
- Xcode 15.0+
- SwiftUI

## Future Enhancements

- Real-time notifications
- Push notifications for new pokes
- User authentication and backend integration
- Photo sharing and custom poke messages
- Social features like poke streaks
- Dark mode optimization

## Screenshots

The app features a modern, glassmorphic design with:
- Smooth tab navigation
- Interactive poke buttons with haptic feedback
- Beautiful gradient backgrounds
- Card-based layouts with transparency effects
- Color-coded poke types and user status indicators

---

Built with ❤️ using SwiftUI and iOS 26 design principles.
