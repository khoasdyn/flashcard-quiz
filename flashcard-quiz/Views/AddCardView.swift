//
//  AddCardView.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 25/1/26.
//

import SwiftUI

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var word = ""
    @State private var definition = ""
    @State private var generator = DefinitionGenerator()
    
    var onSave: (String, String) -> Void
    
    private var trimmedWord: String { word.trimmingCharacters(in: .whitespaces) }
    private var trimmedDefinition: String { definition.trimmingCharacters(in: .whitespaces) }
    private var canSave: Bool { !trimmedWord.isEmpty && !trimmedDefinition.isEmpty }
    private var canGenerate: Bool { !trimmedWord.isEmpty && !generator.isGenerating }
    
    var body: some View {
        NavigationStack {
            Form {
                wordSection
                definitionSection
            }
            .navigationTitle("New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(trimmedWord, trimmedDefinition)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                generator.prewarm()
            }
        }
    }
    
    // MARK: - Sections
    
    private var wordSection: some View {
        Section("Front") {
            TextField("Word", text: $word)
        }
    }
    
    private var definitionSection: some View {
        Section {
            TextField("Definition", text: $definition, axis: .vertical)
                .lineLimit(3...6)
            
            generateButton
            
            if let error = generator.error {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Back")
        } footer: {
            Text("Type a definition manually or use AI to generate one.")
        }
    }
    
    private var generateButton: some View {
        Button {
            Task {
                await generator.generateDefinition(for: trimmedWord)
                if let generated = generator.generatedDefinition {
                    definition = generated
                }
            }
        } label: {
            HStack {
                Image(systemName: "sparkles")
                Text(generator.isGenerating ? "Generating..." : "AI Generate")
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(!canGenerate)
    }
}

#Preview {
    AddCardView { word, definition in
        print("Saved: \(word) - \(definition)")
    }
}
