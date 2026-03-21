# Practice Feature — Refactor Backlog

Tracked issues with the `PracticePageViewModel` and its layer dependencies.
Work these in order: lowest risk first, `scales.dart` last.

---

## 1. Move `ChordType` / `ChordTypeDisplay` / `ChordInversion` to `domain/models/music/`

**Why:** Enum types buried in `chord_definitions.dart` (part of the `chords.dart`
barrel). ViewModels and pages import the full barrel when they only need the enums.

**Scope:** 18 files import `chords.dart`; update presentation-layer callers to
import `domain/models/music/chord_type.dart` directly.

---

## 2. Move `ScaleType` / `Key` / `KeyDisplay` to `domain/models/music/`

**Why:** Enums and a display extension defined in `scales.dart` alongside `Scale`
and `ScaleDefinitions` service classes.

**Scope:** 15 files import `scales.dart`. Do this last — `Key` is the most
widely referenced type in the music theory layer and carries the highest
mechanical update cost.

---

## 3. Introduce `MidiCoordinator` in the application layer

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
