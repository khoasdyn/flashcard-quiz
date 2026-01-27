//
//  WordTypeGenerator.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 27/1/26.
//

import Foundation
import FoundationModels

@Observable
@MainActor
final class WordTypeGenerator {
    private(set) var generatedWordType: GeneratedWordType?
    private(set) var isGenerating = false
    var error: Error?
    
    private var session: LanguageModelSession
    
    init() {
        let instructions = Instructions {
            "You are a grammar expert."
            "Classify words into their grammatical categories."
            "For compound words or phrases, identify the primary grammatical function."
        }
        self.session = LanguageModelSession(tools: [], instructions: instructions)
    }
    
    func generateWordType(for word: String) async {
        generatedWordType = nil
        error = nil
        isGenerating = true
        defer { isGenerating = false }
        
        do {
            let prompt = Prompt {
                "What is the grammatical word type of '\(word)'?"
                "Examples:"
                GeneratedWordType.nounExample
                GeneratedWordType.verbExample
                GeneratedWordType.adjectiveExample
            }
            
            let response = try await session.respond(
                to: prompt,
                generating: GeneratedWordType.self,
                includeSchemaInPrompt: false
            )
            
            generatedWordType = response.content
        } catch {
            self.error = error
        }
    }
    
    func prewarm() {
        session.prewarm()
    }
}
