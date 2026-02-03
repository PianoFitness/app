# ADR-0016: Accessibility Modular Architecture

**Status:** Accepted

**Date:** 2024-01-01

## Context

Piano Fitness must support users with diverse accessibility needs:

- **Visual Impairments** - Screen reader support, high contrast, large text
- **Motor Impairments** - Switch control, voice control, assistive touch
- **Cognitive Disabilities** - Simplified UI, clear instructions
- **Platform Standards** - WCAG 2.1 AA compliance

**Challenge:** Accessibility is cross-cutting concern affecting all features, but shouldn't be tightly coupled to prevent maintenance burden.

## Decision

Implement **modular accessibility architecture** with centralized utilities and feature-specific integrations.

**Architecture:**

```
lib/
├── presentation/
│   └── shared/
│       └── accessibility/            # Shared accessibility utilities
│           ├── semantic_labels.dart   # Label constants
│           ├── screen_reader.dart     # Announcements
│           └── contrast_utils.dart    # Color contrast helpers
└── features/
    ├── play/
    │   └── accessibility/             # Feature-specific integrations
    │       └── play_page_accessibility.dart
    ├── practice/
    │   └── accessibility/
    │       └── practice_page_accessibility.dart
    └── ...
```

**Principles:**

1. **Semantic Labels** - Consistent across features
2. **Announcements** - Screen reader context changes
3. **Keyboard Navigation** - Focus management
4. **Color Contrast** - WCAG 2.1 AA (4.5:1 for text)
5. **Touch Targets** - Minimum 44×44pt (iOS HIG, Material 48×48dp)

**Implementation Example:**
```dart
// Shared utility
class SemanticLabels {
  static const String playNote = "Play note";
  static const String stopNote = "Stop note";
  static const String connectMidi = "Connect MIDI device";
}

// Feature-specific integration
Semantics(
  label: SemanticLabels.playNote,
  hint: "Tap to hear note $noteName",
  onTap: () => playNote(),
  child: PianoKey(...),
)
```

**WCAG 2.1 AA Compliance:**
- Text contrast: ≥4.5:1 (normal), ≥3:1 (large)
- Interactive elements: ≥3:1 against background
- Touch targets: ≥44×44pt (iOS), ≥48×48dp (Android)

## Consequences

### Positive

- **Modularity** - Accessibility organized per feature
- **Reusability** - Shared utilities prevent duplication
- **Discoverability** - Clear directory structure
- **Testability** - Widget tests verify semantic properties
- **Compliance** - WCAG 2.1 AA standards met

### Negative

- **Additional Structure** - Requires feature-specific directories
- **Developer Awareness** - Must remember accessibility requirements

### Neutral

- **Manual Testing** - Screen reader testing requires physical devices
- **Platform Differences** - iOS VoiceOver vs Android TalkBack

## Related Decisions

- [ADR-0001: Clean Architecture](0001-clean-architecture-three-layers.md) - Presentation layer organization
- [ADR-0014: Piano Layout](0014-piano-keyboard-layout-strategy.md) - Piano keyboard accessibility
- [ADR-0022: Platform Support](0022-platform-support-strategy.md) - Cross-platform considerations

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Shared utilities: `lib/presentation/shared/accessibility/`
- Feature integrations: `lib/features/*/accessibility/`
- WCAG 2.1 AA color contrast ratios enforced
- Touch target sizes per platform guidelines
