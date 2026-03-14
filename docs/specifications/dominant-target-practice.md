<!--
  Status: Active
  Created: 2026-03-14
  Last updated: 2026-03-14
-->

# Dominant Target Practice Specification

## Overview

The Dominant Target Practice exercise drills the **authentic cadence** (V→I), the most fundamental harmonic motion in Western tonal music. Students practice playing the dominant chord in each inversion, then resolving it to the target tonic chord. The exercise is framed **destination-first**: the I chord is the labelled target and the V chord is the approach vehicle, reflecting how musicians actually think ("where do I want to land?").

This is the first exercise in a planned "cadence target practice" series. Future exercises will cover plagal (IV→I), deceptive (V→vi), ii–V–I, and tritone substitutions.

## Goals

- **Muscle memory**: Ingrain the V→I resolution across all inversions through repetition.
- **Voice-leading awareness**: Teach students which V inversion leads most smoothly to each I target.
- **Destination-first thinking**: Frame the exercise around the I chord target, not the V chord starting point.
- **Scalability**: Establish a pattern that later cadence exercises can follow.

## Requirements

### Functional Requirements

- The exercise presents V→I pairs for all inversions, organised by I chord target.
- **Triad mode** (default): 3 pairs = 6 steps.
  - Pair 1: V 2nd inversion → I Root position (cadential 6/4 → 5/3)
  - Pair 2: V Root position → I 1st inversion (imperfect authentic cadence)
  - Pair 3: V 1st inversion → I 2nd inversion
- **Seventh chord mode** (toggle): 4 pairs = 8 steps.
  - V becomes `dominant7`; I becomes `major7` (Imaj7).
  - Symmetric inversion mapping: root→root, 1st→1st, 2nd→2nd, 3rd→3rd.
  - V7 and Imaj7 share two common tones, yielding excellent voice leading.
- The exercise works in all 12 major keys.
- Key can auto-progress through the circle of fifths after each completion.
- Hand selection (left, right, both) is respected.
- Each step is `StepType.simultaneous` — the student plays all chord notes together.

### Technical Requirements

- Implemented as a new `PracticeMode.dominantCadence` with a `DominantCadenceStrategy`.
- Uses existing `ExerciseConfiguration.key` and `includeSeventhChords` fields — no new config fields.
- Reuses `ChordBuilder.getChord()` and `ChordInfo.getMidiNotesForHand()` for MIDI generation.
- Voice-leading pairs are hardcoded static constants on the strategy class (not computed dynamically).

## Accessibility

- **Screen reader**: All `CheckboxListTile` controls carry `Semantics` labels describing their purpose.
- **Contrast**: Uses the app's standard theme colours; no custom colour overrides.
- **Touch targets**: Controls follow existing panel layout patterns (≥ 44 dp).
- **Text scaling**: Layout is scroll-based; no fixed heights that would clip text.
- **Reduced motion**: No animations introduced; exercise advancement is instant.

## Design Notes

**Voice-leading pairs (triads)**

The three pairs are chosen from accepted classical voice-leading practice:

| Pair | V approach | I target | Classical name |
|------|-----------|---------|----------------|
| 1 | V 2nd inv | I Root | Cadential 6/4 → 5/3 |
| 2 | V Root | I 1st inv | Imperfect authentic cadence |
| 3 | V 1st inv | I 2nd inv | Approach to 6/4 tonic |

**Voice-leading pairs (seventh chords)**

When `includeSeventhChords = true`, V becomes `dominant7` and I becomes `major7`. The symmetric pairing produces shared common tones in every pair:

| Pair | V7 | Imaj7 | Shared tones (C major example) |
|------|-----|-------|-------------------------------|
| 1 | Root | Root | B held; F→E, D→C step |
| 2 | 1st inv | 1st inv | B and G held; F→E, D→C step |
| 3 | 2nd inv | 2nd inv | G and B held; F→E, D→E step |
| 4 | 3rd inv | 3rd inv | G and B held; F→E, D→C step |

