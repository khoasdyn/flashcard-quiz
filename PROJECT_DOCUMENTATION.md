# Flashcard Quiz App

A SwiftUI flashcard language learning app with smooth card flip animations and AI-powered definition generation.

## Tech Stack

- **SwiftUI** - UI framework
- **SwiftData** - Persistence
- **FoundationModels** - On-device AI generation (iOS 26+)

## Project Structure

```
flashcard-quiz/
├── Models/
│   ├── Flashcard.swift           # SwiftData model
│   ├── GeneratedDefinition.swift # FoundationModels schema for definitions
│   └── GeneratedWordType.swift   # FoundationModels schema for word classification
├── Views/
│   ├── FlashcardView.swift       # Animated flip card component
│   └── AddCardView.swift         # Card creation sheet with AI generation
├── Services/
│   ├── DefinitionGenerator.swift # AI definition generator
│   └── WordTypeGenerator.swift   # AI word type classifier
├── ContentView.swift             # Main screen
└── flashcard_quizApp.swift       # App entry point
```

## Key Techniques

### 1. Smooth card flip animation using Animatable protocol

The card flip uses SwiftUI's `Animatable` protocol to create smooth mid-animation content switching.

**Problem**: Without `Animatable`, opacity changes happen instantly when state changes, not during the animation.

**Solution**: Expose `rotation` as `animatableData` so SwiftUI interpolates it frame-by-frame. Compute which side to show based on current rotation value.

```swift
struct FlashcardView: View, Animatable {
    var rotation: Double
    
    var animatableData: Double {
        get { rotation }
        set { rotation = newValue }
    }
    
    // Content switches exactly when rotation crosses 90 degrees
    private var showingFront: Bool { rotation < 90 }
    
    init(card: Flashcard, isFlipped: Bool) {
        self.rotation = isFlipped ? 180 : 0
    }
}
```

**Flow**:
1. `isFlipped` toggles from `false` to `true`
2. SwiftUI sees rotation should change from `0` to `180`
3. `animatableData` interpolates: 0 → 30 → 60 → 90 → 120 → 150 → 180
4. At each frame, `showingFront` recalculates
5. When rotation crosses 90, opacity switches

### 2. Back side counter-rotation

The back side content appears mirrored without correction because the entire card rotates 180 degrees.

**Solution**: Pre-rotate the back side 180 degrees. When card rotates 180°, the two rotations cancel out.

```swift
private var backSide: some View {
    RoundedRectangle(cornerRadius: 16)
        .fill(.blue.gradient)
        .overlay { Text(card.definition) }
        .rotation3DEffect(.degrees(180), axis: (0, 1, 0)) // Counter-rotation
        .opacity(showingFront ? 0 : 1)
}
```

### 3. SwiftData persistence

**Model**: Use `@Model` macro on a class (not struct). Optional properties store word type classification.

```swift
@Model
class Flashcard {
    var word: String
    var definition: String
    var createdAt: Date
    var wordType: String?
    var wordTypeAbbreviation: String?
    
    init(word: String, definition: String, wordType: String? = nil, wordTypeAbbreviation: String? = nil) {
        self.word = word
        self.definition = definition
        self.createdAt = Date()
        self.wordType = wordType
        self.wordTypeAbbreviation = wordTypeAbbreviation
    }
}
```

**App setup**: Attach model container to WindowGroup.

```swift
@main
struct flashcard_quizApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Flashcard.self)
    }
}
```

**View usage**: Query and modify via environment.

```swift
@Environment(\.modelContext) private var modelContext
@Query(sort: \Flashcard.createdAt) private var cards: [Flashcard]

func addCard(word: String, definition: String, wordType: String?, abbreviation: String?) {
    let newCard = Flashcard(
        word: word,
        definition: definition,
        wordType: wordType,
        wordTypeAbbreviation: abbreviation
    )
    modelContext.insert(newCard)
}

func deleteCard(_ card: Flashcard) {
    modelContext.delete(card)
}
```

### 4. FoundationModels AI generation

**Schema**: Define output structure with `@Generable` and guide the AI with `@Guide`.

```swift
@Generable
struct GeneratedDefinition {
    @Guide(description: "A clear, beginner-friendly definition in exactly 2 sentences.")
    let definition: String
}

extension GeneratedDefinition {
    static let example = GeneratedDefinition(
        definition: "Feeling good and joyful inside. People often smile when happy."
    )
}
```

**Generator**: Use `@Observable` class with `LanguageModelSession`.

```swift
@Observable
@MainActor
final class DefinitionGenerator {
    private(set) var generatedDefinition: String?
    private(set) var isGenerating = false
    var error: Error?
    
    private var session: LanguageModelSession
    
    init() {
        let instructions = Instructions {
            "You are a helpful vocabulary assistant."
            "Provide clear, beginner-friendly definitions in exactly 2 sentences."
        }
        self.session = LanguageModelSession(tools: [], instructions: instructions)
    }
    
    func generateDefinition(for word: String) async {
        isGenerating = true
        defer { isGenerating = false }
        
        do {
            let prompt = Prompt {
                "Define the word '\(word)' in simple language."
                GeneratedDefinition.example
            }
            
            let stream = session.streamResponse(
                to: prompt,
                generating: GeneratedDefinition.self,
                includeSchemaInPrompt: false
            )
            
            for try await partialResponse in stream {
                if let definition = partialResponse.content.definition {
                    generatedDefinition = definition
                }
            }
        } catch {
            self.error = error
        }
    }
    
    func prewarm() {
        session.prewarm()
    }
}
```

