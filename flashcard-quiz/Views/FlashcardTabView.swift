//
//  FlashcardTabView.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 27/1/26.
//

import SwiftUI
import SwiftData

struct FlashcardTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Flashcard.createdAt) private var cards: [Flashcard]
    
    @State private var currentIndex = 0
    @State private var isFlipped = false
    @State private var showingAddSheet = false
    @State private var showingEditSheet = false
    
    private var currentCard: Flashcard? {
        cards.indices.contains(currentIndex) ? cards[currentIndex] : nil
    }
    
    var body: some View {
        VStack(spacing: 24) {
            if !cards.isEmpty {
                Text("\(currentIndex + 1) / \(cards.count)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            
            if let card = currentCard {
                FlashcardView(card: card, isFlipped: isFlipped)
                    .id(card.id)
                    .onTapGesture {
                        withAnimation { isFlipped.toggle() }
                    }
                
                WordTypeBadge(wordType: card.wordType)
            } else {
                emptyState
            }
            
            navigationButtons
            actionButtons
        }
        .padding()
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $showingAddSheet) {
            CardFormView { word, definition, wordType in
                let card = Flashcard(word: word, definition: definition, wordType: wordType)
                modelContext.insert(card)
                currentIndex = cards.count
                isFlipped = false
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            if let card = currentCard {
                CardFormView(card: card) { word, definition, wordType in
                    card.word = word
                    card.definition = definition
                    card.wordType = wordType
                    isFlipped = false
                }
            }
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
                isFlipped = false
                currentIndex -= 1
            } label: {
                Image(systemName: "chevron.left.circle.fill")
                    .font(.largeTitle)
            }
            .disabled(currentIndex == 0)
            
            Button {
                isFlipped = false
                currentIndex += 1
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.largeTitle)
            }
            .disabled(currentIndex >= cards.count - 1)
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
                if let card = currentCard {
                    modelContext.delete(card)
                    if currentIndex >= cards.count - 1 && currentIndex > 0 {
                        currentIndex = cards.count - 2
                    }
                    isFlipped = false
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
            .buttonStyle(.bordered)
            .disabled(cards.isEmpty)
        }
    }
}

#Preview {
    FlashcardTabView()
        .modelContainer(for: Flashcard.self, inMemory: true)
}
