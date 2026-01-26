//
//  Flashcard.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import Foundation
import SwiftData

@Model
class Flashcard {
    var word: String
    var definition: String
    var createdAt: Date
    
    init(word: String, definition: String) {
        self.word = word
        self.definition = definition
        self.createdAt = Date()
    }
}
