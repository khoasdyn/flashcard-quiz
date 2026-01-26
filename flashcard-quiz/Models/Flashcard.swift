//
//  Flashcard.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import Foundation

struct Flashcard: Identifiable {
    let id = UUID()
    let word: String
    let definition: String
}
