//
//  FlashcardViewModel.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import Foundation

@Observable
class FlashcardViewModel {
    var cards: [Flashcard] = []
    
    // Demo data pool to add cards from
    private var demoCards: [Flashcard] = [
        Flashcard(word: "Ephemeral", definition: "Lasting for a very short time"),
        Flashcard(word: "Ubiquitous", definition: "Present, appearing, or found everywhere"),
        Flashcard(word: "Pragmatic", definition: "Dealing with things sensibly and realistically"),
        Flashcard(word: "Eloquent", definition: "Fluent or persuasive in speaking or writing"),
        Flashcard(word: "Resilient", definition: "Able to recover quickly from difficulties"),
        Flashcard(word: "Ambiguous", definition: "Open to more than one interpretation"),
        Flashcard(word: "Meticulous", definition: "Showing great attention to detail"),
        Flashcard(word: "Candid", definition: "Truthful and straightforward"),
        Flashcard(word: "Tenacious", definition: "Holding firmly to something"),
        Flashcard(word: "Inevitable", definition: "Certain to happen; unavoidable")
    ]
    
    private var nextDemoIndex = 0
    
    init() {
        // Start with one card
        addCard()
    }
    
    func addCard() {
        guard nextDemoIndex < demoCards.count else { return }
        cards.append(demoCards[nextDemoIndex])
        nextDemoIndex += 1
    }
    
    func deleteCard(_ card: Flashcard) {
        cards.removeAll { $0.id == card.id }
    }
    
    func deleteCard(at index: Int) {
        guard cards.indices.contains(index) else { return }
        cards.remove(at: index)
    }
    
    var canAddMore: Bool {
        nextDemoIndex < demoCards.count
    }
}
