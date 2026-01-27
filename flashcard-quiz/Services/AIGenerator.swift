//
//  AIGenerator.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 27/1/26.
//

import Foundation
import FoundationModels

@Generable
struct GeneratedCard {
    @Guide(description: "A clear, beginner-friendly definition in exactly 2 sentences.")
    let definition: String
    
    @Guide(description: "The grammatical word type. Must be one of: noun, verb, adjective, adverb, preposition, conjunction, pronoun, interjection, determiner, phrase")
    let wordType: String
}

extension GeneratedCard {
    static let example = GeneratedCard(
        definition: "Feeling good and joyful inside. People often smile when they are happy.",
        wordType: "adjective"
    )
}

@Observable
@MainActor
final class AIGenerator {
    private(set) var result: GeneratedCard?
    private(set) var isGenerating = false
    var error: Error?
    
    private var session: LanguageModelSession
    
    init() {
        let instructions = Instructions {
            "You are a vocabulary assistant."
            "Provide clear, beginner-friendly definitions in 2 sentences."
            "Classify words into their grammatical category."
        }
        self.session = LanguageModelSession(tools: [], instructions: instructions)
    }
    
    func generate(for word: String) async {
        result = nil
        error = nil
        isGenerating = true
        defer { isGenerating = false }
        
        do {
            let prompt = Prompt {
                "Define and classify the word '\(word)'."
                "Example:"
                GeneratedCard.example
            }
            
            let response = try await session.respond(
                to: prompt,
                generating: GeneratedCard.self,
                includeSchemaInPrompt: false
            )
            
            result = response.content
        } catch {
            self.error = error
        }
    }
    
    func prewarm() {
        session.prewarm()
    }
}
