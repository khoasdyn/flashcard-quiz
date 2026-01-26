//
//  GeneratedDefinition.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import Foundation
import FoundationModels

@Generable
struct GeneratedDefinition {
    @Guide(description: "A detailed, beginner-friendly definition. Include what the word means, how it's commonly used, and helpful context. Use 2-3 sentences to fully explain the concept.")
    let definition: String
}

extension GeneratedDefinition {
    static let example = GeneratedDefinition(
        definition: "Feeling good and joyful inside, like when something nice happens to you. When you're happy, you might smile, laugh, or feel excited. It's a positive emotion that makes you feel warm and content."
    )
}
