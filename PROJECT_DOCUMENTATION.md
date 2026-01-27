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
│   └── CardFormView.swift        # Unified add/edit sheet with AI generation
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
        .rotation3DEffect(.degrees(180), axis: (0, 1, 0))
        .opacity(showingFront ? 0 : 1)
}
```

### 3. SwiftData persistence

**Model**: Use `@Model` macro on a class. Optional properties store word type classification.

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

**Generator**: Use `@Observable` class with `LanguageModelSession`. Use `streamResponse` for long outputs (definitions) so users see incremental progress. Use `respond` for short outputs (word type) since the full response arrives quickly.

### 5. Unified form view for add and edit

A single `CardFormView` handles both creating new cards and editing existing ones. The difference is whether a card is passed to the initializer.

```swift
struct CardFormView: View {
    let card: Flashcard?
    var onSave: (String, String, String?, String?) -> Void
    
    @State private var word: String
    @State private var definition: String
    @State private var wordType: String?
    @State private var wordTypeAbbreviation: String?
    
    private var isEditing: Bool { card != nil }
    
    init(card: Flashcard? = nil, onSave: @escaping (String, String, String?, String?) -> Void) {
        self.card = card
        self.onSave = onSave
        _word = State(initialValue: card?.word ?? "")
        _definition = State(initialValue: card?.definition ?? "")
        _wordType = State(initialValue: card?.wordType)
        _wordTypeAbbreviation = State(initialValue: card?.wordTypeAbbreviation)
    }
}
```

The `isEditing` computed property checks if a card was provided. This controls the navigation title ("New Card" vs "Edit Card") and footer text. The `State(initialValue:)` pattern uses optional chaining with nil coalescing to handle both cases: when editing, fields are pre-populated from the card; when adding, fields start empty.

**Usage in ContentView**:

```swift
// Add new card (no card parameter)
.sheet(isPresented: $showingAddSheet) {
    CardFormView { word, definition, wordType, abbreviation in
        addCard(...)
    }
}

// Edit existing card (pass current card)
.sheet(isPresented: $showingEditSheet) {
    if let card = currentCard {
        CardFormView(card: card) { word, definition, wordType, abbreviation in
            updateCard(card, ...)
        }
    }
}
```

### 6. Running multiple async tasks in parallel

The generate button triggers both definition and word type generation simultaneously.

```swift
Task {
    async let definitionTask: () = generateDefinition()
    async let wordTypeTask: () = generateWordType()
    _ = await (definitionTask, wordTypeTask)
}
```

The `async let` syntax starts both tasks immediately without waiting. The `await` on the tuple ensures both complete before continuing.

### 7. Displaying persisted word type with fallback

Cards without classification show "N/A" badge.

```swift
@ViewBuilder
private var wordTypeBadge: some View {
    if let card = currentCard {
        HStack {
            if let abbreviation = card.wordTypeAbbreviation, let wordType = card.wordType {
                Text(abbreviation.uppercased())
                    // ... colored badge
            } else {
                Text("N/A")
                    // ... gray badge
            }
        }
    }
}
```

### 8. View ID for state reset

Use `.id()` modifier to force view recreation when navigating between cards.

```swift
FlashcardView(card: card, isFlipped: isFlipped)
    .id(card.id)
```

### 9. Static dimensions for consistency

```swift
struct FlashcardView: View, Animatable {
    static let cardWidth: CGFloat = 340
    static let cardHeight: CGFloat = 400
}
```

## Features

- Tap card to flip with smooth 3D animation
- Navigate between cards with arrow buttons
- Add new cards via sheet with form
- Edit existing cards with pre-populated form
- AI-generate definitions using on-device model
- Auto-classify word types (noun, verb, adj, etc.) with colored badge
- Word type persists with each card and displays in ContentView
- Old cards without classification show "N/A" badge
- Delete cards
- Data persists across app launches

## Requirements

- iOS 26+
- Device with Apple Intelligence enabled (for AI generation)