Note: `ChordInversion.third` is valid for Imaj7 (4-note chord) but must never be used with the triad I chord.

**Step metadata**

Each step includes: `chordName`, `rootNote`, `chordType`, `inversion`, `position`, `displayName`, `hand`, `stepRole` (`"dominant"` or `"tonic"`), `pairIndex`.

Display names:
- V step: chord name only (e.g. `"G (2nd inv)"`)
- I step: `"Target: I Root"` / `"Target: I 1st Inv"` / `"Target: I 2nd Inv"` / `"Target: Imaj7 3rd Inv"`

**Key file locations**

```text
lib/domain/models/practice/strategies/dominant_cadence_strategy.dart
lib/domain/models/practice/practice_mode.dart          (dominantCadence enum value)
lib/domain/models/practice/exercise_configuration.dart (validation case)
lib/application/state/practice_session.dart            (_createStrategy, setPracticeMode)
lib/presentation/widgets/practice_settings_panel.dart  (_DominantCadenceSettings widget)
lib/features/practice/practice_hub_page.dart           (hub card)
```

## User Flow

1. Student opens Practice Hub.
2. Student taps the **Dominant Cadence** card in the second row.
3. Practice page opens with Dominant Cadence mode selected.
4. Settings panel shows: key selector, hand selector, auto-progress toggle, "Include 7th Chords" checkbox.
5. Piano highlights the V approach chord notes.
6. Student plays the highlighted V chord.
7. Piano advances to highlight the I target chord, labelled e.g. "Target: I Root".
8. Student plays the I chord.
9. Steps 5–8 repeat for each inversion pair.
10. After the final pair, "Exercise completed!" overlay appears.
11. If auto-progress is on, the key advances to the next key in the circle of fifths.

## Testing Requirements

### Unit Tests

- `DominantCadenceStrategy` generates correct step counts (6 for triads, 8 for sevenths).
- All steps have `StepType.simultaneous`.
- Even-indexed steps have `stepRole == "dominant"`, odd-indexed have `"tonic"`.
- V steps use correct `displayName` (chord name) and I steps use `"Target: …"` display name.
- MIDI notes are correct for C major right hand, pair 1 (V 2nd inv → I Root).
- Left and both hand selections produce correct MIDI notes.
- All 12 keys initialise without error in both triad and seventh modes.
- Exercise metadata contains `exerciseType`, `key`, `handSelection`, `includeSeventhChords`.

### Widget Tests

- "Dominant Cadence" card is visible in the Practice Hub second row.
- "Include 7th Chords (V7→Imaj7)" checkbox appears when mode is `dominantCadence`.
- Checkbox toggle updates the configuration.

## Acceptance Criteria

- [ ] "Dominant Cadence" card appears in the Practice Hub.
- [ ] Tapping the card opens the practice page in `dominantCadence` mode.
- [ ] Triad mode generates exactly 6 steps for any key.
- [ ] Seventh chord mode generates exactly 8 steps for any key.
- [ ] I step display names begin with "Target:" in both modes.
- [ ] Seventh chord V steps have 4 MIDI notes per step; I steps have 4 MIDI notes per step.
- [ ] "Include 7th Chords" checkbox appears in the settings panel for this mode.
- [ ] Auto key progression works (exercise cycles to next key after completion).
- [ ] `flutter analyze` passes with zero issues.
- [ ] All existing and new tests pass.

## Future Enhancements

- **Minor mode support**: Use minor tonic (i) with raised dominant (V) for minor key authentic cadences.
- **Deceptive cadence exercise**: V→vi ("Target Practice: Deceptive Cadence").
- **Plagal cadence exercise**: IV→I ("Target Practice: Plagal Cadence").
- **ii–V–I exercise**: Full jazz turnaround across all inversions.
- **Tritone substitution**: ♭II7→I alongside V7→I for advanced students.
- **Tempo / metronome integration**: Practice cadences in time.
- **Voice-leading display**: Show an on-screen guide highlighting which voices move and by how much.
