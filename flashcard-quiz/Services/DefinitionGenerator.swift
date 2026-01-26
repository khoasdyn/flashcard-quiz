//
//  DefinitionGenerator.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import Foundation
import FoundationModels

@Observable
@MainActor
final class DefinitionGenerator {
    private(set) var generatedDefinition: String?
    private(set) var isGenerating = false
    var error: Error?
    
    private var session: LanguageModelSession
    
    init() {
        let instructions = Instructions {
            "You are a helpful vocabulary assistant."
            "Provide detailed, beginner-friendly definitions."
            "Use 2-3 sentences that explain meaning, context, and usage."
            "Avoid using complex words in your definitions."
        }
        
        self.session = LanguageModelSession(tools: [], instructions: instructions)
    }
    
    func generateDefinition(for word: String) async {
        generatedDefinition = nil
        error = nil
        isGenerating = true
        
        defer { isGenerating = false }
        
        do {
            let prompt = Prompt {
                "Define the word '\(word)' in simple, beginner-friendly language."
                "Here is an example of the format:"
                GeneratedDefinition.example
            }
            
            let stream = session.streamResponse(
                to: prompt,
                generating: GeneratedDefinition.self,
                includeSchemaInPrompt: false
            )
            
            for try await partialResponse in stream {
                if let definition = partialResponse.content.definition {
                    generatedDefinition = definition
                }
            }
        } catch {
            self.error = error
        }
    }
    
    func prewarm() {
        session.prewarm()
    }
}
