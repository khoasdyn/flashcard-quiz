//
//  CardRowView.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 27/1/26.
//

import SwiftUI

struct CardRowView: View {
    let card: Flashcard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(card.word)
                    .font(.headline)
                
                Spacer()
                
                WordTypeBadge(wordType: card.wordType)
            }
            
            Text(card.definition)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    List {
        CardRowView(card: Flashcard(word: "Ephemeral", definition: "Lasting for a very short time. The morning dew is ephemeral, disappearing as the sun rises.", wordType: .adjective))
        CardRowView(card: Flashcard(word: "Run", definition: "To move swiftly on foot. People run to exercise or to get somewhere quickly.", wordType: .verb))
        CardRowView(card: Flashcard(word: "Legacy", definition: "Something handed down from the past.", wordType: nil))
    }
}
