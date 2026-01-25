//
//  ContentView.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import SwiftUI

// MARK: - Data Model

struct Flashcard {
    let word: String
    let definition: String
}

// MARK: - Flashcard View

struct FlashcardView: View, Animatable {
    let card: Flashcard
    
    var rotation: Double
    
    // This tells SwiftUI to animate the rotation value smoothly
    // Without this, SwiftUI would not know how to interpolate between rotation values
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    // Compute which side to show based on current rotation during animation
    // When rotation is less than 90 degrees, we see the front (word)
    // When rotation passes 90 degrees, we see the back (definition)
    var showingFront: Bool {
        rotation < 90
    }
    
    init(card: Flashcard, isFlipped: Bool) {
        self.card = card
        // Convert the boolean state to rotation degrees
        // false (showing front) = 0 degrees, true (showing back) = 180 degrees
        self.rotation = isFlipped ? 180 : 0
    }
    
    var body: some View {
        ZStack {
            let base = RoundedRectangle(cornerRadius: 16)
            
            // Front side - the word
            base
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
            
            // Back side - the definition
            base
                .fill(.blue.gradient)
                .overlay {
                    Text(card.definition)
                        .font(.title3)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(24)
                }
                // Counter-rotate the back side so text reads correctly when card is flipped
                .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
                .opacity(showingFront ? 0 : 1)
        }
        .frame(width: 300, height: 200)
        .shadow(radius: 5)
        .rotation3DEffect(.degrees(rotation), axis: (0, 1, 0))
    }
}

// MARK: - Main View

struct ContentView: View {
    
    let card = Flashcard(
        word: "Ephemeral",
        definition: "Lasting for a very short time"
    )
    
    @State private var isFlipped = false
    
    var body: some View {
        VStack {
            FlashcardView(card: card, isFlipped: isFlipped)
                .onTapGesture {
                    withAnimation {
                        isFlipped.toggle()
                    }
                }
            
            Text("Tap the card to flip")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.top, 20)
        }
    }
}

#Preview {
    ContentView()
}
