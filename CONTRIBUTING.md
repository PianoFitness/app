# Contributing to Piano Fitness 🎹

Thank you for your interest in contributing to Piano Fitness! This document provides guidelines and information for developers, musicians, and educators who want to contribute to the project.

## 🚀 Quick Start for Contributors

### Prerequisites

- **Flutter SDK** (latest stable version)
- **Git** for version control
- **IDE** (VS Code, Android Studio, or IntelliJ recommended)
- **MIDI keyboard** (optional, for testing MIDI features)

### Getting Started

1. **Fork and clone the repository**

   ```bash
   git clone https://github.com/yourusername/piano-fitness.git
   cd piano-fitness/app
   ```

2. **Set up development environment**

   ```bash
   # Install Flutter dependencies
   flutter pub get
   
   # Install development tools
   brew install lefthook markdownlint-cli  # macOS
   # or
   npm install -g lefthook markdownlint-cli  # Cross-platform
   ```

3. **Install git hooks and verify setup**

   ```bash
   # Initialize git hooks for code quality
   lefthook install
   
   # Verify Flutter installation
   flutter doctor
   
   # Run tests to ensure everything works
   flutter test
   ```

4. **Run the application**

   ```bash
   flutter run
   ```

## 🛠️ Development Workflow

### Branch Strategy

- **`main`** - Stable releases and production-ready code
- **`develop`** - Integration branch for new features
- **Feature branches** - Individual features (`feature/accessibility-improvements`)
- **Bug fix branches** - Bug fixes (`fix/midi-connection-issue`)

### Making Changes

1. **Create a feature branch**

   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Follow our coding conventions (see below)
   - Write tests for new functionality
   - Update documentation as needed

3. **Test your changes**

   ```bash
   # Run all tests
   flutter test
   
   # Run tests with coverage
   flutter test --coverage
   
   # Check code quality
   flutter analyze
   dart format .
   ```

4. **Commit and push**

   ```bash
   git add .
   git commit -m "feat: add your feature description"
   git push origin feature/your-feature-name
   ```

5. **Create a Pull Request**
   - Provide a clear description of your changes
   - Reference any related issues
   - Include screenshots for UI changes

## 🏗️ Project Architecture

### Directory Structure

```text
app/
├── lib/
│   ├── main.dart                 # App entry point and Provider configuration
│   ├── features/                 # Feature-based MVVM modules
│   │   ├── device_controller/    # MIDI device testing and control
│   │   ├── midi_settings/        # MIDI device configuration
│   │   ├── notifications/        # Practice reminders and notifications
│   │   ├── play/                 # Main piano interface
│   │   ├── practice/             # Guided practice exercises
│   │   ├── reference/            # Scale and chord reference
│   │   └── repertoire/           # Repertoire practice with timer
│   ├── shared/                   # Common code shared across features
│   │   ├── accessibility/        # Accessibility framework
│   │   ├── models/              # Data models and business entities
│   │   ├── services/            # Business logic and external integrations
│   │   ├── theme/               # Theming and visual design system
│   │   ├── utils/               # Music theory and helper functions
│   │   └── widgets/             # Reusable UI components
│   └── scripts/                  # Development and build scripts
├── test/                         # Test files (mirrors lib/ structure)
├── docs/                         # Project documentation
├── android/                      # Android platform files
├── ios/                          # iOS platform files
├── macos/                        # macOS platform files
├── windows/                      # Windows platform files
├── linux/                        # Linux platform files
└── web/                          # Web platform files
```

### Architecture Pattern: MVVM with Clean Architecture

Piano Fitness follows a **feature-based MVVM architecture**:

- **View (Page)**: Pure UI layer, handles user interactions
- **ViewModel**: Business logic layer, manages state and coordinates between View and shared services
- **Model**: Data structures and business rules (in shared layer)

Each feature is self-contained with its own View and ViewModel, while sharing common functionality through the `shared/` layer.

## 📋 Development Guidelines

### Code Style and Conventions

#### File Naming

- **Files**: Use snake_case (`piano_keyboard_component.dart`)
- **Classes**: Use PascalCase (`PianoKeyboard`, `MidiController`)
- **Variables/Methods**: Use camelCase (`currentNote`, `playSound()`)

### MVVM Implementation Guidelines

1. **Pages (Views)** should be focused purely on UI and user interaction
2. **ViewModels** should handle all business logic and extend `ChangeNotifier`
3. **Shared utilities** should contain pure functions and music theory
4. **Models** should represent data structures and global state

