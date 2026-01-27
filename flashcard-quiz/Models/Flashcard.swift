//
//  Flashcard.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
class Flashcard {
    var word: String
    var definition: String
    var createdAt: Date
    var wordTypeRaw: String?
    
    var wordType: WordType? {
        get { wordTypeRaw.flatMap { WordType(rawValue: $0) } }
        set { wordTypeRaw = newValue?.rawValue }
    }
    
    init(word: String, definition: String, wordType: WordType? = nil) {
        self.word = word
        self.definition = definition
        self.createdAt = Date()
        self.wordTypeRaw = wordType?.rawValue
    }
}

enum WordType: String, CaseIterable {
    case noun, verb, adjective, adverb, preposition, conjunction, pronoun, interjection, determiner, phrase
    
    var abbreviation: String {
        switch self {
        case .noun: "n"
        case .verb: "v"
        case .adjective: "adj"
        case .adverb: "adv"
        case .preposition: "prep"
        case .conjunction: "conj"
        case .pronoun: "pron"
        case .interjection: "interj"
        case .determiner: "det"
        case .phrase: "phr"
        }
    }
    
    var color: Color {
        switch self {
        case .noun: .blue
        case .verb: .green
        case .adjective: .orange
        case .adverb: .purple
        case .preposition: .pink
        case .conjunction: .cyan
        case .pronoun: .indigo
        case .interjection: .red
        case .determiner: .mint
        case .phrase: .teal
        }
    }
}
