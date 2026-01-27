//
//  ContentView.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Flashcard.createdAt) private var cards: [Flashcard]
    
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
    
    private var currentCard: Flashcard? {
        cards.indices.contains(currentIndex) ? cards[currentIndex] : nil
    }
    
    private var isFirstCard: Bool { currentIndex == 0 }
    private var isLastCard: Bool { currentIndex >= cards.count - 1 }
    
    var body: some View {
        VStack(spacing: 24) {
            cardCounter
            cardDisplay
            wordTypeBadge
            navigationButtons
            actionButtons
        }
        .padding()
        .sheet(isPresented: $showingAddSheet) {
            AddCardView { word, definition, wordType, abbreviation in
                addCard(word: word, definition: definition, wordType: wordType, abbreviation: abbreviation)
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let card = currentCard {
                EditCardView(card: card) { word, definition, wordType, abbreviation in
                    updateCard(card, word: word, definition: definition, wordType: wordType, abbreviation: abbreviation)
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private var cardCounter: some View {
        if !cards.isEmpty {
            Text("\(currentIndex + 1) / \(cards.count)")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var cardDisplay: some View {
        if let card = currentCard {
            FlashcardView(card: card, isFlipped: isFlipped)
                .id(card.id)
                .onTapGesture {
                    withAnimation {
                        isFlipped.toggle()
                    }
                }
        } else {
            emptyState
        }
    }
    
    @ViewBuilder
    private var wordTypeBadge: some View {
        if let card = currentCard {
            HStack {
                if let abbreviation = card.wordTypeAbbreviation, let wordType = card.wordType {
                    Text(abbreviation.uppercased())
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(badgeColor(for: wordType), in: Capsule())
                } else {
                    Text("N/A")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.gray.opacity(0.2), in: Capsule())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func badgeColor(for wordType: String) -> Color {
        switch wordType.lowercased() {
        case "noun": return .blue
        case "verb": return .green
        case "adjective": return .orange
        case "adverb": return .purple
        case "preposition": return .pink
        case "conjunction": return .cyan
        case "pronoun": return .indigo
        case "interjection": return .red
        case "determiner": return .mint
        case "phrase": return .teal
        default: return .gray
        }
    }
    
    private var emptyState: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.gray.opacity(0.2))
            .frame(width: FlashcardView.cardWidth, height: FlashcardView.cardHeight)
            .overlay {
                Text("No cards yet")
                    .foregroundStyle(.secondary)
            }
    }
    
    private var navigationButtons: some View {
        HStack(spacing: 40) {
            Button {
                goToPrevious()
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.largeTitle)
            }
            .disabled(isFirstCard)
            
            Button {
                goToNext()
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.largeTitle)
            }
            .disabled(isLastCard)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button {
                showingAddSheet = true
            } label: {
                Label("Add", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            
            Button {
                showingEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .buttonStyle(.bordered)
            .disabled(cards.isEmpty)
            
            Button(role: .destructive) {
                deleteCurrentCard()
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            .disabled(cards.isEmpty)
        }
    }
    
    // MARK: - Actions
    
    private func goToPrevious() {
        isFlipped = false
        currentIndex -= 1
    }
    
    private func goToNext() {
        isFlipped = false
        currentIndex += 1
    }
    
    private func addCard(word: String, definition: String, wordType: String?, abbreviation: String?) {
        let newCard = Flashcard(
            word: word,
            definition: definition,
            wordType: wordType,
            wordTypeAbbreviation: abbreviation
        )
        modelContext.insert(newCard)
        currentIndex = cards.count
        isFlipped = false
    }
    
    private func updateCard(_ card: Flashcard, word: String, definition: String, wordType: String?, abbreviation: String?) {
        card.word = word
        card.definition = definition
        card.wordType = wordType
        card.wordTypeAbbreviation = abbreviation
        isFlipped = false
    }
    
    private func deleteCurrentCard() {
        guard let card = currentCard else { return }
        modelContext.delete(card)
        
        if currentIndex >= cards.count - 1 && currentIndex > 0 {
            currentIndex = cards.count - 2
        }
        isFlipped = false
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Flashcard.self, inMemory: true)
}
