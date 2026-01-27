//
//  ContentView.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Cards", systemImage: "rectangle.stack") {
                FlashcardTabView()
            }
            
            Tab("List", systemImage: "list.bullet") {
                ListTabView()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Flashcard.self, inMemory: true)
}
