# Flashcard Quiz App

A SwiftUI flashcard app with flip animations and AI-powered generation using FoundationModels.

## Tech Stack

- **SwiftUI** - UI framework
- **SwiftData** - Persistence
- **FoundationModels** - On-device AI (iOS 26+)

## Project Structure

```
flashcard-quiz/
├── Models/
│   └── Flashcard.swift       # SwiftData model + WordType enum
├── Views/
│   ├── FlashcardView.swift   # Animated flip card
│   ├── CardFormView.swift    # Add/edit sheet
│   └── WordTypeBadge.swift   # Reusable badge component
├── Services/
│   └── AIGenerator.swift     # Single AI generator for definition + word type
├── ContentView.swift         
└── flashcard_quizApp.swift   
```

## Key Techniques

### 1. WordType as enum

Instead of storing word type as two separate strings, use an enum with computed properties for abbreviation and color. SwiftData cannot store enums directly, so store the raw string value and expose a computed property.

```swift
@Model
class Flashcard {
    var word: String
    var definition: String
    var createdAt: Date
    var wordTypeRaw: String?
    
    var wordType: WordType? {
        get { wordTypeRaw.flatMap { WordType(rawValue: $0) } }
        set { wordTypeRaw = newValue?.rawValue }
    }
}

enum WordType: String, CaseIterable {
    case noun, verb, adjective, adverb, preposition, conjunction, pronoun, interjection, determiner, phrase
    
    var abbreviation: String {
        switch self {
        case .noun: "n"
        case .verb: "v"
        case .adjective: "adj"
        // ...
        }
    }
    
    var color: Color {
        switch self {
        case .noun: .blue
        case .verb: .green
        case .adjective: .orange
        // ...
        }
    }
}
```

### 2. Single AI generator

One `@Generable` struct produces both definition and word type in a single API call. More efficient than two separate requests.

```swift
@Generable
struct GeneratedCard {
    @Guide(description: "A clear, beginner-friendly definition in exactly 2 sentences.")
    let definition: String
    
    @Guide(description: "The grammatical word type. Must be one of: noun, verb, adjective...")
    let wordType: String
}

@Observable
@MainActor
final class AIGenerator {
    private(set) var result: GeneratedCard?
    private(set) var isGenerating = false
    var error: Error?
    
    private var session: LanguageModelSession
    
    func generate(for word: String) async {
        // Single call returns both definition and wordType
    }
}
```

### 3. Reusable WordTypeBadge

Extract badge styling into a standalone component used by both ContentView and CardFormView.

```swift
struct WordTypeBadge: View {
    let wordType: WordType?
    
    var body: some View {
        if let wordType {
            Text(wordType.abbreviation.uppercased())
                .background(wordType.color, in: Capsule())
        } else {
            Text("N/A")
                .background(.gray.opacity(0.2), in: Capsule())
        }
    }
}
```

### 4. Unified CardFormView

Single view handles both add and edit. Difference is whether a card is passed to the initializer.

```swift
struct CardFormView: View {
    let card: Flashcard?
    var onSave: (String, String, WordType?) -> Void
    
    private var isEditing: Bool { card != nil }
    
    init(card: Flashcard? = nil, onSave: @escaping (String, String, WordType?) -> Void) {
        self.card = card
        self.onSave = onSave
        _word = State(initialValue: card?.word ?? "")
        _definition = State(initialValue: card?.definition ?? "")
        _wordType = State(initialValue: card?.wordType)
    }
}
```

### 5. Card flip animation with Animatable

Expose rotation as `animatableData` so SwiftUI interpolates frame-by-frame. Content switches when rotation crosses 90 degrees.

```swift
struct FlashcardView: View, Animatable {
    var rotation: Double
    
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    private var showingFront: Bool { rotation < 90 }
}
```

### 6. Back side counter-rotation

Pre-rotate back content 180 degrees so it appears correctly when the card flips.

```swift
private var backSide: some View {
    RoundedRectangle(cornerRadius: 16)
        .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
        .opacity(showingFront ? 0 : 1)
}
```

## Features

- Tap to flip with smooth 3D animation
- Navigate between cards
- Add/edit cards with unified form
- AI-generate definition + word type in one call
- Colored word type badges
- SwiftData persistence

## Requirements

- iOS 26+
- Apple Intelligence enabled device
