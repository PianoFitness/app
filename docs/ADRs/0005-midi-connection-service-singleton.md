# ADR-0005: MidiConnectionService as Internal Singleton

**Status:** Accepted

**Date:** 2026-02-03

## Context

During Phase 2 dependency injection refactoring, we needed to decide how to handle `MidiConnectionService`, which was implemented as a singleton.

**Hardware Reality:**
- Piano Fitness connects to **one MIDI device at a time**
- MIDI connection is a system-level resource
- Multiple instances would cause resource conflicts

**Options Considered:**

1. **Eliminate Singleton** - Refactor to instance-based service
   - Risk: Complex refactoring with high chance of bugs
   - Benefit: Pure dependency injection throughout
   
2. **Expose Singleton via Repository** - Repository returns singleton instance
   - Risk: Singleton pattern leaks through abstraction
   - Benefit: Minimal changes, clean external interface
   
3. **Wrap Singleton in Repository** - Repository creates singleton internally
   - Risk: Repository lifetime differs from service lifetime
   - Benefit: Singleton hidden from consumers, proper abstraction boundary

## Decision

Keep `MidiConnectionService` as an internal singleton within `MidiRepositoryImpl`. The repository wraps the singleton without exposing it to consumers.

**Implementation:**

```dart
class MidiRepositoryImpl implements IMidiRepository {
  MidiRepositoryImpl() : _service = MidiConnectionService();
  
  final MidiConnectionService _service; // Singleton internally
  
  // Repository methods delegate to singleton
}
```

**Rationale:**

- **Hardware Justification** - Only one MIDI device exists, singleton appropriate
- **Boundary Isolation** - Provider manages repository lifetime, not service lifetime
- **Lower Risk** - Avoids risky refactoring of working singleton pattern
- **Proper Abstraction** - External code depends on IMidiRepository interface, not singleton

## Consequences

### Positive

- **Low Risk** - No changes to proven MidiConnectionService implementation
- **Proper Abstraction** - Singleton hidden behind repository interface
- **Hardware Alignment** - Pattern matches hardware reality (one device)
- **Fast Implementation** - Minimal code changes required

### Negative

- **Hidden Singleton** - Singleton pattern still exists, just wrapped
- **Lifetime Mismatch** - Repository created/destroyed, singleton persists

### Neutral

- **Provider Pattern** - Provider still manages repository as if instance-based
- **Testing** - Tests mock IMidiRepository, unaware of internal singleton

## Related Decisions

- [ADR-0004: Repository Pattern](0004-repository-pattern-external-dependencies.md) - Repository abstraction strategy
- [ADR-0006: Global MIDI State](0006-global-midi-state.md) - Complementary MIDI state management
- [ADR-0015: MIDI Message Processing](0015-midi-message-processing.md) - MIDI processing architecture

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- MidiConnectionService singleton: `lib/application/services/midi/midi_connection_service.dart`
- Repository wrapper: `lib/application/repositories/midi_repository_impl.dart`
- Original decision documented: `REFACTOR_DI.md` "ADR-001"
