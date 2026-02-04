# ADR-0014: Piano Keyboard Layout Strategy

**Status:** Accepted

**Date:** 2024-01-01

## Context

Piano Fitness displays interactive piano keyboards across multiple features (PlayPage, PracticePage). Requirements:

- **Consistent Experience** - Similar feel across features
- **iPad Optimized** - Proper key proportions on larger screens
- **No Horizontal Scrolling** - All exercise notes visible
- **Practice Focused** - Keyboard centered on current exercise
- **Responsive** - Adapts to all screen sizes

Initial implementation had inconsistent ranges and required scrolling during practice exercises.

## Decision

Implement **49-key fixed and dynamic layouts** with 20% screen height allocation.

**PlayPage - Fixed Range:**
- **Range:** C2 to C6 (exactly 49 keys spanning 4 octaves)
- **Purpose:** Consistent general piano interaction
- **Implementation:** `lib/features/play/play_page_view_model.dart` - `getFixed49KeyRange()`

**PracticePage - Dynamic Centering:**
- **Range:** 49 keys centered on current exercise
- **Algorithm:**
  1. Find min/max notes in exercise
  2. Calculate center point
  3. Create 49-key range (24 semitones each side)
  4. Shift if needed to include all notes
  5. Clamp to A0..C8 bounds
- **Implementation:** `lib/features/practice/practice_page_view_model.dart` - `calculatePracticeRange()`
- **Utility:** `lib/presentation/utils/piano_range_utils.dart`

**Screen Layout:**
- **Content:** 80% (flex: 4) - Settings, instructions, controls
- **Piano:** 20% (flex: 1) - Interactive keyboard

**Key Width Calculation:**
```dart
final availableWidth = screenWidth - 32; // padding
final dynamicKeyWidth = availableWidth / 29; // 29 white keys
keyWidth: dynamicKeyWidth.clamp(20.0, 60.0)
```

## Consequences

### Positive

- **No Scrolling** - All exercise notes visible in PracticePage
- **Optimal Proportions** - 20% screen height improves key size on iPad
- **Consistent UX** - 49-key constraint across features
- **Responsive** - Adapts to all screen sizes
- **Practice Optimized** - Dynamic centering eliminates navigation

### Negative

- **49-Key Limit** - Exercise sequences must fit within 4-octave range
- **Algorithm Complexity** - Dynamic centering requires calculation

### Neutral

- **Two Strategies** - Fixed (PlayPage) vs Dynamic (PracticePage)

## Related Decisions

- [ADR-0002: MVVM Pattern](0002-mvvm-presentation-pattern.md) - ViewModel handles range calculation
- [ADR-0013: Music Theory](0013-music-theory-domain-services.md) - Uses note utilities
- [ADR-0016: Accessibility](0016-accessibility-modular-architecture.md) - Piano keyboard accessibility

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- PlayPage ViewModel: `lib/features/play/play_page_view_model.dart`
- PracticePage ViewModel: `lib/features/practice/practice_page_view_model.dart`
- Range utilities: `lib/presentation/utils/piano_range_utils.dart`
- Piano component: `package:piano` (third-party)
