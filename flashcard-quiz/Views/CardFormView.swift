//
//  CardFormView.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 27/1/26.
//

import SwiftUI

struct CardFormView: View {
    @Environment(\.dismiss) private var dismiss
    
    let card: Flashcard?
    var onSave: (String, String, String?, String?) -> Void
    
    @State private var word: String
    @State private var definition: String
    @State private var wordType: String?
    @State private var wordTypeAbbreviation: String?
    @State private var definitionGenerator = DefinitionGenerator()
    @State private var wordTypeGenerator = WordTypeGenerator()
    
    private var isEditing: Bool { card != nil }
    
    init(card: Flashcard? = nil, onSave: @escaping (String, String, String?, String?) -> Void) {
        self.card = card
        self.onSave = onSave
        _word = State(initialValue: card?.word ?? "")
        _definition = State(initialValue: card?.definition ?? "")
        _wordType = State(initialValue: card?.wordType)
        _wordTypeAbbreviation = State(initialValue: card?.wordTypeAbbreviation)
    }
    
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
            .navigationTitle(isEditing ? "Edit Card" : "New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(trimmedWord, trimmedDefinition, wordType, wordTypeAbbreviation)
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
        if wordTypeGenerator.isGenerating || wordType != nil {
            Section {
                HStack {
                    Spacer()
                    if wordTypeGenerator.isGenerating {
                        ProgressView()
                            .controlSize(.small)
                        Text("Classifying...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else if let type = wordType, let abbreviation = wordTypeAbbreviation {
                        Text(abbreviation.uppercased())
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(badgeColor(for: type), in: Capsule())
                        
                        Text(type.capitalized)
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
            Text(isEditing ? "Edit manually or regenerate with AI." : "Type a definition manually or use AI to generate one.")
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
        if let generated = wordTypeGenerator.generatedWordType {
            wordType = generated.wordType
            wordTypeAbbreviation = generated.abbreviation
        }
    }
}

#Preview("Add") {
    CardFormView { word, definition, wordType, abbreviation in
        print("Added: \(word)")
    }
}

#Preview("Edit") {
    CardFormView(
        card: Flashcard(word: "Ephemeral", definition: "Lasting for a short time", wordType: "adjective", wordTypeAbbreviation: "adj")
    ) { word, definition, wordType, abbreviation in
        print("Edited: \(word)")
    }
}
