# Device Controller Feature — Refactor Backlog

Tracked layer-boundary issues in `DeviceControllerPage` and `DeviceControllerViewModel`.
Work in order: lowest risk and highest independence first.

---

~~## 1. Add CC / PC / pitch-bend methods to `IMidiRepository`~~ ✓ Done

~~## 2. Move `MidiService.getPitchBendValue` out of the ViewModel~~ ✓ Done

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
