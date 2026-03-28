# Architecture

Piano Fitness follows **Clean Architecture** with three strictly ordered layers. Dependencies flow inward only: Presentation → Application → Domain.

---

## Layers

### Domain (`lib/domain/`)

The innermost layer. Contains pure business logic with no external dependencies — no Flutter, no I/O, no infrastructure packages.

**Allowed imports:** `dart:*` core libraries, pure Dart packages with no transitive Flutter dependency (e.g. `package:meta`, `package:collection`), and other `lib/domain/*` files.

**Prohibited imports:** `lib/application/*`, `lib/presentation/*`, any Flutter or infrastructure package.

> To verify a new package is safe for the domain layer: `dart pub deps | grep flutter`. Empty output → acceptable. Non-empty → belongs in application layer.

Contains:

- **`models/`** — Value objects and domain entities (e.g. `MidiNote`, `MidiChannel`, `ChordType`, `ScaleType`)
- **`services/`** — Pure functions with no external dependencies. Two sub-areas:
  - **`music_theory/`** — Scale/chord generation, note utilities, circle of fifths, voice leading
  - **`midi/`** — Protocol-level MIDI message parsing (`midi_service.dart`): converts raw `Uint8List` bytes into typed `MidiEvent` objects. Uses only `dart:typed_data` and domain models — no I/O, no Flutter
- **`repositories/`** — Interface contracts (e.g. `IMidiRepository`) implemented in the application layer
- **`constants/`** — Domain-level constants (musical theory, practice)

### Application (`lib/application/`)

Orchestrates domain services, repository implementations, and cross-cutting infrastructure concerns.

**Allowed imports:** `lib/domain/*`, Flutter framework, and infrastructure packages.

**Prohibited imports:** `lib/presentation/*`.

Contains:

- **`repositories/`** — Concrete repository implementations (e.g. `MidiRepositoryImpl`)
- **`services/`** — Infrastructure integrations that require Flutter or platform packages. Includes `midi/` for MIDI device connection (`midi_connection_service.dart`) and device discovery (`midi_device_discovery_service_impl.dart`). Distinct from `domain/services/midi/` which handles pure protocol parsing
- **`state/`** — Global `ChangeNotifier` state shared across features (e.g. `MidiState`, `PracticeSession`)
- **`utils/`** — Application-layer utilities and adapters (e.g. `MidiDataHandler`, `PianoNoteBridge`, `VirtualPianoUtils`)
- **`database/`** — Drift ORM configuration and schema management

### Presentation (`lib/presentation/`)

The outermost layer. UI widgets and ViewModels. May import from all layers.

Contains:

- **`features/`** — MVVM feature modules (one directory per feature)
- **`widgets/`** — Shared UI components used across features
- **`theme/`** — Material theme configuration and semantic colour extensions
- **`constants/`** — UI constants (`Spacing`, `ResponsiveBreakpoints`, `AppBorderRadius`, etc.)
- **`utils/`** — Presentation utilities (piano range calculation, accessibility helpers)
- **`accessibility/`** — Semantic label constants and accessible widget wrappers

---

## MVVM Pattern

Each feature in `lib/presentation/features/<feature>/` follows a consistent structure:

```text
feature_page.dart          # Thin StatelessWidget — creates ChangeNotifierProvider, renders _FeatureView
feature_page_view_model.dart  # ChangeNotifier — all feature business logic and state
```

**Page responsibilities:**

- Creates the `ChangeNotifierProvider` with the ViewModel, injecting dependencies via `context.read<T>()`
- Delegates all UI building to a private `_FeatureView` `StatelessWidget`
- Contains no business logic

**ViewModel responsibilities:**

- Extends `ChangeNotifier`
- Coordinates application-layer state and services
- Exposes immutable getters; calls `notifyListeners()` after state changes
- Disposes all subscriptions and handlers in `dispose()`

**View responsibilities:**

- Reads ViewModel via `context.watch<FeaturePageViewModel>()` or `Consumer`
- Handles user interaction by delegating to ViewModel methods
- No business logic — only layout, styling, and user interaction

---

## Key Patterns

### Repository Interface

Interfaces are defined in `domain/repositories/` and implemented in `application/repositories/`. ViewModels receive the interface type via constructor injection; tests use mock implementations.

