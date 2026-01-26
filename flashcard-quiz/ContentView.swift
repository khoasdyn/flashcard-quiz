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
    
    private var currentCard: Flashcard? {
        cards.indices.contains(currentIndex) ? cards[currentIndex] : nil
    }
    
    private var isFirstCard: Bool { currentIndex == 0 }
    private var isLastCard: Bool { currentIndex >= cards.count - 1 }
    
    var body: some View {
        VStack(spacing: 24) {
            cardCounter
            cardDisplay
            navigationButtons
            actionButtons
        }
        .padding()
        .sheet(isPresented: $showingAddSheet) {
            AddCardView { word, definition in
                addCard(word: word, definition: definition)
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
        HStack(spacing: 20) {
            Button {
                showingAddSheet = true
            } label: {
                Label("Add", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            
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
    
    private func addCard(word: String, definition: String) {
        let newCard = Flashcard(word: word, definition: definition)
        modelContext.insert(newCard)
        currentIndex = cards.count
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
