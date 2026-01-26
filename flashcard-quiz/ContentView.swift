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
    
    // Demo data pool
    private let demoData: [(word: String, definition: String)] = [
        ("Ephemeral", "Lasting for a very short time"),
        ("Ubiquitous", "Present, appearing, or found everywhere"),
        ("Pragmatic", "Dealing with things sensibly and realistically"),
        ("Eloquent", "Fluent or persuasive in speaking or writing"),
        ("Resilient", "Able to recover quickly from difficulties"),
        ("Ambiguous", "Open to more than one interpretation"),
        ("Meticulous", "Showing great attention to detail"),
        ("Candid", "Truthful and straightforward"),
        ("Tenacious", "Holding firmly to something"),
        ("Inevitable", "Certain to happen; unavoidable")
    ]
    
    private var currentCard: Flashcard? {
        guard cards.indices.contains(currentIndex) else { return nil }
        return cards[currentIndex]
    }
    
    private var nextDemoIndex: Int {
        cards.count
    }
    
    private var canAddMore: Bool {
        nextDemoIndex < demoData.count
    }
    
    var body: some View {
        VStack(spacing: 24) {
            cardCounter
            
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
            
            navigationButtons
            actionButtons
        }
        .padding()
    }
    
    // MARK: - Subviews
    
    private var cardCounter: some View {
        Group {
            if !cards.isEmpty {
                Text("\(currentIndex + 1) / \(cards.count)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    private var emptyState: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.gray.opacity(0.2))
            .frame(width: 300, height: 200)
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
            .disabled(currentIndex == 0)
            
            Button {
                goToNext()
            } label: {
                Image(systemName: "chevron.right.circle.fill")
                    .font(.largeTitle)
            }
            .disabled(currentIndex >= cards.count - 1)
        }
    }
    
    private var actionButtons: some View {
        HStack(spacing: 20) {
            Button {
                addCard()
            } label: {
                Label("Add", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!canAddMore)
            
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
    
    private func addCard() {
        guard canAddMore else { return }
        
        let demo = demoData[nextDemoIndex]
        let newCard = Flashcard(word: demo.word, definition: demo.definition)
        modelContext.insert(newCard)
        
        currentIndex = cards.count // Will be count after insert
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
