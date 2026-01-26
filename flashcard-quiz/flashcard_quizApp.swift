//
//  flashcard_quizApp.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import SwiftUI
import SwiftData

@main
struct flashcard_quizApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Flashcard.self)
    }
}
