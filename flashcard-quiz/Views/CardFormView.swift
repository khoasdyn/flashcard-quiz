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
    
    @FocusState private var isWordFieldFocused: Bool
    
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
            VStack(spacing: 0) {
                Form {
                    Section("Word") {
                        TextField("Enter a word", text: $word)
                            .focused($isWordFieldFocused)
                    }
                    
                    Section("Word Type") {
                        Picker("Select type", selection: $wordType) {
                            Text("None").tag(WordType?.none)
                            ForEach(WordType.allCases, id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(WordType?.some(type))
                            }
                        }
                        
                        if let wordType {
                            HStack {
                                Spacer()
                                WordTypeBadge(wordType: wordType)
                                Spacer()
                            }
                        }
                    }
                    
                    Section("Definition") {
                        TextField("Definition", text: $definition, axis: .vertical)
                            .lineLimit(3...6)
                        
                        if generator.isGenerating {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .controlSize(.small)
                                Text("Generating...")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                            }
                        }
                        
                        if let error = generator.error {
                            Text(error.localizedDescription)
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                }
                
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
                    .padding(.vertical, 14)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .fontWeight(.semibold)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!canGenerate)
                .opacity(canGenerate ? 1 : 0.5)
                .padding()
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
                
                // Auto-focus the word field only when adding a new card,
                // not when editing an existing one
                if !isEditing {
                    isWordFieldFocused = true
                }
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
