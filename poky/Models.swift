//
//  Models.swift
//  poky
//
//  Created by Robin Augereau on 16/10/2025.
//

import Foundation
import SwiftUI
import Combine

// MARK: - User Model
struct User: Identifiable, Codable {
    let id = UUID()
    let username: String
    let displayName: String
    let profileImage: String
    var pokeCount: Int = 0
    var lastSeen: Date = Date()
    var isOnline: Bool = true
    
    init(username: String, displayName: String, profileImage: String = "person.circle.fill") {
        self.username = username
        self.displayName = displayName
        self.profileImage = profileImage
    }
}

// MARK: - Poke Model
struct Poke: Identifiable, Codable {
    let id = UUID()
    let fromUser: User
    let toUser: User
    let timestamp: Date
    var isRead: Bool = false
}

// MARK: - Poke Relation
struct PokeRelation: Identifiable {
    let id = UUID()
    let otherUser: User
    let count: Int
    let lastPokeDate: Date
    let lastPokeBy: UUID // ID of the user who sent the last poke
    
    var isYourTurn: Bool {
        return lastPokeBy != otherUser.id
    }
}

// MARK: - Leaderboard Entry
struct LeaderboardEntry: Identifiable {
    let id = UUID()
    let user: User
    let totalPokes: Int
    let receivedPokes: Int
    let rank: Int
}

// MARK: - Mock Data
class MockData: ObservableObject {
    @Published var users: [User] = []
    @Published var currentUser: User
    @Published var pokes: [Poke] = []
    @Published var pokeRelations: [PokeRelation] = []
    @Published var leaderboard: [LeaderboardEntry] = []
    
    init() {
        // Create current user
        self.currentUser = User(username: "robin", displayName: "Robin Augereau", profileImage: "person.circle.fill")
        
        // Create mock users
        self.users = [
            User(username: "alice", displayName: "Alice Johnson", profileImage: "person.circle.fill"),
            User(username: "bob", displayName: "Bob Smith", profileImage: "person.circle.fill"),
            User(username: "charlie", displayName: "Charlie Brown", profileImage: "person.circle.fill"),
            User(username: "diana", displayName: "Diana Prince", profileImage: "person.circle.fill"),
            User(username: "eve", displayName: "Eve Wilson", profileImage: "person.circle.fill"),
            User(username: "frank", displayName: "Frank Miller", profileImage: "person.circle.fill"),
            User(username: "grace", displayName: "Grace Hopper", profileImage: "person.circle.fill"),
            User(username: "henry", displayName: "Henry Ford", profileImage: "person.circle.fill")
        ]
        
        // Create mock pokes
        self.pokes = [
            Poke(fromUser: users[0], toUser: currentUser, timestamp: Date().addingTimeInterval(-3600)),
            Poke(fromUser: users[1], toUser: currentUser, timestamp: Date().addingTimeInterval(-7200)),
            Poke(fromUser: currentUser, toUser: users[2], timestamp: Date().addingTimeInterval(-1800)),
            Poke(fromUser: users[3], toUser: currentUser, timestamp: Date().addingTimeInterval(-5400)),
            Poke(fromUser: currentUser, toUser: users[4], timestamp: Date().addingTimeInterval(-900))
        ]
        
        // Create mock poke relations
        self.pokeRelations = [
            PokeRelation(otherUser: users[0], count: 12, lastPokeDate: Date().addingTimeInterval(-1800), lastPokeBy: currentUser.id),
            PokeRelation(otherUser: users[1], count: 8, lastPokeDate: Date().addingTimeInterval(-3600), lastPokeBy: users[1].id),
            PokeRelation(otherUser: users[2], count: 15, lastPokeDate: Date().addingTimeInterval(-900), lastPokeBy: currentUser.id),
            PokeRelation(otherUser: users[3], count: 6, lastPokeDate: Date().addingTimeInterval(-7200), lastPokeBy: users[3].id),
            PokeRelation(otherUser: users[4], count: 23, lastPokeDate: Date().addingTimeInterval(-450), lastPokeBy: currentUser.id),
            PokeRelation(otherUser: users[5], count: 4, lastPokeDate: Date().addingTimeInterval(-10800), lastPokeBy: users[5].id)
        ]
        
        // Create mock leaderboard
        self.leaderboard = [
            LeaderboardEntry(user: users[0], totalPokes: 156, receivedPokes: 89, rank: 1),
            LeaderboardEntry(user: currentUser, totalPokes: 142, receivedPokes: 98, rank: 2),
            LeaderboardEntry(user: users[1], totalPokes: 134, receivedPokes: 76, rank: 3),
            LeaderboardEntry(user: users[3], totalPokes: 128, receivedPokes: 82, rank: 4),
            LeaderboardEntry(user: users[2], totalPokes: 115, receivedPokes: 67, rank: 5),
            LeaderboardEntry(user: users[4], totalPokes: 98, receivedPokes: 54, rank: 6),
            LeaderboardEntry(user: users[5], totalPokes: 87, receivedPokes: 45, rank: 7),
            LeaderboardEntry(user: users[6], totalPokes: 76, receivedPokes: 38, rank: 8)
        ]
    }
    
    func sendPoke(from: User, to: User) {
        let newPoke = Poke(fromUser: from, toUser: to, timestamp: Date())
        pokes.append(newPoke)
        
        // Update poke counts
        if let fromIndex = users.firstIndex(where: { $0.id == from.id }) {
            users[fromIndex].pokeCount += 1
        }
        if let toIndex = users.firstIndex(where: { $0.id == to.id }) {
            users[toIndex].pokeCount += 1
        }
    }
    
    func anonymizePokeRelation(_ pokeRelation: PokeRelation) {
        // In a real app, this would anonymize the relation in the leaderboard
        // For now, we'll just remove it from the poke relations list
        pokeRelations.removeAll { $0.id == pokeRelation.id }
    }
    
    func deletePokeRelation(_ pokeRelation: PokeRelation) {
        // Remove the poke relation
        pokeRelations.removeAll { $0.id == pokeRelation.id }
        
        // Also remove related pokes
        pokes.removeAll { poke in
            (poke.fromUser.id == currentUser.id && poke.toUser.id == pokeRelation.otherUser.id) ||
            (poke.fromUser.id == pokeRelation.otherUser.id && poke.toUser.id == currentUser.id)
        }
    }
}
