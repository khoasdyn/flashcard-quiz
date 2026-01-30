# Flashcard Quiz App

A SwiftUI flashcard app with flip animations and AI-powered generation using FoundationModels.

## Tech stack

- **SwiftUI** for the UI framework
- **SwiftData** for persistence
- **FoundationModels** for on-device AI (iOS 26+)

## Project structure

```
flashcard-quiz/
├── ContentView.swift              # TabView container
├── Models/
│   └── Flashcard.swift            # SwiftData model + WordType enum
├── Views/
│   ├── AIGenerateButton.swift     # Extracted button with styling and state
│   ├── CardDetailView.swift       # Sheet for viewing card from list
│   ├── CardFormView.swift         # Add/edit form with AI generation
│   ├── CardRowView.swift          # List row component
│   ├── FlashcardTabView.swift     # Cards tab with flip animation
│   ├── FlashcardView.swift        # Animated flip card
│   ├── ListTabView.swift          # List tab with swipe actions
│   └── WordTypeBadge.swift        # Reusable badge component
├── Services/
│   └── AIGenerator.swift          # AI generator for definition + word type
└── flashcard_quizApp.swift        # App entry point
```

## Features

- Two view modes via TabView: flip card view and vertical list view
- Tap card to flip with smooth 3D animation
- Navigate between cards with arrow buttons (Cards tab)
- Swipe to edit or delete cards (List tab)
- Add/edit cards with unified form
- Manual word type selection via Picker dropdown
- AI-generate definition and word type in one call
- Colored word type badges
- SwiftData persistence

## Key techniques

### 1. Card flip animation with Animatable

The card flip uses SwiftUI's `Animatable` protocol to create smooth mid-animation content switching. Exposing `rotation` as `animatableData` lets SwiftUI interpolate it frame-by-frame, and the content switches exactly when rotation crosses 90 degrees.

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

### 2. Back side counter-rotation

The back side content appears mirrored without correction. Pre-rotating the back side 180 degrees cancels this out.

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
}

enum WordType: String, CaseIterable {
    case noun, verb, adjective, adverb, preposition, conjunction, pronoun, interjection, determiner, phrase
    
    var color: Color { ... }
}
```

### 4. Single AI generator with FoundationModels

One `@Generable` struct produces both definition and word type in a single API call.

```swift
@Generable
struct GeneratedCard {
    @Guide(description: "A clear, beginner-friendly definition in exactly 2 sentences.")
    let definition: String
    
    @Guide(description: "The grammatical word type. Must be one of: noun, verb, adjective, adverb, preposition, conjunction, pronoun, interjection, determiner, phrase")
    let wordType: String
}

@Observable
@MainActor
final class AIGenerator {
    private(set) var result: GeneratedCard?
    private(set) var isGenerating = false
    var error: Error?
    
    private var session: LanguageModelSession
    
    func generate(for word: String) async { ... }
    func prewarm() { session.prewarm() }
}
```

### 5. Picker with optional binding

When binding a Picker to an optional type, tag values must match the selection type exactly using `WordType?.none` and `WordType?.some(type)`.

```swift
Picker("Select type", selection: $wordType) {
    Text("None").tag(WordType?.none)
    ForEach(WordType.allCases, id: \.self) { type in
        Text(type.rawValue.capitalized).tag(WordType?.some(type))
    }
}
```

### 6. Unified CardFormView for add and edit

A single view handles both creating new cards and editing existing ones using `State(initialValue:)` to pre-populate fields.

```swift
struct CardFormView: View {
    let card: Flashcard?
    var onSave: (String, String, WordType?) -> Void
    
    @State private var word: String
    @State private var definition: String
    @State private var wordType: WordType?
    
    init(card: Flashcard? = nil, onSave: @escaping (String, String, WordType?) -> Void) {
        self.card = card
        self.onSave = onSave
        _word = State(initialValue: card?.word ?? "")
        _definition = State(initialValue: card?.definition ?? "")
        _wordType = State(initialValue: card?.wordType)
    }
}
```

### 7. Extracted AIGenerateButton component

The AI generate button has substantial styling (frame, padding, background, clip shape) and state handling (generating state, disabled state). Extracting it into its own view keeps `CardFormView` focused on form logic while making the button reusable.

```swift
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
```

The button accepts three parameters: `isGenerating` controls the label text, `canGenerate` controls enabled state and opacity, and `onTap` is the action closure. The async logic stays in the parent view because it updates `@State` properties that belong to `CardFormView`.

### 8. Sheet binding with item

Use `.sheet(item:)` for sheets that need to pass data. The sheet dismisses when the binding is `nil` and presents when assigned a value.

```swift
@State private var cardToEdit: Flashcard?

.sheet(item: $cardToEdit) { card in
    CardFormView(card: card) { word, definition, wordType in
        card.word = word
        card.definition = definition
        card.wordType = wordType
    }
}
```

### 9. TabView with iOS 18+ syntax

The new `Tab` initializer provides a cleaner API than the older `.tabItem` modifier.

```swift
TabView {
    Tab("Cards", systemImage: "rectangle.stack") {
        FlashcardTabView()
    }
    
    Tab("List", systemImage: "list.bullet") {
        ListTabView()
    }
}
```

### 10. Swipe actions in List

List rows support leading and trailing swipe actions with customizable tint colors.

```swift
.swipeActions(edge: .trailing, allowsFullSwipe: true) {
    Button(role: .destructive) {
        modelContext.delete(card)
    } label: {
        Label("Delete", systemImage: "trash")
    }
}
.swipeActions(edge: .leading) {
    Button {
        cardToEdit = card
    } label: {
        Label("Edit", systemImage: "pencil")
    }
    .tint(.orange)
}
```

### 11. Keyboard avoidance for sheets

SwiftUI's automatic keyboard avoidance operates at the window level, not the view level. When a keyboard appears in a sheet, the safe area change propagates to all views in the window, including the content behind the sheet overlay.

To prevent the underlying view from shifting when the sheet's keyboard appears, apply `.ignoresSafeArea(.keyboard)` to the view that presents the sheet.

```swift
// In FlashcardTabView
VStack(spacing: 24) {
    // content
}
.padding()
.ignoresSafeArea(.keyboard)
.sheet(isPresented: $showingAddSheet) {
    CardFormView { ... }
}

// In ListTabView
NavigationStack {
    // content
}
.ignoresSafeArea(.keyboard)
.sheet(isPresented: $showingAddSheet) {
    CardFormView { ... }
}
```

This modifier tells the presenting view to ignore keyboard-related safe area changes while allowing the sheet itself to handle keyboard avoidance normally.

## Requirements

- iOS 26+
- Apple Intelligence enabled device
