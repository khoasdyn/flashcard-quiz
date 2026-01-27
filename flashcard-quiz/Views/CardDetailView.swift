//
//  CardDetailView.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 27/1/26.
//

import SwiftUI

struct CardDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let card: Flashcard
    @State private var isFlipped = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                FlashcardView(card: card, isFlipped: isFlipped)
                    .onTapGesture {
                        withAnimation { isFlipped.toggle() }
                    }
                
                WordTypeBadge(wordType: card.wordType)
                
                Text("Tap card to flip")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .navigationTitle(card.word)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

#Preview {
    CardDetailView(card: Flashcard(word: "Ephemeral", definition: "Lasting for a very short time. The morning dew is ephemeral, disappearing as the sun rises.", wordType: .adjective))
}
