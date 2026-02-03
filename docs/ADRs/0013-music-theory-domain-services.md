# ADR-0013: Music Theory Domain Services

**Status:** Accepted

**Date:** 2024-01-01

## Context

Piano Fitness requires extensive music theory knowledge:
- **Scales**: 96 combinations (12 keys × 8 modes: Major, Minor, Dorian, Phrygian, Lydian, Mixolydian, Aeolian, Locrian)
- **Chords**: 144 combinations (12 notes × 4 types × 3 inversions: Major, Minor, Diminished, Augmented)
- **Arpeggios**: Pattern generation for practice
- **Circle of Fifths**: Key relationships and progressions
- **Voice Leading**: Smooth chord transitions

This knowledge must be:
- **Pure** - No framework dependencies
- **Precise** - Mathematical correctness for music theory
- **Reusable** - Shared across multiple features
- **Testable** - Verifiable algorithms

## Decision

Implement music theory as domain services in `lib/domain/services/music_theory/` with zero framework dependencies.

**Services Created (9 total):**

1. **scales.dart** - Scale definitions and generation
2. **chord_builder.dart** - Chord construction logic
3. **arpeggios.dart** - Arpeggio pattern generation
4. **note_utils.dart** - Note conversion and calculations
5. **circle_of_fifths.dart** - Key relationships
6. **chord_inversion_utils.dart** - Inversion algorithms
7. **voice_leading.dart** - Smooth progressions
8. **interval_utils.dart** - Musical intervals
9. **chord_progressions.dart** - Common progressions

**Principles:**

- **Mathematical Precision** - Exact semitone calculations
- **Zero Dependencies** - Pure Dart, no Flutter/packages
- **Immutable** - All operations return new values
- **Comprehensive Testing** - 144 chord + 96 scale test combinations

## Consequences

### Positive

- **Domain Purity** - No framework coupling
- **Reusability** - Services used across features (Play, Practice, Reference)
- **Testability** - Unit tests verify mathematical correctness
- **Maintainability** - Clear separation from UI/infrastructure
- **Extensibility** - Easy to add new music theory concepts

### Negative

- **Learning Curve** - Developers need basic music theory knowledge
- **Complex Algorithms** - Voice leading and inversions are non-trivial

### Neutral

- **Service Organization** - Each music theory concept is separate service
- **Test Coverage** - Comprehensive testing validates correctness

## Related Decisions

- [ADR-0001: Clean Architecture](0001-clean-architecture-three-layers.md) - Domain layer principles
- [ADR-0014: Piano Layout](0014-piano-keyboard-layout-strategy.md) - Uses note calculations

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Domain services: `lib/domain/services/music_theory/`
- Test coverage: `test/domain/services/music_theory/`
- 144 chord test combinations
- 96 scale test combinations
