# Flashcard Quiz

A SwiftUI flashcard app for vocabulary learning with flip animations and AI-powered content generation.

## Features

- Two view modes: flip through cards with 3D animations or browse a scrollable list
- AI generation: auto-generate definitions and word types using on-device Apple Intelligence
- Manual word type selection via dropdown picker
- Color-coded word type badges for noun, verb, adjective, and more
- Swipe actions for quick edit and delete in list view
- Local persistence with SwiftData

## Requirements

- iOS 26+
- Device with Apple Intelligence support

## Tech stack

- SwiftUI
- SwiftData
- FoundationModels

## Project structure

```
flashcard-quiz/
├── ContentView.swift              # TabView container with Cards and List tabs
├── Models/
│   └── Flashcard.swift            # SwiftData model with WordType enum
├── Views/
│   ├── AIGenerateButton.swift     # Reusable AI generate button with styling
│   ├── CardDetailView.swift       # Sheet for viewing a card from list
│   ├── CardFormView.swift         # Unified add/edit form with AI generation
│   ├── CardRowView.swift          # List row showing word, definition, badge
│   ├── FlashcardTabView.swift     # Cards tab with navigation and flip cards
│   ├── FlashcardView.swift        # Animated 3D flip card component
│   ├── ListTabView.swift          # List tab with swipe actions
│   └── WordTypeBadge.swift        # Color-coded capsule badge
├── Services/
│   └── AIGenerator.swift          # FoundationModels integration
└── flashcard_quizApp.swift        # App entry point with model container
```

## Installation

1. Clone the repository
2. Open `flashcard-quiz.xcodeproj` in Xcode
3. Build and run on a supported device

## Usage

### Cards tab
- Tap card to flip between word and definition
- Use arrow buttons to navigate between cards
- Add, edit, or delete cards with bottom buttons

### List tab
- Tap any card to view details in a sheet
- Swipe right to edit
- Swipe left to delete

### Adding cards
- Enter a word manually
- Select word type from dropdown or tap AI Generate
- AI fills both definition and word type automatically

## Documentation

See `PROJECT_DOCUMENTATION.md` for detailed technical documentation including architecture decisions, key techniques, and code examples.

## License

MIT