### 5. Word type classification with FoundationModels

**Schema**: A separate `@Generable` struct for classifying words into grammatical categories.

```swift
@Generable
struct GeneratedWordType {
    @Guide(description: "The grammatical category of the word. Must be exactly one of: noun, verb, adjective, adverb, preposition, conjunction, pronoun, interjection, determiner, or phrase")
    let wordType: String
    
    @Guide(description: "A 1-3 letter abbreviation of the word type. Use standard abbreviations: n (noun), v (verb), adj (adjective), adv (adverb), prep (preposition), conj (conjunction), pron (pronoun), interj (interjection), det (determiner), phr (phrase)")
    let abbreviation: String
}

extension GeneratedWordType {
    static let nounExample = GeneratedWordType(wordType: "noun", abbreviation: "n")
    static let verbExample = GeneratedWordType(wordType: "verb", abbreviation: "v")
    static let adjectiveExample = GeneratedWordType(wordType: "adjective", abbreviation: "adj")
}
```

**Generator**: Uses non-streaming `respond` method for quick classification. Since word type is short, streaming is unnecessary.

```swift
@Observable
@MainActor
final class WordTypeGenerator {
    private(set) var generatedWordType: GeneratedWordType?
    private(set) var isGenerating = false
    var error: Error?
    
    private var session: LanguageModelSession
    
    init() {
        let instructions = Instructions {
            "You are a grammar expert."
            "Classify words into their grammatical categories."
        }
        self.session = LanguageModelSession(tools: [], instructions: instructions)
    }
    
    func generateWordType(for word: String) async {
        generatedWordType = nil
        isGenerating = true
        defer { isGenerating = false }
        
        do {
            let prompt = Prompt {
                "What is the grammatical word type of '\(word)'?"
                "Examples:"
                GeneratedWordType.nounExample
                GeneratedWordType.verbExample
                GeneratedWordType.adjectiveExample
            }
            
            let response = try await session.respond(
                to: prompt,
                generating: GeneratedWordType.self,
                includeSchemaInPrompt: false
            )
            
            generatedWordType = response.content
        } catch {
            self.error = error
        }
    }
}
```

**Streaming vs Non-streaming**: Use `streamResponse` when output is long (definitions) so users see incremental progress. Use `respond` when output is short (word type) since the full response arrives quickly anyway.

### 6. Running multiple async tasks in parallel

In AddCardView, the generate button triggers both definition and word type generation simultaneously using Swift's structured concurrency.

```swift
Button {
    Task {
        async let definitionTask: () = generateDefinition()
        async let wordTypeTask: () = generateWordType()
        _ = await (definitionTask, wordTypeTask)
    }
} label: {
    // ...
}
```

The `async let` syntax starts both tasks immediately without waiting. The `await` on the tuple ensures both complete before continuing. This is faster than sequential execution since both AI requests run in parallel.

### 7. Displaying persisted word type with fallback

In ContentView, the badge displays the stored word type from the Flashcard model. Cards created before word type classification was added show "N/A" instead.

```swift
@ViewBuilder
private var wordTypeBadge: some View {
    if let card = currentCard {
        HStack {
            if let abbreviation = card.wordTypeAbbreviation, let wordType = card.wordType {
                Text(abbreviation.uppercased())
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(badgeColor(for: wordType), in: Capsule())
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
        .frame(maxWidth: .infinity)
    }
}
```

### 8. View ID for state reset

When navigating between cards, use `.id()` modifier to force view recreation. This resets the FlashcardView animation state.

```swift
FlashcardView(card: card, isFlipped: isFlipped)
    .id(card.id) // Forces new view instance when card changes
```

### 9. Static dimensions for consistency

Define card dimensions as static constants to share between FlashcardView and empty state.

```swift
struct FlashcardView: View, Animatable {
    static let cardWidth: CGFloat = 340
    static let cardHeight: CGFloat = 240
}

// In ContentView
private var emptyState: some View {
    RoundedRectangle(cornerRadius: 16)
        .frame(width: FlashcardView.cardWidth, height: FlashcardView.cardHeight)
}
```

## Features

- Tap card to flip with smooth 3D animation
- Navigate between cards with arrow buttons
- Add new cards via sheet with form
- AI-generate definitions using on-device model
- Auto-classify word types (noun, verb, adj, etc.) with colored badge
- Word type persists with each card and displays in ContentView
- Old cards without classification show "N/A" badge
- Delete cards
- Data persists across app launches

## Requirements

- iOS 26+
- Device with Apple Intelligence enabled (for AI generation)