### Package Management

**⚠️ IMPORTANT**: Always use Flutter CLI commands for dependencies:

```bash
# Add dependencies
flutter pub add package_name
flutter pub add --dev package_name  # dev dependencies

# Remove dependencies  
flutter pub remove package_name

# Update dependencies
flutter pub get        # after manual changes
flutter pub upgrade    # upgrade to latest compatible
```

**Never manually edit `pubspec.yaml` for adding/removing dependencies.**

## 🧪 Testing Guidelines

### Test Coverage Requirements

- **New Features**: ≥80% test coverage required
- **Bug Fixes**: Must include regression tests
- **Refactoring**: Must maintain existing coverage levels
- **MIDI Components**: Require comprehensive testing due to complexity

### Test Organization

Tests mirror the `lib/` structure for easy navigation:

```text
test/
├── features/                     # Feature-based MVVM tests
│   ├── play/
│   │   ├── play_page_test.dart          # UI tests
│   │   └── play_page_view_model_test.dart # Business logic tests
│   └── practice/
│       ├── practice_page_test.dart       # UI tests
│       └── practice_page_view_model_test.dart # Business logic tests
├── shared/                       # Shared code tests
│   ├── models/                   # Data model unit tests
│   ├── utils/                    # Music theory and utility tests
│   └── widgets/                  # Shared widget tests
└── widget_integration_test.dart  # Cross-feature integration tests
```

### Testing Commands

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test categories
flutter test test/features/play/       # Play feature tests
flutter test test/shared/models/       # Shared model tests

# Generate and view coverage report
flutter test --coverage && genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Types

- **Unit Tests**: Business logic in ViewModels and utilities
- **Widget Tests**: UI components and user interactions
- **Integration Tests**: Complete workflows and feature interactions
- **Mock Tests**: External dependencies (MIDI devices, Bluetooth)

## 🎵 Music Theory Guidelines

### Note Representation

