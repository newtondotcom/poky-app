    //
//  PokeRelationSearchView.swift
//  poky
//
//  Created by Robin Augereau on 17/10/2025.
//

import Combine
import SwiftUI

// New: Search for poke relations in the system search tab
struct PokeRelationSearchView: View {
    @ObservedObject var mockData: MockData
    @State private var searchText: String = ""
    @State private var selectedPokeRelation: PokeRelation?
    @State private var showingUserSheet = false

    var filteredPokeRelations: [PokeRelation] {
        if searchText.isEmpty {
            return mockData.pokeRelations
        } else {
            return mockData.pokeRelations.filter { relation in
                relation.otherUser.displayName.localizedCaseInsensitiveContains(searchText) ||
                relation.otherUser.username.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 12) {
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
                }
                .background(
                    LinearGradient(
                        colors: [.clear, .purple.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                HStack {
                    Text("Search Poke Relations")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer()
                    Text("\(filteredPokeRelations.count)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(.secondary.opacity(0.2))
                        )
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)

                if filteredPokeRelations.isEmpty && !searchText.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)
                        Text("No poke relations found")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 24)
                    .frame(maxWidth: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredPokeRelations) { pokeRelation in
                                PokeRelationRow(
                                    pokeRelation: pokeRelation,
                                    onPoke: { completion in
                                        // Simulate poke with delay
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                            mockData.sendPoke(from: mockData.currentUser, to: pokeRelation.otherUser)
                                            completion()
                                        }
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
            .searchable(text: $searchText, prompt: "Search friends or usernames")
            .sheet(isPresented: $showingUserSheet) {
                if let pokeRelation = selectedPokeRelation {
                    UserActionSheet(
                        pokeRelation: pokeRelation,
                        onAnonymize: {
                            mockData.anonymizePokeRelation(pokeRelation)
                            showingUserSheet = false
                        },
                        onDelete: {
                            // Deleting handled here if needed
                            mockData.deletePokeRelation(pokeRelation)
                            showingUserSheet = false
                        },
                        onDismiss: {
                            showingUserSheet = false
                        }
                    )
                }
            }
        }
    }
}
