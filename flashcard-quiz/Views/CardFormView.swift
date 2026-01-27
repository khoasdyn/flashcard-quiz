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
    var onSave: (String, String, WordType?) -> Void
    
    @State private var word: String
    @State private var definition: String
    @State private var wordType: WordType?
    @State private var generator = AIGenerator()
    
    private var isEditing: Bool { card != nil }
    private var canSave: Bool { !word.trimmingCharacters(in: .whitespaces).isEmpty && !definition.trimmingCharacters(in: .whitespaces).isEmpty }
    private var canGenerate: Bool { !word.trimmingCharacters(in: .whitespaces).isEmpty && !generator.isGenerating }
    
    init(card: Flashcard? = nil, onSave: @escaping (String, String, WordType?) -> Void) {
        self.card = card
        self.onSave = onSave
        _word = State(initialValue: card?.word ?? "")
        _definition = State(initialValue: card?.definition ?? "")
        _wordType = State(initialValue: card?.wordType)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Word") {
                    TextField("Enter a word", text: $word)
                }
                
                if generator.isGenerating || wordType != nil {
                    Section {
                        HStack {
                            Spacer()
                            if generator.isGenerating {
                                ProgressView()
                                    .controlSize(.small)
                                Text("Generating...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                WordTypeBadge(wordType: wordType)
                                if let wordType {
                                    Text(wordType.rawValue.capitalized)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                
                Section {
                    TextField("Definition", text: $definition, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Button {
                        Task {
                            await generator.generate(for: word.trimmingCharacters(in: .whitespaces))
                            if let result = generator.result {
                                definition = result.definition
                                wordType = WordType(rawValue: result.wordType)
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
                    
                    if let error = generator.error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Definition")
                }
            }
            .navigationTitle(isEditing ? "Edit Card" : "New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(
                            word.trimmingCharacters(in: .whitespaces),
                            definition.trimmingCharacters(in: .whitespaces),
                            wordType
                        )
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
}

#Preview("Add") {
    CardFormView { _, _, _ in }
}

#Preview("Edit") {
    CardFormView(card: Flashcard(word: "Ephemeral", definition: "Lasting briefly", wordType: .adjective)) { _, _, _ in }
}
