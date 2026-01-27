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
│   └── AIGenerator.swift     # AI generator for definition + word type
├── ContentView.swift         
└── flashcard_quizApp.swift   
```

## Features

- Tap card to flip with smooth 3D animation
- Navigate between cards with arrow buttons
- Add/edit cards with unified form
- AI-generate definition and word type in one call
- Colored word type badges (old cards show "N/A")
- SwiftData persistence

## Key Techniques

### 1. Card flip animation with Animatable

The card flip uses SwiftUI's `Animatable` protocol to create smooth mid-animation content switching. Without `Animatable`, opacity changes happen instantly when state changes, not during the animation. Exposing `rotation` as `animatableData` lets SwiftUI interpolate it frame-by-frame, and the content switches exactly when rotation crosses 90 degrees.

```swift
struct FlashcardView: View, Animatable {
    let card: Flashcard
    var rotation: Double
    
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    private var showingFront: Bool { rotation < 90 }
    
    init(card: Flashcard, isFlipped: Bool) {
        self.card = card
        self.rotation = isFlipped ? 180 : 0
    }
    
    var body: some View {
        ZStack {
            frontSide
            backSide
        }
        .rotation3DEffect(.degrees(rotation), axis: (0, 1, 0))
    }
}
```

When `isFlipped` toggles, SwiftUI interpolates rotation (0 → 30 → 60 → 90 → 120 → 150 → 180), and at each frame `showingFront` recalculates to switch content at the right moment.

### 2. Back side counter-rotation

The back side content appears mirrored without correction because the entire card rotates 180 degrees. Pre-rotating the back side 180 degrees cancels this out.

```swift
private var backSide: some View {
    RoundedRectangle(cornerRadius: 16)
        .fill(.blue.gradient)
        .overlay { Text(card.definition) }
        .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
        .opacity(showingFront ? 0 : 1)
}
```

### 3. SwiftData with enum storage

SwiftData cannot store enums directly. Store the raw string value and expose a computed property for type-safe access.

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
    
    init(word: String, definition: String, wordType: WordType? = nil) {
        self.word = word
        self.definition = definition
        self.createdAt = Date()
        self.wordTypeRaw = wordType?.rawValue
    }
}

enum WordType: String, CaseIterable {
    case noun, verb, adjective, adverb, preposition, conjunction, pronoun, interjection, determiner, phrase
    
    var color: Color {
        switch self {
        case .noun: .blue
        case .verb: .green
        case .adjective: .orange
        case .adverb: .purple
        case .preposition: .pink
        case .conjunction: .cyan
        case .pronoun: .indigo
        case .interjection: .red
        case .determiner: .mint
        case .phrase: .teal
        }
    }
}
```

The enum uses full word names as raw values ("noun", "verb", etc.), which matches what the AI generates and displays nicely with `.rawValue.capitalized`.

### 4. Single AI generator with FoundationModels

One `@Generable` struct produces both definition and word type in a single API call, more efficient than separate requests.

```swift
@Generable
struct GeneratedCard {
    @Guide(description: "A clear, beginner-friendly definition in exactly 2 sentences.")
    let definition: String
    
    @Guide(description: "The grammatical word type. Must be one of: noun, verb, adjective, adverb, preposition, conjunction, pronoun, interjection, determiner, phrase")
    let wordType: String
}

extension GeneratedCard {
    static let example = GeneratedCard(
        definition: "Feeling good and joyful inside. People often smile when they are happy.",
        wordType: "adjective"
    )
}

@Observable
@MainActor
final class AIGenerator {
    private(set) var result: GeneratedCard?
    private(set) var isGenerating = false
    var error: Error?
    
    private var session: LanguageModelSession
    
    init() {
        let instructions = Instructions {
            "You are a vocabulary assistant."
            "Provide clear, beginner-friendly definitions in 2 sentences."
            "Classify words into their grammatical category."
        }
        self.session = LanguageModelSession(tools: [], instructions: instructions)
    }
    
    func generate(for word: String) async {
        result = nil
        error = nil
        isGenerating = true
        defer { isGenerating = false }
        
        do {
            let prompt = Prompt {
                "Define and classify the word '\(word)'."
                "Example:"
                GeneratedCard.example
            }
            
            let response = try await session.respond(
                to: prompt,
                generating: GeneratedCard.self,
                includeSchemaInPrompt: false
            )
            
            result = response.content
        } catch {
            self.error = error
        }
    }
    
    func prewarm() {
        session.prewarm()
    }
}
```

### 5. Reusable WordTypeBadge

Extract badge styling into a standalone component used by both ContentView and CardFormView. Cards without classification show "N/A".

```swift
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
```

### 6. Unified CardFormView for add and edit

A single view handles both creating new cards and editing existing ones. The difference is whether a card is passed to the initializer. Use `State(initialValue:)` to pre-populate fields from an existing card.

```swift
struct CardFormView: View {
    let card: Flashcard?
    var onSave: (String, String, WordType?) -> Void
    
    @State private var word: String
    @State private var definition: String
    @State private var wordType: WordType?
    @State private var generator = AIGenerator()
    
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

Usage in ContentView:

```swift
// Add new card (no card parameter)
.sheet(isPresented: $showingAddSheet) {
    CardFormView { word, definition, wordType in
        let card = Flashcard(word: word, definition: definition, wordType: wordType)
        modelContext.insert(card)
    }
}

// Edit existing card (pass current card)
.sheet(isPresented: $showingEditSheet) {
    if let card = currentCard {
        CardFormView(card: card) { word, definition, wordType in
            card.word = word
            card.definition = definition
            card.wordType = wordType
        }
    }
}
```

### 7. View ID for state reset

Use `.id()` modifier to force view recreation when navigating between cards. This resets the FlashcardView animation state.

```swift
FlashcardView(card: card, isFlipped: isFlipped)
    .id(card.id)
```

### 8. Static dimensions for consistency

Define card dimensions as static constants to share between FlashcardView and empty state placeholder.

```swift
struct FlashcardView: View, Animatable {
    static let cardWidth: CGFloat = 340
    static let cardHeight: CGFloat = 400
}

// In ContentView
private var emptyState: some View {
    RoundedRectangle(cornerRadius: 16)
        .fill(.gray.opacity(0.2))
        .frame(width: FlashcardView.cardWidth, height: FlashcardView.cardHeight)
}
```

## Requirements

- iOS 26+
- Apple Intelligence enabled device
