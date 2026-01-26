//
//  ContentView.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import SwiftUI

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
