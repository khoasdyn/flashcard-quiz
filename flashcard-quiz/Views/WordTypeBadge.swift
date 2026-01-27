//
//  WordTypeBadge.swift
//  flashcard-quiz
//
//  Created by khoasdyn on 27/1/26.
//

import SwiftUI

struct WordTypeBadge: View {
    let wordType: WordType?
    
    var body: some View {
        if let wordType {
            Text(wordType.rawValue.capitalized)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(wordType.color, in: Capsule())
        } else {
            Text("N/A")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.gray.opacity(0.2), in: Capsule())
        }
    }
}

#Preview {
    VStack(spacing: 12) {
        WordTypeBadge(wordType: .noun)
        WordTypeBadge(wordType: .verb)
        WordTypeBadge(wordType: .adjective)
        WordTypeBadge(wordType: nil)
    }
}
