//
//  FlashcardView.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import SwiftUI

struct FlashcardView: View, Animatable {
    
    static let cardWidth: CGFloat = 340
    static let cardHeight: CGFloat = 400
    
    let card: Flashcard
    var rotation: Double
    
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    private var showingFront: Bool { rotation < 90 }
    
    init(card: Flashcard, isFlipped: Bool) {
        self.card = card
        self.rotation = isFlipped ? 180 : 0
    }
    
    var body: some View {
        ZStack {
            frontSide
            backSide
        }
        .frame(width: Self.cardWidth, height: Self.cardHeight)
        .shadow(radius: 5)
        .rotation3DEffect(.degrees(rotation), axis: (0, 1, 0))
    }
    
    private var frontSide: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.indigo.gradient)
            .overlay {
                Text(card.word)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(24)
            }
            .opacity(showingFront ? 1 : 0)
    }
    
    private var backSide: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.blue.gradient)
            .overlay {
                Text(card.definition)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(24)
            }
            .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
            .opacity(showingFront ? 0 : 1)
    }
}

#Preview {
    FlashcardView(
        card: Flashcard(word: "Ephemeral", definition: "Lasting for a very short time"),
        isFlipped: false
    )
}
