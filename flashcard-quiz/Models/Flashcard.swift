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
    var wordType: String?
    var wordTypeAbbreviation: String?
    
    init(word: String, definition: String, wordType: String? = nil, wordTypeAbbreviation: String? = nil) {
        self.word = word
        self.definition = definition
        self.createdAt = Date()
        self.wordType = wordType
        self.wordTypeAbbreviation = wordTypeAbbreviation
    }
}
