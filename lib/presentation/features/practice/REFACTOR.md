# Practice Feature — Refactor Backlog

Tracked issues with the `PracticePageViewModel` and its layer dependencies.
Work these in order: lowest risk first, `scales.dart` last.

---

## 1. Move `MidiEvent` / `MidiEventType` to `domain/models/midi/`

**Why:** Both types are pure data — `MidiEvent` is an immutable value object,
`MidiEventType` is an enum. They are defined inside `midi_service.dart`, causing
ViewModels to import a domain service just to name the type.
`domain/models/midi/` already exists (empty).

**Scope:** 5 files import `midi_service.dart` for these types.

---

## 2. Move `ArpeggioType` / `ArpeggioOctaves` to `domain/models/music/`

**Why:** Both are plain enums — no behaviour. Defined in `arpeggios.dart`
alongside service logic (`Arpeggio`, `ArpeggioDefinitions`), causing ViewModel
to import the service file for the types only.

**Scope:** 5 files import `arpeggios.dart`.

---

## 3. Move `ChordType` / `ChordTypeDisplay` / `ChordInversion` to `domain/models/music/`

**Why:** Same pattern — enum types buried in `chord_definitions.dart` (part of
the `chords.dart` barrel). ViewModels and pages import the full barrel when they
only need the enums.

**Scope:** 10 files import `chords.dart`.

---

## 4. Move `ScaleType` / `Key` / `KeyDisplay` to `domain/models/music/`

**Why:** Same pattern — enums and a display extension defined in `scales.dart`
alongside `Scale` and `ScaleDefinitions` service classes.

**Scope:** 15 files import `scales.dart`. Do this last — `Key` is the most
widely referenced type in the music theory layer and carries the highest
mechanical update cost.

---

## 5. Introduce `MidiCoordinator` in the application layer

**Why:** All four MIDI-receiving ViewModels (`PracticePageViewModel`,
`PlayPageViewModel`, `ReferencePageViewModel`, `DeviceControllerViewModel`)
directly import `IMidiRepository` solely to register and unregister a raw-data
handler in their constructor and `dispose()`. This is an infrastructure
lifecycle concern that belongs in the application layer.

A `MidiCoordinator` (or `MidiEventSubscription`) would:
- Own `registerDataHandler` / `unregisterDataHandler` against the repository
- Delegate parsing to `MidiDataHandler.dispatch()`
- Return a cancellable subscription so ViewModels call `_subscription.cancel()`
  in `dispose()` without holding a repository reference

**Scope:** New class + updates to 4 ViewModels and their 4 page-level provider
sites (where `IMidiRepository` is injected).

---

## Non-issues (kept as-is)

- Domain **model** imports (`PracticeMode`, `ExerciseConfiguration`,
  `HandSelection`, `ChordProgression`) in the ViewModel are correct — a
  ViewModel may reference domain models as parameter types.
- `MidiState` and `PracticeSession` application-layer imports are correct.
