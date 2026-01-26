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
    @Guide(description: "A clear, beginner-friendly definition in exactly 2 sentences. First sentence explains the meaning, second sentence shows how it's commonly used.")
    let definition: String
}

extension GeneratedDefinition {
    static let example = GeneratedDefinition(
        definition: "Feeling good and joyful inside, like when something nice happens to you. People often smile, laugh, or feel excited when they are happy."
    )
}
