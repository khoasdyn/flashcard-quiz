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
    @State private var definitionGenerator = DefinitionGenerator()
    @State private var wordTypeGenerator = WordTypeGenerator()
    
    var onSave: (String, String, String?, String?) -> Void
    
    private var trimmedWord: String { word.trimmingCharacters(in: .whitespaces) }
    private var trimmedDefinition: String { definition.trimmingCharacters(in: .whitespaces) }
    private var canSave: Bool { !trimmedWord.isEmpty && !trimmedDefinition.isEmpty }
    private var isGenerating: Bool { definitionGenerator.isGenerating || wordTypeGenerator.isGenerating }
    private var canGenerate: Bool { !trimmedWord.isEmpty && !isGenerating }
    
    var body: some View {
        NavigationStack {
            Form {
                wordSection
                wordTypeBadgeSection
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
                        let wordType = wordTypeGenerator.generatedWordType
                        onSave(trimmedWord, trimmedDefinition, wordType?.wordType, wordType?.abbreviation)
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                definitionGenerator.prewarm()
                wordTypeGenerator.prewarm()
            }
        }
    }
    
    // MARK: - Sections
    
    private var wordSection: some View {
        Section("Word") {
            TextField("Enter a word", text: $word)
        }
    }
    
    @ViewBuilder
    private var wordTypeBadgeSection: some View {
        if wordTypeGenerator.isGenerating || wordTypeGenerator.generatedWordType != nil {
            Section {
                HStack {
                    Spacer()
                    if wordTypeGenerator.isGenerating {
                        ProgressView()
                            .controlSize(.small)
                        Text("Classifying...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else if let wordType = wordTypeGenerator.generatedWordType {
                        Text(wordType.abbreviation.uppercased())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(badgeColor(for: wordType.wordType), in: Capsule())
                        
                        Text(wordType.wordType.capitalized)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                }
            }
        }
    }
    
    private func badgeColor(for wordType: String) -> Color {
        switch wordType.lowercased() {
        case "noun": return .blue
        case "verb": return .green
        case "adjective": return .orange
        case "adverb": return .purple
        case "preposition": return .pink
        case "conjunction": return .cyan
        case "pronoun": return .indigo
        case "interjection": return .red
        case "determiner": return .mint
        case "phrase": return .teal
        default: return .gray
        }
    }
    
    private var definitionSection: some View {
        Section {
            TextField("Definition", text: $definition, axis: .vertical)
                .lineLimit(3...6)
            
            generateButton
            
            if let error = definitionGenerator.error ?? wordTypeGenerator.error {
                Text(error.localizedDescription)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Definition")
        } footer: {
            Text("Type a definition manually or use AI to generate one.")
        }
    }
    
    private var generateButton: some View {
        Button {
            Task {
                async let definitionTask: () = generateDefinition()
                async let wordTypeTask: () = generateWordType()
                _ = await (definitionTask, wordTypeTask)
            }
        } label: {
            HStack {
                Image(systemName: "sparkles")
                Text(isGenerating ? "Generating..." : "AI Generate")
            }
            .frame(maxWidth: .infinity)
        }
        .disabled(!canGenerate)
    }
    
    // MARK: - Actions
    
    private func generateDefinition() async {
        await definitionGenerator.generateDefinition(for: trimmedWord)
        if let generated = definitionGenerator.generatedDefinition {
            definition = generated
        }
    }
    
    private func generateWordType() async {
        await wordTypeGenerator.generateWordType(for: trimmedWord)
    }
}

#Preview {
    AddCardView { word, definition, wordType, abbreviation in
        print("Saved: \(word) - \(definition) - \(wordType ?? "nil") - \(abbreviation ?? "nil")")
    }
}
