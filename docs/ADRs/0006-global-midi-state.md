# ADR-0006: Global MIDI State

**Status:** Accepted

**Date:** 2026-02-03

## Context

Before Phase 2 refactoring, MIDI state was managed inconsistently:
- 4 ViewModels created local `MidiState()` instances
- Each ViewModel maintained separate MIDI state
- State could diverge between features (e.g., selected channel mismatch)
- No single source of truth for MIDI device state

**Hardware Reality:**
- Piano Fitness connects to **one MIDI device**
- Device state (active notes, selected channel, connection status) is global
- All features operate on the same MIDI device

**Problems with Local State:**
- State inconsistency between PlayPage, PracticePage, ReferencePage, DeviceControllerPage
- Duplicate MIDI message processing logic
- Difficult to coordinate cross-feature behavior
- Confused user experience when features show different state

## Decision

Migrate all ViewModels to a single shared global `MidiState` instance registered as `ChangeNotifierProvider<MidiState>` at app root.

**Implementation:**

1. **Single Registration** in `main.dart`:
   ```dart
   ChangeNotifierProvider<MidiState>(
     create: (_) => MidiState(),
   )
   ```

2. **Constructor Injection** - All ViewModels receive shared instance:
   ```dart
   class PlayPageViewModel extends ChangeNotifier {
     PlayPageViewModel({required MidiState midiState})
       : _midiState = midiState;
   }
   ```

3. **Remove Local Instances** - Eliminated `MidiState()` from 4 ViewModels

**Migration Approach:**
- All-at-once migration (not incremental)
- Ensures consistency across all features immediately

## Consequences

### Positive

- **Single Source of Truth** - One MidiState reflects hardware reality
- **State Consistency** - All features see same MIDI device state
- **Simplified Logic** - No duplicate state management code
- **Better UX** - Consistent MIDI state across all features
- **Cross-Feature Coordination** - Features can react to shared MIDI events

### Negative

- **Global State** - All ViewModels share state (intentional for MIDI)
- **Coupling** - Features coupled to MidiState structure

### Neutral

- **ChangeNotifier Pattern** - Uses standard Flutter reactive pattern
- **Provider Scope** - Registered at app root, available everywhere

## Related Decisions

- [ADR-0002: MVVM Pattern](0002-mvvm-presentation-pattern.md) - ViewModel architecture
- [ADR-0003: Provider DI](0003-provider-dependency-injection.md) - How MidiState is injected
- [ADR-0005: MidiConnectionService Singleton](0005-midi-connection-service-singleton.md) - Complementary singleton pattern
- [ADR-0015: MIDI Message Processing](0015-midi-message-processing.md) - What state MidiState manages

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- MidiState implementation: `lib/application/state/midi_state.dart`
- Provider registration: `lib/main.dart` MultiProvider
- ViewModel injection: All 7 ViewModels receive shared MidiState
- Original decision: `REFACTOR_DI.md` "ADR-002"
