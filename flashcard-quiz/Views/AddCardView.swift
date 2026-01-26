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
    
    var onSave: (String, String) -> Void
    
    private var canSave: Bool {
        !word.trimmingCharacters(in: .whitespaces).isEmpty &&
        !definition.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Front") {
                    TextField("Word", text: $word)
                }
                
                Section("Back") {
                    TextField("Definition", text: $definition, axis: .vertical)
                        .lineLimit(3...6)
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
        }
    }
}

#Preview {
    AddCardView { word, definition in
        print("Saved: \(word) - \(definition)")
    }
}
