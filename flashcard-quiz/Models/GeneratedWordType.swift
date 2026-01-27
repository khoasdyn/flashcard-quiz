//
//  GeneratedWordType.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 27/1/26.
//

import Foundation
import FoundationModels

@Generable
struct GeneratedWordType {
    @Guide(description: "The grammatical category of the word. Must be exactly one of: noun, verb, adjective, adverb, preposition, conjunction, pronoun, interjection, determiner, or phrase")
    let wordType: String
    
    @Guide(description: "A 1-3 letter abbreviation of the word type. Use standard abbreviations: n (noun), v (verb), adj (adjective), adv (adverb), prep (preposition), conj (conjunction), pron (pronoun), interj (interjection), det (determiner), phr (phrase)")
    let abbreviation: String
}

extension GeneratedWordType {
    static let nounExample = GeneratedWordType(
        wordType: "noun",
        abbreviation: "n"
    )
    
    static let verbExample = GeneratedWordType(
        wordType: "verb",
        abbreviation: "v"
    )
    
    static let adjectiveExample = GeneratedWordType(
        wordType: "adjective",
        abbreviation: "adj"
    )
}
