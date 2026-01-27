//
//  ListTabView.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 27/1/26.
//

import SwiftUI
import SwiftData

struct ListTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Flashcard.createdAt, order: .reverse) private var cards: [Flashcard]
    
    @State private var showingAddSheet = false
    @State private var cardToEdit: Flashcard?
    @State private var selectedCard: Flashcard?
    
    var body: some View {
        NavigationStack {
            Group {
                if cards.isEmpty {
                    ContentUnavailableView(
                        "No Flashcards",
                        systemImage: "rectangle.stack",
                        description: Text("Tap + to add your first card")
                    )
                } else {
                    List {
                        ForEach(cards) { card in
                            CardRowView(card: card)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    selectedCard = card
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        modelContext.delete(card)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .swipeActions(edge: .leading) {
                                    Button {
                                        cardToEdit = card
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.orange)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Flashcards")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                CardFormView { word, definition, wordType in
                    let card = Flashcard(word: word, definition: definition, wordType: wordType)
                    modelContext.insert(card)
                }
            }
            .sheet(item: $cardToEdit) { card in
                CardFormView(card: card) { word, definition, wordType in
                    card.word = word
                    card.definition = definition
                    card.wordType = wordType
                }
            }
            .sheet(item: $selectedCard) { card in
                CardDetailView(card: card)
            }
        }
    }
}

#Preview {
    ListTabView()
        .modelContainer(for: Flashcard.self, inMemory: true)
}
