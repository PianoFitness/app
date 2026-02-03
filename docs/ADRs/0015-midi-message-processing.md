# ADR-0015: MIDI Message Processing

**Status:** Accepted

**Date:** 2024-01-01

## Context

MIDI devices send various message types:

- **Note Events** - Note On (0x90-0x9F), Note Off (0x80-0x8F)
- **Control Change** - CC messages (0xB0-0xBF)
- **Program Change** - Instrument selection (0xC0-0xCF)
- **Pitch Bend** - Pitch wheel (0xE0-0xEF)
- **System Real-Time** - Beat clock (0xF8), Active Sense (0xFE)

**Challenge:** System real-time messages (clock, active sense) flood the stream with 24+ messages per second, overwhelming UI updates and logs.

## Decision

Implement **MIDI message filtering and parsing** in domain service layer.

**Domain Service: MidiService**

Location: `lib/domain/services/midi/midi_service.dart`

**Responsibilities:**
1. **Parse raw MIDI bytes** to structured MidiEvent objects
2. **Filter system messages** - Ignores 0xF8 (clock), 0xFE (active sense)
3. **Validate message structure** - Ensures correct byte counts
4. **Type safety** - Returns strongly-typed events (NoteOn, NoteOff, ControlChange, etc.)

**MidiEvent Hierarchy:**
```dart
sealed class MidiEvent {}

class NoteOnEvent extends MidiEvent {
  final int note, velocity, channel;
}

class NoteOffEvent extends MidiEvent {
  final int note, velocity, channel;
}

class ControlChangeEvent extends MidiEvent {
  final int controller, value, channel;
}

class ProgramChangeEvent extends MidiEvent {
  final int program, channel;
}

class PitchBendEvent extends MidiEvent {
  final int value, channel;
}
```

**Filtering Logic:**
```dart
// Ignore system real-time messages
if (statusByte == 0xF8 || statusByte == 0xFE) return null;

// Parse valid messages
switch (statusByte & 0xF0) {
  case 0x90: return NoteOnEvent(...);
  case 0x80: return NoteOffEvent(...);
  // ...
}
```

## Consequences

### Positive

- **Clean UI** - No clock/active sense spam in logs or state
- **Type Safety** - Sealed classes prevent invalid message types
- **Testable** - Pure parsing logic with comprehensive tests
- **Domain Purity** - No flutter_midi_command dependency
- **Performance** - Filter reduces unnecessary processing

### Negative

- **Additional Layer** - Adds parsing overhead (minimal)
- **Message Loss** - Filtering could hide important diagnostic info (mitigated by debug logs)

### Neutral

- **Event-Based** - Uses Dart sealed classes for pattern matching

## Related Decisions

- [ADR-0001: Clean Architecture](0001-clean-architecture-three-layers.md) - Domain service principles
- [ADR-0005: MidiConnectionService Singleton](0005-midi-connection-service-singleton.md) - Service integration
- [ADR-0006: Global MIDI State](0006-global-midi-state.md) - Consumes parsed events

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Domain service: `lib/domain/services/midi/midi_service.dart`
- Test coverage: `test/domain/services/midi/midi_service_test.dart`
- Used by ViewModels to process MIDI data
- Filters 24+ clock messages per second
