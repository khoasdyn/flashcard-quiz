//
//  AIGenerateButton.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 30/1/26.
//

import SwiftUI

struct AIGenerateButton: View {
    let isGenerating: Bool
    let canGenerate: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button {
            onTap()
        } label: {
            HStack {
                Image(systemName: "sparkles")
                Text(isGenerating ? "Generating..." : "AI Generate")
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
}

#Preview {
    VStack {
        AIGenerateButton(isGenerating: false, canGenerate: true) {
            print("Generate tapped")
        }
        
        AIGenerateButton(isGenerating: true, canGenerate: false) {
            print("Generate tapped")
        }
        
        AIGenerateButton(isGenerating: false, canGenerate: false) {
            print("Generate tapped")
        }
    }
}