- Use **scientific pitch notation** (C4 = middle C)
- Support **enharmonic equivalents** (F# = Gb)
- Implement **octave range validation** (A0 to C8)

### Scale and Chord Implementation

- All scales and chords should be mathematically precise
- Support **all 12 keys** with proper enharmonic spelling
- Implement **voice leading algorithms** for smooth progressions
- Use **MIDI note numbers** internally, display names for UI

### Piano Range Optimization

- **49-key standard range**: C2 to C6 for consistent layouts
- **Dynamic centering**: Automatically center exercises within range
- **Responsive key sizing**: Adapt to screen width with proper constraints

## ♿ Accessibility Guidelines

### Accessibility Requirements

Piano Fitness follows **WCAG 2.1 AA** standards:

- **Semantic labeling**: All interactive elements must have descriptive labels
- **Screen reader support**: Comprehensive VoiceOver/TalkBack compatibility
- **Keyboard navigation**: Full app functionality via keyboard
- **Color contrast**: Meet or exceed WCAG contrast requirements

### Accessibility Implementation

```dart
// Example: Accessible piano key
Semantics(
  label: "C4 piano key",
  hint: "Tap to play note",
  button: true,
  child: PianoKey(note: "C4"),
)

// Example: Live region announcement
SemanticsService.announce(
  "Playing C major scale", 
  Directionality.of(context),
);
```

### Accessibility Testing

- Test with **VoiceOver** (iOS) and **TalkBack** (Android)
- Verify **keyboard navigation** works throughout app
- Check **color contrast** ratios meet WCAG standards
- Validate **semantic structure** with accessibility tools

## 🔧 Development Tools and Commands

### Common Development Commands

```bash
# Development workflow
flutter run                      # Run app on default device
flutter run -d device_id         # Run on specific device
flutter run --release            # Release mode

# Code quality (REQUIRED before commits)
flutter analyze                  # Static analysis
dart format .                    # Format code
dart fix --apply                 # Auto-fix issues

# Building
flutter build apk               # Android APK
flutter build ios              # iOS build
flutter build web              # Web build
flutter build macos            # macOS build
```

### Automated Quality Checks

We use **lefthook** for automated code quality:

- **Pre-commit**: Automatically formats code and runs `flutter analyze`
- **Pre-push**: Runs full test suite before pushing
- **Commit-msg**: (Optional) Validates conventional commit format

### Debugging MIDI Issues

```bash
# Check MIDI device connectivity
flutter logs                    # View real-time logs
flutter run --verbose           # Verbose output

# Debug on physical device (MIDI requires real hardware)
flutter devices                 # List available devices
flutter run -d [device-id]      # Run on specific device
```

## 🎯 Contribution Areas

### For Developers

#### Flutter Development

- **UI Components**: Piano keyboard, practice interfaces, responsive layouts
- **State Management**: MVVM architecture, Provider pattern, reactive UI
- **Platform Integration**: MIDI handling, Bluetooth connectivity, native features
- **Performance**: Widget optimization, smooth animations, memory management

#### MIDI Programming

- **Timing Accuracy**: Sub-millisecond precision, real-time processing
- **Device Compatibility**: USB, Bluetooth, network MIDI support
- **Protocol Implementation**: MIDI message parsing, channel management
- **Cross-platform**: iOS, Android, desktop MIDI handling

### For Musicians and Educators

#### Exercise Design

- **Pedagogical Features**: Exercise progression, difficulty adaptation
- **Music Theory**: Scale patterns, chord progressions, voice leading
- **Practice Methodology**: Deliberate practice principles, feedback systems
- **Assessment Tools**: Progress tracking, achievement systems

#### Accessibility and Inclusion

- **Screen Reader Optimization**: Musical context descriptions
- **Motor Accessibility**: Alternative input methods, customizable interactions
- **Cognitive Accessibility**: Clear instructions, consistent navigation
- **Multi-language**: Internationalization, musical terminology

### For Designers

#### User Experience

- **Music Education UX**: Learning-focused interface design
- **Responsive Design**: Phone, tablet, desktop optimization
- **Accessibility**: WCAG compliance, inclusive design patterns
- **Visual Hierarchy**: Clear information architecture

#### Visual Design

- **Music Context**: Colors and typography for learning
- **Dark Mode**: Extended practice session comfort
- **Icon Design**: Musical symbols, interaction indicators
- **Animation**: Smooth, purposeful motion design

## 🐛 Bug Reports and Feature Requests

### Bug Reports

When reporting bugs, please include:

1. **Device Information**: OS, version, device model
2. **Steps to Reproduce**: Detailed reproduction steps
3. **Expected Behavior**: What should happen
4. **Actual Behavior**: What actually happens
5. **Screenshots**: If applicable
6. **MIDI Setup**: If MIDI-related, include device information

### Feature Requests

For new features, please provide:

1. **Problem Statement**: What problem does this solve?
2. **Proposed Solution**: Your suggested implementation
3. **User Stories**: How would users interact with this feature?
4. **Success Criteria**: How do we know when it's complete?
5. **Educational Value**: How does this improve piano learning?

## 📚 Resources for Contributors

### Flutter Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Flutter Widget Catalog](https://flutter.dev/docs/development/ui/widgets)

### Music Theory Resources

- [Music Theory Fundamentals](https://musictheory.net/)
- [MIDI Technical Standard](https://www.midi.org/specifications)
- [Piano Pedagogy Research](https://www.piano-journal.com/)

### Accessibility Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Flutter Accessibility Guide](https://flutter.dev/docs/development/accessibility-and-semantics)
- [Mobile Accessibility Testing](https://developer.android.com/guide/topics/ui/accessibility/testing)

## 🤝 Community Guidelines

### Code of Conduct

Piano Fitness is committed to providing a welcoming and inclusive environment for all contributors. We expect:

- **Respectful communication** in all interactions
- **Constructive feedback** focused on code and ideas, not individuals
- **Collaborative problem-solving** with patience and empathy
- **Educational focus** on improving piano learning outcomes

### Getting Help

- **GitHub Issues**: Technical questions and bug reports
- **GitHub Discussions**: General questions and feature discussions
- **Documentation**: Check existing docs before asking questions
- **Code Review**: Learn from feedback on pull requests

## 🏆 Recognition

Contributors are recognized in several ways:

- **GitHub Contributor Statistics**: Automatic recognition for commits
- **CHANGELOG.md**: Major contributors mentioned in release notes
- **Special Recognition**: Outstanding contributions highlighted in releases
- **Learning Opportunities**: Mentorship and skill development support

## 🎵 Join Us in Improving Piano Practice

Whether you're a developer passionate about music technology, an educator with ideas for better learning tools, or a designer focused on accessible interfaces, Piano Fitness offers opportunities to make a meaningful impact on music education.

**Every contribution, no matter how small, helps students and teachers around the world develop their musical skills more effectively.**

Let's build the future of piano practice together! 🎹✨

*For questions about contributing, please open a GitHub Issue or start a Discussion. We're here to help you get started!*