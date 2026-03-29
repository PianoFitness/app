<!--
  Status: Active
  Created: 2026-03-29
  Last updated: 2026-03-29
-->

# Practice History Page Specification

## Overview

The Practice History page gives users a simple, scrollable view of their completed exercises. It is the Phase 2 UI milestone of the exercise history feature (see `exercise-history.md`). Each time a user finishes a practice exercise, the event is recorded in the database; this page surfaces those records in reverse-chronological order so users can see what they have been working on.

The design is intentionally minimal for this milestone: a plain timeline of cards, one per entry, with no date grouping, statistics, or filters. Simplicity is the explicit goal — establishing the UI surface now and deferring richer analytics to a later phase (see ADR-0029).

## Goals

- **Surfacing practice activity**: Let users easily browse what they have practiced, when, and with which settings.
- **Habit reinforcement**: Seeing a list of past completions provides lightweight motivation to keep practising.
- **Foundation for analytics**: Establish the page scaffold and ViewModel that later phases extend with statistics and filters without structural rewrites.

## Requirements

### Functional Requirements

- **Display all history entries for the active profile** ordered most-recent first, loaded from `IExerciseHistoryRepository.getEntriesForProfile`.
- **General-purpose entry card**: every entry regardless of practice mode is rendered by the same `HistoryEntryCard` widget. The card must show:
  - Practice mode label (e.g., "Scales", "Chords by Key", "Arpeggios")
  - Exercise parameters formatted as a human-readable description appropriate to the mode (see Design Notes)
  - Hand selection label ("Left Hand", "Right Hand", "Both Hands")
  - Completion timestamp formatted as a readable date and time
- **Loading state**: while the repository call is in flight, show a centered loading indicator.
- **Empty state**: when the profile has no history entries, show a friendly message encouraging the user to complete a practice exercise.
- **Error state**: if loading fails, show a brief error message; do not crash.
- **Profile awareness**: when the active profile changes, the displayed entries must reflect the new profile.

### Out of Scope (Deferred to Phase 3)

- Date-grouped headers or sections
- Aggregate statistics (total count, streaks, most-practiced keys)
- Filtering or sorting controls
- Pull-to-refresh (entries are loaded once at page open)

### Technical Requirements

- Follow the MVVM pattern: `HistoryPage` is a thin `StatelessWidget`; `HistoryPageViewModel` is a `ChangeNotifier` that holds all state (see ADR-0002).
- `HistoryPageViewModel` receives `IUserProfileRepository` and `IExerciseHistoryRepository` via constructor injection (see ADR-0003, ADR-0004).
- The active `profileId` is resolved from `IUserProfileRepository.getActiveProfileId()` inside the ViewModel; it is not passed in from the page.
- The page lives at `lib/presentation/features/history/history_page.dart` and registers as the fifth tab in `MainNavigation` (see ADR-0029).

## Accessibility

- **Screen reader**: Each `HistoryEntryCard` wraps its content in a `Semantics` widget with a `label` that combines the mode description, exercise parameters, hand selection, and completion time — giving screen reader users a single, complete announcement per card.
- **Contrast**: Card content uses `Theme.of(context)` colour tokens; no custom colours are introduced that could fail WCAG AA contrast ratios.
- **Touch targets**: Cards are list items that occupy the full device width; no custom tap targets smaller than 48 dp are used.
- **Text scaling**: Card layout uses `Text` with no fixed heights that would clip at large font sizes.
- **Reduced motion**: The page contains no animations.

## Design Notes

### Entry Card Label Formatting

Each `HistoryEntryCard` holds a single `ExerciseHistoryEntry`. The descriptive line is formatted per `practiceMode`:

| Mode                | Description format                                                                                                  |
| ------------------- | ------------------------------------------------------------------------------------------------------------------- |
| `scales`            | "{key} {scaleType} Scale" — e.g., "C Major Scale", "D♭ Dorian Scale"                                                |
| `chordsByKey`       | "{key} Chords" + ", with 7ths" when `includeSeventhChords` is true — e.g., "G Chords, with 7ths"                    |
| `chordsByType`      | "{chordType} Chords" + ", with inversions" when `includeInversions` is true — e.g., "Minor Chords, with inversions" |
| `arpeggios`         | "{note} {arpeggioType} Arpeggio ({octaves} oct)" — e.g., "A Major Arpeggio (2 oct)"                                 |
| `chordProgressions` | "{key} — {chordProgressionId}" — e.g., "C — I - IV - V"                                                             |
| `dominantCadence`   | "{key} Dominant Cadence" — e.g., "G Dominant Cadence"                                                               |

If a field required for formatting is unexpectedly null, the card falls back to displaying the `practiceMode.name` string rather than throwing.

### ViewModel State Machine

`HistoryPageViewModel` exposes four mutually exclusive states via its properties, which the page maps to four layouts:

| VM state  | `isLoading` | `error`  | `entries` | Page shows                           |
| --------- | ----------- | -------- | --------- | ------------------------------------ |
| Loading   | `true`      | `null`   | `[]`      | Centered `CircularProgressIndicator` |
| Error     | `false`     | non-null | `[]`      | Inline error message                 |
| Empty     | `false`     | `null`   | `[]`      | Empty-state message                  |
| Populated | `false`     | `null`   | non-empty | `ListView` of `HistoryEntryCard`s    |

### Widget Structure

```text
HistoryPage (StatelessWidget + ChangeNotifierProvider)
└── Consumer<HistoryPageViewModel>
    └── Scaffold
        └── SafeArea
            └── [loading | error | empty | ListView]
                    └── HistoryEntryCard (one per entry)
```

## Integration Points

- **Exercise History Data Layer** (`exercise-history.md`): Reads entries via `IExerciseHistoryRepository`; depends on the domain model `ExerciseHistoryEntry`.
- **User Profiles** (`user-profiles.md`): Reads the active profile ID via `IUserProfileRepository.getActiveProfileId()`.
- **Main Navigation** (`lib/presentation/widgets/main_navigation.dart`): Registered as the fifth bottom navigation tab with a history icon; see ADR-0029 for rationale.
- **MVVM pattern** (ADR-0002): Page/ViewModel split follows the established presentation-layer convention.
- **Dependency injection** (ADR-0003): ViewModel is created inside the page's `ChangeNotifierProvider` using `context.read<T>()` to resolve repository dependencies.

## Testing Requirements

- **ViewModel unit tests**: mock `IExerciseHistoryRepository` and `IUserProfileRepository`; verify loading, populated, empty, and error states.
- **Widget tests**: verify all four page states render the expected UI; verify `HistoryEntryCard` displays correct labels for each of the six practice modes.
- **Coverage target**: ≥80% for all new files.

## Acceptance Criteria

- Tapping the History tab shows a reverse-chronological list of the active profile's completed exercises.
- Each card shows the practice mode, exercise description, hand selection, and completion time.
- Completing a practice exercise while the History tab is in the `IndexedStack` and then returning to it shows the new entry (entries reload when the ViewModel is (re)created by the page).
- The empty state is shown when no history exists for the active profile.
- The loading indicator is visible during initial data fetch.
- All new ViewModel and widget tests pass; no new analyzer warnings or errors are introduced by changed files (pre-existing info-level hints in unmodified files are exempt).
