# Device Controller Feature — Refactor Backlog

Tracked layer-boundary issues in `DeviceControllerPage` and `DeviceControllerViewModel`.
Work in order: lowest risk and highest independence first.

---

## 1. Add CC / PC / pitch-bend methods to `IMidiRepository`

**Why:** `sendControlChange()`, `sendProgramChange()`, and `sendPitchBend()` in the
ViewModel construct `CCMessage`, `PCMessage`, and `PitchBendMessage` from
`flutter_midi_command` directly and call `.send()`, bypassing `IMidiRepository` entirely.
This couples the ViewModel to an infrastructure package and makes these operations
untestable via mock repositories.

**Fix:** Add three methods to `IMidiRepository` and implement them in `MidiRepositoryImpl`:

```dart
Future<void> sendControlChange(int controller, int value, int channel);
Future<void> sendProgramChange(int program, int channel);
Future<void> sendPitchBend(double bend, int channel);
```

The ViewModel then delegates to the repository and no longer imports
`flutter_midi_command_messages.dart`.

**Scope:** `domain/repositories/midi_repository.dart`,
`application/repositories/midi_repository_impl.dart`,
`device_controller_view_model.dart`. Tests: update ViewModel tests to assert
the mock repository is called; add repository impl tests for the new methods.

---

## 2. Move `MidiService.getPitchBendValue` out of the ViewModel

**Why:** `_processMidiEvent` calls `MidiService.getPitchBendValue(data1, data2)` directly
in the ViewModel. Domain service calls from ViewModels should go through the application
layer. `MidiEvent` already carries `data1` and `data2`, so this pure conversion can be
exposed on `MidiEvent` itself (e.g. a `pitchBendValue` getter computed from those fields),
keeping the domain service out of the ViewModel entirely.

**Fix:** Add a `double get pitchBendValue` getter to `MidiEvent` in
`domain/models/midi/midi_event.dart`, implemented using the same two-byte conversion
formula currently in `MidiService.getPitchBendValue`. Remove the direct `MidiService`
import from the ViewModel.

**Scope:** `domain/models/midi/midi_event.dart`,
`domain/services/midi/midi_service.dart` (keep as re-export or remove if unused),
`device_controller_view_model.dart`.

---

## 3. Move note-label derivation out of the View

**Why:** `_buildDevicePianoKey` calls `NoteUtils.getCompactNoteName(midiNote)` directly
in the view, importing a domain service into the presentation layer's view class. Display
string derivation belongs in the ViewModel.

**Fix:** Add a `String getNoteLabel(int midiNote)` method (or equivalent) to
`DeviceControllerViewModel`. The view calls `viewModel.getNoteLabel(midiNote)` and drops
its `note_utils.dart` import.

**Scope:** `device_controller_view_model.dart`, `device_controller_page.dart`.

---

## 4. Expose slider bounds through the ViewModel

**Why:** The view imports `MidiProtocol` domain constants directly to set slider `min`/`max`
values (`controllerMax`, `programMax`, `pitchBendNormalizedMin`). Domain constants used
purely for UI configuration should be surfaced via the ViewModel, keeping domain imports
out of the view.

**Fix:** Add `static const` getters or a constants object on `DeviceControllerViewModel`
that re-exposes the relevant bounds. The view reads them from the ViewModel and drops
its `midi_protocol_constants.dart` import.

**Scope:** `device_controller_view_model.dart`, `device_controller_page.dart`.

---

## Non-issues

See [ARCHITECTURE.md — Accepted Import Patterns](../../../../ARCHITECTURE.md#accepted-import-patterns) for documented acceptable patterns that apply here.
