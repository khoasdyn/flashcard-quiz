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
    
    private var canSave: Bool {
        !word.trimmingCharacters(in: .whitespaces).isEmpty &&
        !definition.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var canGenerate: Bool {
        !word.trimmingCharacters(in: .whitespaces).isEmpty && !generator.isGenerating
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Front") {
                    TextField("Word", text: $word)
                }
                
                Section {
                    TextField("Definition", text: $definition, axis: .vertical)
                        .lineLimit(3...6)
                    
                    Button {
                        Task {
                            await generator.generateDefinition(for: word)
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
                    
                    if let error = generator.error {
                        Text(error.localizedDescription)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Back")
                } footer: {
                    Text("Type a definition manually or use AI to generate one based on the word.")
                }
            }
            .navigationTitle("New Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        onSave(word.trimmingCharacters(in: .whitespaces),
                               definition.trimmingCharacters(in: .whitespaces))
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

#Preview {
    AddCardView { word, definition in
        print("Saved: \(word) - \(definition)")
    }
}