```dart
// Domain: interface contract
abstract class IMidiRepository {
  Future<void> sendNoteOn(int note, int velocity, int channel);
  void registerDataHandler(void Function(Uint8List) handler);
  void unregisterDataHandler(void Function(Uint8List) handler);
}

// Application: concrete implementation
class MidiRepositoryImpl implements IMidiRepository { ... }

// Presentation: ViewModel receives interface
class PlayPageViewModel extends ChangeNotifier {
  PlayPageViewModel({required IMidiRepository midiRepository}) ...
}
```

### Value Objects

Domain value objects enforce invariants at construction time, preventing invalid state from propagating. Follow the `MidiNote` / `MidiChannel` pattern: constructor guard, `validate()` static helper, `isValid()` predicate.

```dart
class MidiNote {
  static const int min = 0;
  static const int max = 127;

  MidiNote(this.value) {
    if (value < min || value > max) throw RangeError(...);
  }

  static int validate(int note) { ... }  // returns note or throws
  static bool isValid(int note) => note >= min && note <= max;
}
```

### Bridge / Adapter

When a Flutter widget package introduces its own type system for a concept the domain already models, a bridge in `lib/application/utils/` converts between the two. This keeps domain types pure and the conversion logic centralised and testable.

**Example:** `PianoNoteBridge` converts between domain `MusicalNote`/MIDI integers and `package:piano`'s `NotePosition`.

Add a bridge when:

- Multiple sites need the same conversion between a domain type and a Flutter package type
- The conversion is non-trivial

Do **not** implement a Flutter package's interface directly on a domain type — that would import Flutter into the domain layer.

### Re-export for Backward Compatibility

When a type is extracted from a service file into `domain/models/`, the service file re-exports it so existing callers are not broken:

```dart
// domain/services/music_theory/scales.dart
import "package:piano_fitness/domain/models/music/scale_types.dart";
export "package:piano_fitness/domain/models/music/scale_types.dart";
```

New code should import the model file directly; only files that also use the service class need the service import.

### MIDI Subscriptions via `MidiCoordinator`

ViewModels that receive MIDI input subscribe through `MidiCoordinator` (in `application/utils/`), not directly against `IMidiRepository`. `MidiCoordinator.subscribe()` owns `registerDataHandler`/`unregisterDataHandler` lifecycle, delegates raw byte → `MidiEvent` parsing to `MidiDataHandler.dispatch()`, and returns a `MidiSubscription` that is cancelled in `dispose()`. ViewModels only implement the feature-specific switch over `MidiEventType`.

---

## Accepted Import Patterns

These patterns may appear to violate layer boundaries at first glance but are explicitly correct:

- **Domain models in ViewModels** — `PracticeMode`, `ExerciseConfiguration`, `HandSelection`, `ChordProgression`, `MidiChannel`, `MidiDevice`, and similar value objects are domain model types. ViewModels may use them as parameter and return types without violating clean architecture.
- **Domain constants in ViewModels** — `MidiProtocol` and similar domain-layer constants are acceptable in ViewModels, e.g. for validation guards on user input. This is not a domain service call — it is reading a constant.
- **Domain repository interfaces in ViewModels** — `IMidiRepository` in a ViewModel is correct. ViewModels depend on interfaces, not on infrastructure implementations.
- **Application state in ViewModels** — `MidiState`, `PracticeSession`, and other `ChangeNotifier` state objects live in `application/state/` and are expected ViewModel dependencies.
- **Presentation utilities in Views** — `isWhiteKey`/`isBlackKey` from `presentation/utils/piano_key_utils.dart` and similar helpers belong in the view class, not the ViewModel.

---

## Architecture Enforcement

### Pre-commit Hook

`scripts/check-layer-boundaries.sh` (configured via `lefthook.yml`) runs automatically on commits that touch `lib/domain/` or `lib/application/`. It scans for forbidden cross-layer imports and explains violations with remediation guidance.

Run manually:

```bash
./scripts/check-layer-boundaries.sh
```

### Static Analysis

`analysis_options.yaml` enforces strict type checking. Layer dependency rules are documented inline.

---

## Further Reading

- [Architecture Decision Records](docs/ADRs/README.md) — rationale behind specific architectural choices
- [ADR-003: Repository Pattern](docs/ADRs/003-repository-pattern-implementation.md)
- [ADR-005: Dependency Injection Strategy](docs/ADRs/005-dependency-injection-strategy.md)
- [Clean Architecture — Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Dependency Inversion Principle](https://en.wikipedia.org/wiki/Dependency_inversion_principle)
