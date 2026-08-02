# Skill Progression Specification

**Status:** Draft, revision 5  
**Proposed file:** `docs/specifications/skill-progression.md`  
**Scope:** Non-blocking Curriculum page, proficiency heatmap, and reuse of the existing Practice Page  
**Required dependency:** `docs/specifications/exercise-tempo-calculation.md`  

## Related implementation

This feature should extend these existing code paths wherever possible:

- `lib/domain/models/practice/exercise.dart`
- `lib/domain/models/practice/exercise_configuration.dart`
- `lib/domain/models/practice/practice_mode.dart`
- `lib/domain/models/practice/exercise_history_entry.dart`
- `lib/domain/repositories/exercise_history_repository.dart`
- `lib/application/state/exercise_strategy_factory.dart`
- `lib/application/state/practice_session.dart`
- `lib/application/state/practice_runner.dart`
- `lib/presentation/features/practice/practice_page.dart`
- `lib/presentation/features/practice/practice_page_view_model.dart`
- `lib/presentation/features/practice/practice_hub_page.dart`
- `lib/presentation/widgets/practice_settings_panel.dart`
- `lib/presentation/features/history/history_page_view_model.dart`

## 1. Purpose

PianoFitness already supports a flexible set of MIDI-assessable piano exercises. Learners can configure scales, chords, arpeggios, block chords, chord progressions, and dominant cadences, then practise them through a shared Practice Page and exercise runner.

The current system does not show:

- How exercises relate to one another.
- Which techniques commonly prepare a learner for other techniques.
- How proficient a learner is in each exercise across musical keys.
- Which tempo the learner has demonstrated consistently.
- Which areas of technique have received little or no recent practice.

This specification introduces a skill-progression feature that:

1. Organises existing PianoFitness exercises into a navigable technique graph.
2. Describes recommended dependencies and relationships between exercises.
3. Displays proficiency as a positive, graduated heatmap.
4. Evaluates proficiency from repeated historical attempts with sufficient pitch accuracy and, where required, reliable exercise-tempo evidence.
5. Opens selected exercises in the existing Practice Page.
6. Preserves the current practice workflow, runner, history pipeline, and navigation conventions.
7. Allows learners and teachers to traverse the graph freely without hard locks.

The long-term goal is a “periodic table of piano exercises”: a structured catalogue in which MIDI-assessable exercises have stable identities, meaningful neighbours, recommended dependencies, and visible proficiency.

## 2. Minimal-delta design

The Curriculum page is a navigator and progress visualisation. It is not a second practice environment.

```text
Practice Hub
    |
    v
Curriculum
    |
    | Navigator.push(...)
    v
Existing Practice Page
    |
    v
Existing PracticeSession and PracticeRunner
    |
    v
Existing ExerciseHistoryEntry persistence
    |
    v
Reactive history stream
    |
    v
Curriculum heatmap updates
```

The student selects a skill, key, and exercise from the Curriculum page. PianoFitness then opens the existing Practice Page with the corresponding `ExerciseConfiguration`.

The learner may:

- Complete as many repetitions as desired.
- Change settings using the existing Practice Settings panel.
- Revisit a skill that is already proficient.
- Use ordinary back navigation to return to the Curriculum page.
- Enter the same exercises through the Practice Hub or other existing entry points.

Each completed repetition is saved through the existing exercise-history path. The Curriculum page derives proficiency from that history.

No new Practice Runner, alternate exercise session, or duplicate completion workflow should be introduced.

## 3. Required dependency: exercise tempo calculation

Exercise-tempo evidence is defined by:

```text
docs/specifications/exercise-tempo-calculation.md
```

That specification is authoritative for:

- MIDI onset timestamping.
- Inter-onset calculation.
- Exercise BPM calculation.
- Minimum sample requirements.
- Timing-consistency thresholds.
- Tempo reliability classification.
- Tempo fields stored in exercise history.

The skill-progression feature must not independently recalculate, repair, reinterpret, or relax a tempo measurement.

Version 1 of the tempo specification defines:

> One completed `PracticeStep` onset equals one exercise beat.

Therefore, `measuredTempoBpm` is **exercise BPM**: completed step onsets per minute. It is useful for comparing compatible repetitions of the same exercise, but it is not automatically equivalent to conventional quarter-note BPM and must not be compared indiscriminately across unrelated exercise types.

The progression evaluator depends only on this contract:

1. `tempoMeasurementQuality == reliable` means the tempo specification's reliability gates passed.
2. A reliable result has a non-null `measuredTempoBpm`.
3. `insufficientData`, `inconsistent`, and `unavailable` results provide no tempo evidence.
4. `tempoMeasurementVersion` identifies the calculation semantics used by the history entry.
5. Only supported and compatible measurement versions may be aggregated.
6. The configured metronome BPM is never substituted for performed exercise BPM.
7. Unreliable or absent tempo evidence is neutral; it must not reduce existing positive proficiency.

Not every exercise is long enough to satisfy the tempo specification's minimum evidence requirements. In particular, short cadences and chord progressions may always produce `insufficientData` in version 1. Each skill therefore declares whether reliable tempo evidence is required, optional, or not applicable for establishing proficiency.

## 4. Design principles

### 4.1 Reuse the Practice Page

The existing Practice Page remains the only guided MIDI exercise page.

The Curriculum page must launch it rather than reproduce:

- Exercise settings.
- MIDI subscription and coordination.
- Piano highlighting.
- Finger annotations.
- Practice progress.
- Exercise completion feedback.
- Repetition and reset behaviour.
- History persistence.
- Error handling.

### 4.2 Reuse `ExerciseConfiguration`

Each playable leaf in the technique graph resolves to an existing, valid `ExerciseConfiguration`.

The skill catalogue must not introduce another exercise-definition schema containing duplicate fields for mode, key, hand, scale type, chord type, inversion, octave, or progression.

### 4.3 Reuse exercise history

The current history model mirrors the completed `ExerciseConfiguration`. The first version should use that stored configuration to match attempts to catalogue exercises.

The first version should not require skill-node, checkpoint, or catalogue IDs to be added to every history entry.

Explicit skill attribution may be introduced later only if the catalogue needs several semantically different nodes that intentionally share the same configuration.

### 4.4 Dependencies guide rather than lock

A dependency describes a recommended sequence.

It must not prevent a learner from:

- Opening a node.
- Practising an exercise.
- Revisiting a proficient skill.
- Following a teacher’s instruction.
- Exploring a branch out of sequence.

### 4.5 Proficiency replaces binary completion

The primary state is not `locked`, `unlocked`, or `complete`.

Each exercise, key, and node exposes derived proficiency based on repeated historical evidence.

### 4.6 Use positive visual evidence

The heatmap must not use negative colours to label weak performance.

Recommended semantics:

- Neutral: no qualifying accuracy evidence.
- Subtle positive indication: some qualifying accuracy repetitions, but fewer than required.
- Established positive fill: sufficient evidence under the skill's tempo-evidence policy.
- Stronger positive fill: greater compatible exercise-tempo evidence when tempo is part of the skill.
- Full positive fill: the configured reference proficiency has been demonstrated.

Accuracy, repetition counts, and reliable tempo evidence must also be available as text. A skill without reliable tempo evidence must never display a guessed BPM.

### 4.7 Catalogue growth is additive

Adding a new node must not reset or downgrade existing proficiency.

A new node appears neutral until matching evidence exists.

Existing nodes retain their proficiency because it is derived from matching exercise history, not from completing a tier.

## 5. Goals

The system must:

- Represent a versioned catalogue of piano skill nodes.
- Represent recommended dependencies and other relationships.
- Associate each playable graph leaf with an existing `ExerciseConfiguration`.
- Group exercises into checkpoints such as musical keys.
- Match existing history entries to catalogue exercises.
- Derive per-exercise, per-key, and per-node proficiency.
- Require repeated qualifying attempts before showing established proficiency.
- Apply reliable exercise-tempo evidence according to each skill's tempo-evidence policy rather than using the metronome setting.
- Display the catalogue as a freely traversable Curriculum page or grouped skill map.
- Open exercises through the existing Practice Page.
- Preserve existing free-practice and Practice Hub behaviour.
- Allow new catalogue entries without invalidating unrelated progress.
- Allow the catalogue to describe planned technique families as roadmap entries (§13) without requiring an `ExerciseConfiguration`, checkpoints, or proficiency state.

The system should:

- Give learners a clear overview of piano technique.
- Show learners the fuller arc of the pedagogy, including technique families that are planned but not yet practiseable.
- Show how many keys have been practised for each skill.
- Show recent pitch accuracy, repetition count, and reliable exercise tempo when available and applicable.
- Encourage balanced practice across keys and exercise families.
- Suggest sensible next exercises without restricting choice.
- Let teachers direct learners to any exercise.
- Follow existing PianoFitness layout, navigation, accessibility, and state-management conventions.

## 6. Non-goals

The first implementation will not:

- Replace `PracticePage`, `PracticeSession`, or `PracticeRunner`.
- Create a second practice workflow.
- Replace or substantially redesign the existing exercise models.
- Introduce a second exercise-generation system.
- Encode every key, hand, octave, pattern, and tempo combination as a graph node.
- Enforce hard tier locks.
- Treat incomplete dependencies as errors.
- Display punitive or negative proficiency colours.
- Automatically assess subjective musical qualities such as phrasing, expression, tone, or style.
- Verify fingering from ordinary MIDI input.
- Redefine or duplicate the algorithm in `exercise-tempo-calculation.md`.
- Require the complete hypothetical curriculum before release.
- Require explicit skill IDs in exercise history for the first vertical slice.
- Import the TypeScript curriculum directly at runtime.
- Require every family in `docs/curriculum.md` to appear as a roadmap entry — inclusion is a curation choice (§13.6).
- Give a roadmap entry a practice session, checkpoint, or proficiency state.

## 7. Existing practice behaviour to preserve

### 7.1 Runtime exercise representation

`PracticeExercise` and `PracticeStep` remain the generated runtime representation.

The technique graph must not add graph or proficiency state to either model.

### 7.2 Exercise generation

`ExerciseConfiguration` remains the canonical input to `ExerciseStrategyFactory`.

A catalogue exercise must pass `ExerciseConfiguration.validate()`.

A new skill node does not require a new `PracticeMode` when it can be represented by an existing configuration.

### 7.3 Repetition loop

After an exercise is completed, the current `PracticeSession` resets the existing runner when automatic key progression is disabled.

This behaviour already supports the desired workflow:

1. Play the exercise.
2. Receive completion feedback.
3. Begin another repetition of the same exercise.
4. Repeat as many times as desired.
5. Return to the Curriculum page when finished.

The skill feature must not add a separate “next repetition” page or progression dialog.

### 7.4 Completion feedback

The Practice Page’s existing completion overlay should remain the primary immediate feedback.

The first skill-tree release does not need to show progression calculations after every repetition.

Reliable exercise BPM may be added to the existing completion message by `exercise-tempo-calculation.md`; progression calculations remain outside the active Practice Page.

### 7.5 Editable practice settings

Exercises opened from the Curriculum page use the ordinary Practice Settings panel.

The learner may change the key, hand, mode, or other supported settings.

Every completed attempt is matched from the configuration that was actually active at completion. Therefore:

- An unchanged configuration contributes to the originally selected graph cell.
- A changed configuration contributes to another matching graph exercise, if one exists.
- An unmatched configuration remains valid practice history but does not affect the Curriculum page.

No special “skill progression mode” is required.

## 8. Practice Page extension

The Practice Page currently accepts an initial practice mode and an optional chord progression.

Add one optional parameter:

```dart
const PracticePage({
  super.key,
  this.initialMode = PracticeMode.scales,
  this.initialChordProgression,
  this.initialConfiguration,
  this.backTooltip = "Back to Practice Hub",
});
```

```dart
final ExerciseConfiguration? initialConfiguration;
final String backTooltip;
```

### 8.1 Initialisation precedence

When `initialConfiguration` is present:

1. Validate it.
2. Apply it directly to the new `PracticeSession`.
3. Do not derive a replacement configuration from `initialMode`.
4. Ignore or reject an incompatible `initialChordProgression`.

When it is absent, preserve the current mode and chord-progression initialisation behaviour.

Illustrative ViewModel change:

```dart
void initializePracticeSession({
  required ExerciseCompletedCallback onExerciseCompleted,
  required ValueChanged<List<int>> onHighlightedNotesChanged,
  PracticeMode initialMode = PracticeMode.scales,
  ChordProgression? initialChordProgression,
  ExerciseConfiguration? initialConfiguration,
}) {
  // Create the existing PracticeSession.

  if (initialConfiguration != null) {
    initialConfiguration.validate();
    _practiceSession!.updateConfiguration(initialConfiguration);
    return;
  }

  // Preserve the existing initialMode and initialChordProgression path.
}
```

This is the only required Practice Page configuration change for the first vertical slice.

### 8.2 Back navigation

Use the existing app-bar back button and `Navigator.of(context).pop()`.

The Curriculum page pushes the Practice Page onto the existing navigator stack, so popping naturally returns to the same graph position.

Use a source-appropriate tooltip:

```text
Back to Curriculum
```

The page title may remain:

```text
Practice Session
```

No custom return router, callback, or result object is required.

## 9. Curriculum navigation

Follow the existing `PracticeHubPage` convention of using `Navigator.push` with `MaterialPageRoute`.

Illustrative launch:

```dart
Future<void> openSkillExercise(
  BuildContext context,
  SkillExercise exercise,
) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => PracticePage(
        initialConfiguration: exercise.configuration,
        backTooltip: "Back to Curriculum",
      ),
    ),
  );
}
```

The tree does not need a returned completion result because exercise history is already persisted independently.

## 10. Reactive proficiency updates

The Curriculum ViewModel should follow the existing History Page pattern:

1. Resolve the active profile.
2. Subscribe to `watchEntriesForProfile(profileId)`.
3. Recalculate proficiency whenever history changes.
4. Call `notifyListeners()`.
5. Cancel the subscription on disposal.

Because the tree remains underneath the pushed Practice Page, completed repetitions may update its ViewModel while the learner is still practising. When the learner returns, the refreshed heatmap is already available.

The first version should not add a second progress database or require a manual “submit session” action.

## 11. Entry point and UX conventions

### 11.1 Practice Hub entry

Add the Curriculum page to the existing Practice Hub.

Because it is not a `PracticeMode`, represent it as an action card or dedicated section rather than adding an enum value.

Suggested card:

```text
Curriculum
Explore exercises and track proficiency across keys
```

Use the existing `Card`, `ListTile` or `InkWell`, spacing, icons, colour scheme, and stable widget-key conventions already present in the Practice Hub.

### 11.2 First-version tree presentation

The first vertical slice should prefer existing Flutter layout patterns over a bespoke graph canvas.

Acceptable first-version structures include:

- Grouped cards.
- Expandable sections.
- Indented dependency rows.
- A scrollable tree.
- A grid of node cards with simple connecting indicators.

A fully zoomable graph, constellation, or periodic-table layout is a future presentation enhancement.

### 11.3 Node cards

A node card should show:

- Skill name.
- Short description.
- Key coverage, when relevant.
- Positive proficiency indication.
- Recommended prerequisites.
- A clear affordance to open details.

Example:

```text
Major scale, hands apart
7 of 12 keys with established evidence
Recommended before: Major scale, hands together
```

### 11.4 Key-detail view

Opening a key-based node displays all relevant keys.

Each key cell should show:

- Key name.
- Positive proficiency fill.
- Recent qualifying accuracy-attempt count.
- Recent average pitch accuracy.
- Recent average reliable exercise BPM, when compatible evidence exists.
- Historical best reliable exercise BPM, when applicable.
- A neutral tempo status when tempo is optional, unavailable, or insufficient.
- Suggested next tempo, when available.
- A direct practice action.

Reliable-tempo example:

```text
C major
3 qualifying attempts
96% recent accuracy
82 BPM exercise tempo
Practice
```

Short-exercise example:

```text
Dominant cadence in C
3 accurate attempts
Tempo not recorded: exercise too short
Practice
```

### 11.5 Accessibility

Every colour state must have a text or icon equivalent.

The interface must expose:

- `2 of 3 qualifying attempts`.
- `7 of 12 keys`.
- Numeric accuracy.
- Numeric exercise BPM when a reliable value is displayed.
- Accessible labels describing proficiency.
- Minimum touch-target sizes.
- Stable semantic ordering.

The first release should reuse existing accessibility utilities and semantic colour conventions where applicable.

### 11.6 Roadmap cards

A roadmap entry (§13) renders as a visually distinct card grouped alongside the real node cards for its group, so a learner sees the fuller arc of the pedagogy — for example, under "Chord Vocabulary" the real Diatonic Triads and ii–V–I nodes appear next to a roadmap card for "Seventh chords".

A roadmap card:

- Is always visible. It is not hidden, collapsed, or blurred behind a paywall-style tease.
- Carries no navigation action. It is not wrapped in `InkWell`, `GestureDetector`, or any tappable affordance.
- Uses a neutral, muted style distinct from every proficiency state — it is not part of the proficiency colour scale (§18.3) and must not be confused with the "no evidence yet" state of a real, practiseable node.
- Shows an explicit "planned" or "coming soon" label as text, not colour alone.
- Exposes an accessible label that states the entry is planned and not yet available for practice, so a screen-reader user does not treat it as an inert bug (for example, `"Seventh chords, planned, not yet available to practise"`).

## 12. Catalogue model

The following API is illustrative.

```dart
@immutable
class SkillCatalogue {
  const SkillCatalogue({
    required this.id,
    required this.version,
    required this.nodes,
    this.groups = const [],
    this.roadmapEntries = const [],
  });

  final String id;
  final int version;
  final List<SkillNode> nodes;
  final List<SkillGraphGroup> groups;
  final List<SkillRoadmapEntry> roadmapEntries;
}
```

### 12.1 Optional graph groups

Groups are presentation metadata, not progression gates.

```dart
@immutable
class SkillGraphGroup {
  const SkillGraphGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.nodeIds,
    this.displayOrder,
  });

  final String id;
  final String name;
  final String description;
  final List<String> nodeIds;
  final int? displayOrder;
}
```

Examples:

- Scale foundations
- Chord vocabulary
- Arpeggios and patterns
- Progressions and cadences
- Advanced harmony

### 12.2 Skill nodes

```dart
@immutable
class SkillNode {
  const SkillNode({
    required this.id,
    required this.name,
    required this.description,
    required this.checkpoints,
    required this.proficiencyRule,
    this.tempoProgression,
    this.relations = const [],
    this.groupIds = const [],
  });

  final String id;
  final String name;
  final String description;
  final List<SkillCheckpoint> checkpoints;
  final SkillProficiencyRule proficiencyRule;
  final TempoProgression? tempoProgression;
  final List<SkillRelation> relations;
  final List<String> groupIds;
}
```

Node IDs must be stable and globally unique.

Examples:

```text
major-scale-apart
major-scale-together
natural-minor-scale
triad-inversions
i-iv-v-i
dominant-cadence
```

### 12.3 Skill checkpoints

A checkpoint commonly represents a musical key or root.

```dart
@immutable
class SkillCheckpoint {
  const SkillCheckpoint({
    required this.id,
    required this.name,
    required this.exercises,
  });

  final String id;
  final String name;
  final List<SkillExercise> exercises;
}
```

### 12.4 Skill exercises

```dart
@immutable
class SkillExercise {
  const SkillExercise({
    required this.id,
    required this.name,
    required this.configuration,
  });

  final String id;
  final String name;
  final ExerciseConfiguration configuration;
}
```

The `configuration` is the exact value passed to the Practice Page.

## 13. Roadmap entries

### 13.1 Purpose

A `SkillNode` must resolve to a real, playable `SkillCheckpoint`/`SkillExercise` backed by a valid `ExerciseConfiguration` (§12.2, §12.4). That is correct for anything a learner can practise today, but it leaves no way to represent "this technique exists on the roadmap and will be practiseable later." An unimplemented family is simply absent from the tree.

A roadmap entry fills that gap. It is a purely descriptive, additive item that names a planned technique family without promising it is playable. It lets a learner see the fuller arc of the pedagogy — including advanced material well beyond the current catalogue — while every non-goal about hard gating (§6) and about not requiring the complete hypothetical curriculum before release remains true.

Roadmap entries do not change §4.4: dependencies still guide rather than lock, and a roadmap entry is not a dependency gate. It is a signpost.

### 13.2 Roadmap entry model

The following API is illustrative.

```dart
@immutable
class SkillRoadmapEntry {
  const SkillRoadmapEntry({
    required this.id,
    required this.name,
    required this.description,
    this.groupId,
    this.buildsOnNodeId,
  });

  final String id;
  final String name;
  final String description;
  final String? groupId;
  final String? buildsOnNodeId;
}
```

- `id`: stable and globally unique, drawn from the same namespace as `SkillNode.id` (§12.2).
- `name` and `description`: short, learner-facing copy, the same tone as a node card (§11.3).
- `groupId`: optional. When present, it must reference an existing `SkillGraphGroup.id` (§12.1), and the entry renders alongside that group's node cards (§11.6).
- `buildsOnNodeId`: optional. When present, it must reference an existing `SkillNode.id`, expressing "this planned family extends an existing, practiseable node" — the same advisory relationship a `recommendedPrerequisite` relation (§14.1) expresses between two real nodes.

### 13.3 What a roadmap entry is not

A roadmap entry has no configuration to validate. It must not have:

- An `ExerciseConfiguration`.
- A `SkillCheckpoint` or `SkillExercise`.
- A `SkillProficiencyRule` or `TempoEvidencePolicy`.
- Proficiency, coverage, or heatmap state of any kind (§18.3).

`SkillCatalogueValidator` must not run its configuration-identity checks (§15.1, §15.2) against roadmap entries — there is no configuration to check. Validation of a roadmap entry is limited to: non-empty unique `id`, and, when present, `groupId`/`buildsOnNodeId` referencing real catalogue entries.

The proficiency evaluator (§16) must never see roadmap entries. They are excluded from history matching entirely, because they have no configuration for a history entry to match against.

### 13.4 Presentation

See §11.6 for the roadmap card itself. In summary: always visible, never tappable, visually distinct from every proficiency state, and never presented as a locked or broken practice session.

### 13.5 Promotion path

When a roadmap entry's family gets implemented, it becomes an ordinary `SkillNode` with real checkpoints and exercises, and is removed from `roadmapEntries`.

This is non-breaking. Roadmap entries are never referenced by exercise history and never carry proficiency state, so there is nothing to migrate — the new `SkillNode` simply starts out neutral, exactly like any other newly added node (§4.7, §19.1).

### 13.6 Source of roadmap entries

`docs/curriculum.md` is the intended source for what roadmap entries to add over time. It describes a much larger draft pedagogy — 35 sections across 25 suggested top-level families, spanning scales, modes, pentatonic and blues vocabulary, extended and altered chords, progressions, cadences, voice leading, secondary dominants, tritone substitution, modal interchange, classical chromatic harmony, chromatic mediants, Neo-Riemannian transformations, jazz voicings, quartal and quintal harmony, and improvisation and composition challenges.

The roadmap is not required to enumerate all 25 curriculum families. Choosing which planned families to surface, and when, is a curation choice, consistent with the existing non-goal of not requiring the complete hypothetical curriculum before release (§6).

## 14. Relationships

```dart
enum SkillRelationType {
  recommendedPrerequisite,
  variation,
  related,
  appliesIn,
}

@immutable
class SkillRelation {
  const SkillRelation({
    required this.type,
    required this.nodeId,
    this.description,
  });

  final SkillRelationType type;
  final String nodeId;
  final String? description;
}
```

### 14.1 Meanings

- `recommendedPrerequisite`: Commonly prepares the learner for the current node.
- `variation`: Uses closely related musical material or transformation.
- `related`: Meaningfully connected without a clear sequence.
- `appliesIn`: Used within the referenced progression or application exercise.

### 14.2 Behaviour

Relationships may affect:

- Tree layout.
- Explanatory copy.
- Recommendations.
- “Practise this first” suggestions.

Relationships must not affect whether a node can be opened.

## 15. History-to-skill matching

The proficiency evaluator matches an `ExerciseHistoryEntry` to a `SkillExercise` by comparing the completed configuration with the catalogue configuration.

### 15.1 Canonical configuration identity

Add a domain service or value object that creates a canonical identity from:

- `practiceMode`
- `handSelection`
- `key`
- `scaleType`
- `chordType`
- `includeInversions`
- `includeSeventhChords`
- `musicalNote`
- `arpeggioType`
- `arpeggioOctaves`
- `pattern`
- `includeLeftHandRoot`
- `chordProgressionId`

The identity must normalise existing default and nullable representations consistently.

Possible API:

```dart
@immutable
class ExerciseConfigurationIdentity {
  const ExerciseConfigurationIdentity.fromConfiguration(
    ExerciseConfiguration configuration,
  );

  factory ExerciseConfigurationIdentity.fromHistory(
    ExerciseHistoryEntry entry,
  );
}
```

### 15.2 Unique matching rule

Within one active catalogue, one canonical configuration should normally map to one `SkillExercise`.

Catalogue validation should reject duplicate configuration identities unless the duplication is explicitly marked and supported by a later attribution mechanism.

This keeps the first implementation deterministic and avoids new history columns.

### 15.3 Existing history

All compatible existing history may contribute, including attempts launched from:

- The Curriculum page.
- The Practice Hub.
- Quick Start.
- Any other existing route to the Practice Page.

This is a deliberate benefit of configuration-based matching.

History created before tempo measurement may still contribute accuracy evidence for skills whose tempo policy is `optional` or `notApplicable`. It cannot contribute required tempo evidence.

## 16. Proficiency evidence

### 16.1 Tempo-evidence policy

```dart
enum TempoEvidencePolicy {
  required,
  optional,
  notApplicable,
}
```

Meanings:

- `required`: Established proficiency requires attempts that satisfy both the accuracy rule and reliable tempo rule.
- `optional`: Accuracy evidence can establish proficiency. Reliable tempo enriches the result when available.
- `notApplicable`: Tempo is ignored for proficiency in the current catalogue version.

Use `required` only when the generated exercise normally contains enough step onsets and duration to satisfy the exercise-tempo specification.

Short exercises that cannot produce five intervals and two seconds of measured material in one repetition must use `optional` or `notApplicable` until a later specification supports pooled timing evidence across repetitions.

### 16.2 Accuracy-qualifying attempt

A history entry provides accuracy evidence when:

1. Its configuration matches the skill exercise.
2. Its pitch accuracy is at or above the configured threshold.

### 16.3 Tempo-qualifying attempt

A history entry provides tempo evidence when:

1. It provides accuracy evidence.
2. `tempoMeasurementQuality == reliable`.
3. `measuredTempoBpm != null`.
4. `tempoMeasurementVersion` is supported by the active catalogue or evaluator.
5. It meets any configured exercise-specific tempo-band rule.

`insufficientData`, `inconsistent`, and `unavailable` entries never provide tempo evidence.

### 16.4 Progression-qualifying attempt

The policy determines whether an attempt counts toward established proficiency:

- `required`: the attempt must provide both accuracy and tempo evidence.
- `optional`: accuracy evidence is sufficient; tempo evidence is retained separately when available.
- `notApplicable`: accuracy evidence is sufficient and tempo fields are ignored.

### 16.5 Proficiency rule

```dart
@immutable
class SkillProficiencyRule {
  const SkillProficiencyRule({
    this.minimumAccuracy = 90,
    this.evidenceAttemptCount = 3,
    this.tempoEvidencePolicy = TempoEvidencePolicy.required,
    this.supportedTempoMeasurementVersions = const {1},
    this.referenceTempoBpm,
  });

  final double minimumAccuracy;
  final int evidenceAttemptCount;
  final TempoEvidencePolicy tempoEvidencePolicy;
  final Set<int> supportedTempoMeasurementVersions;

  /// Exercise BPM for this skill's compatible PracticeStep semantics.
  final double? referenceTempoBpm;
}
```

The recommended default evidence window is the three most recent progression-qualifying attempts.

Catalogue validation must reject:

- An empty supported-version set when tempo is required.
- A reference BPM when tempo is `notApplicable`.
- A `required` policy when the generated exercise contains fewer than six `PracticeStep` values and therefore cannot produce five inter-onset intervals.

### 16.6 Skill-exercise proficiency

```dart
@immutable
class SkillExerciseProficiency {
  const SkillExerciseProficiency({
    required this.accuracyQualifyingAttemptCount,
    required this.reliableTempoAttemptCount,
    required this.progressionQualifyingAttemptCount,
    required this.recentAverageAccuracy,
    required this.recentAverageMeasuredBpm,
    required this.historicalBestMeasuredBpm,
    required this.hasSufficientAccuracyEvidence,
    required this.hasSufficientTempoEvidence,
    required this.hasEstablishedProficiency,
    required this.positiveScore,
  });

  final int accuracyQualifyingAttemptCount;
  final int reliableTempoAttemptCount;
  final int progressionQualifyingAttemptCount;
  final double? recentAverageAccuracy;
  final double? recentAverageMeasuredBpm;
  final double? historicalBestMeasuredBpm;
  final bool hasSufficientAccuracyEvidence;
  final bool hasSufficientTempoEvidence;
  final bool hasEstablishedProficiency;
  final double positiveScore;
}
```

Interpretation:

- `hasSufficientAccuracyEvidence` is based on the configured accuracy evidence count.
- `hasSufficientTempoEvidence` is based only on reliable, compatible tempo entries.
- `hasEstablishedProficiency` applies the skill's tempo-evidence policy.
- `recentAverageMeasuredBpm` and `historicalBestMeasuredBpm` are null when no compatible reliable tempo evidence exists.

When fewer progression-qualifying attempts exist than required:

- `hasEstablishedProficiency` is false.
- The UI may show partial repetition progress.
- The cell does not appear fully established.

### 16.7 Checkpoint proficiency

A checkpoint aggregates its required skill exercises.

For example, C major hands apart may aggregate:

- C major, left hand.
- C major, right hand.

The detail view must show individual exercise values if they differ materially.

### 16.8 Node proficiency and coverage

A node exposes at least:

- Checkpoint coverage.
- Recent average accuracy.
- Positive proficiency score.
- Recent average reliable exercise tempo only when all aggregated child exercises use compatible step-beat semantics and measurement versions.

Example with compatible tempo evidence:

```text
7 of 12 keys
94% recent qualifying accuracy
76 BPM recent exercise tempo
```

Example without compatible node-level tempo:

```text
7 of 12 keys
94% recent qualifying accuracy
Tempo shown per exercise
```

The heatmap colour is a compact summary. The underlying values remain available.

## 17. Tempo progression

Tempo progression is optional and applies only to a compatible skill exercise or checkpoint, not to a graph tier.

In version 1, BPM means `PracticeStep` onsets per minute. A tempo progression must therefore compare only entries that share:

- The same `SkillExercise`.
- The same canonical `ExerciseConfiguration`.
- The same tempo-measurement version.
- The same interpretation of one step as one exercise beat.

Do not average or rank BPM across unrelated exercise types.

```dart
@immutable
class TempoProgression {
  const TempoProgression({
    required this.incrementBpm,
    this.minimumBpm,
    this.referenceBpm,
  });

  final int incrementBpm;
  final int? minimumBpm;
  final int? referenceBpm;
}
```

A suggested next tempo may be calculated only from reliable compatible tempo evidence:

1. Find the highest exercise-tempo band supported by the required reliable repetitions.
2. Treat that band as the current demonstrated baseline.
3. Add `incrementBpm`.
4. Display the resulting suggestion in the key-detail view.
5. Do not prevent the learner from practising at another tempo.

No next-tempo suggestion is shown when:

- Tempo is `notApplicable`.
- No reliable tempo evidence exists.
- The available history uses incompatible measurement versions.
- The exercise is too short to produce reliable version 1 tempo evidence.

Passing a suggested BPM into the Practice Page is not required for the first vertical slice.

If later added, it should use the existing global metronome state rather than introducing skill-specific tempo controls.

## 18. Heatmap presentation

### 18.1 Positive-only states

Recommended states:

- Neutral: no qualifying accuracy attempts.
- Partial: one or more qualifying attempts, but fewer than required.
- Established: the skill's accuracy and tempo-evidence policy has been satisfied.
- Stronger positive intensity: greater compatible reliable exercise-tempo evidence when tempo is part of the skill.
- Full positive intensity: the configured reference proficiency has been demonstrated.

For `optional` and `notApplicable` skills, established proficiency must remain visually achievable without reliable tempo evidence.

### 18.2 No negative state

An attempt below the threshold remains in history but does not add positive proficiency evidence.

It must not turn a node red or reduce an established historical-best value.

Recent values may change over time, but the UI should distinguish:

- Recent qualifying performance.
- Historical best.
- Coverage.

### 18.3 Roadmap entries are outside the heatmap

A roadmap entry (§13) carries no proficiency and is never part of the heatmap's neutral, partial, established, or full-intensity states.

Its card uses a separate, neutral-but-not-heatmapped visual treatment (§11.6) so it cannot be mistaken for a real node that simply has "no evidence yet."

## 19. Catalogue evolution

### 19.1 Adding nodes

Adding a node is non-destructive.

It appears neutral until matching history exists.

Existing nodes retain their proficiency.

### 19.2 Editing nodes

Display-copy changes do not require migration.

Changing the underlying configuration identity may change which history matches. Such changes require:

- A catalogue version increment.
- A compatibility decision.
- Tests covering the intended migration behaviour.

### 19.3 Removing nodes

Removing a node hides it from the active catalogue but does not delete exercise history.

## 20. Recommended first implementation

Use a small vertical slice of existing practice modes:

1. Major scale, hands apart — tempo `required`.
2. Major scale, hands together — tempo `required`.
3. Natural minor scale — tempo `required`.
4. Major and minor triads — tempo `optional` unless the generated sequence satisfies the minimum timing sample requirements.
5. Triad inversions — tempo `required` only for sufficiently long generated sequences.
6. I-IV-V-I progression — tempo `optional` in version 1.
7. Dominant cadence — tempo `notApplicable` or `optional` in version 1.
8. One-octave major arpeggio — tempo `required`.

The slice should demonstrate:

- A Practice Hub entry.
- Existing `MaterialPageRoute` navigation.
- Exact `ExerciseConfiguration` launch.
- Unlimited repetitions in the existing Practice Page.
- Reactive history updates.
- Configuration-based matching.
- Three-attempt evidence windows with per-skill tempo policies.
- Positive key and node heatmaps.
- Non-blocking dependencies.
- Additive catalogue updates.

The shipped catalogue (version 3) has already grown past this illustrative slice: it also covers the remaining scale modes (dorian, phrygian, lydian, mixolydian, locrian) and the i–vi–iv–v and ii–v–i progressions. See `default_skill_catalogue.dart`.

## 21. Suggested file structure

```text
lib/domain/models/skill_progression/
├── skill_catalogue.dart
├── skill_graph_group.dart
├── skill_node.dart
├── skill_checkpoint.dart
├── skill_exercise.dart
├── skill_relation.dart
├── skill_proficiency_rule.dart
├── tempo_progression.dart
└── skill_proficiency_snapshot.dart

lib/domain/services/skill_progression/
├── exercise_configuration_identity.dart
├── skill_catalogue_validator.dart
├── skill_history_matcher.dart
├── skill_proficiency_evaluator.dart
└── skill_recommender.dart

lib/presentation/features/skill_progression/
├── skill_tree_page.dart
└── skill_tree_page_view_model.dart

lib/infrastructure/skill_progression/
└── default_skill_catalogue.dart
```

No new runner, practice session, practice settings panel, or exercise-history repository is required.

## 22. Incremental delivery plan

### Dependency 0: Exercise tempo calculation

Implement `docs/specifications/exercise-tempo-calculation.md`:

- Record one onset per `PracticeStep` from supported external MIDI input.
- Calculate version 1 exercise BPM and timing statistics.
- Persist `tempoMeasurementQuality`, `measuredTempoBpm`, and `tempoMeasurementVersion` with history.
- Withhold BPM for `insufficientData`, `inconsistent`, and `unavailable` results.
- Complete real-device timing validation before enabling user-facing BPM.

### Increment 1: Catalogue and matching

- Add catalogue models.
- Add a small static Dart catalogue.
- Add canonical configuration identity.
- Validate that catalogue configurations are unique and valid.
- Match existing history to skill exercises.
- Do not change practice execution.

### Increment 2: Practice Page launch

- Add optional `initialConfiguration` to `PracticePage`.
- Apply it through `PracticePageViewModel.initializePracticeSession`.
- Preserve existing mode and chord-progression launch paths.
- Add a source-appropriate back tooltip.
- Add a Curriculum action to `PracticeHubPage`.

### Increment 3: Proficiency evaluation

- Subscribe to the existing reactive history stream.
- Calculate recent accuracy, tempo, and progression-qualifying evidence.
- Apply each skill's `TempoEvidencePolicy`.
- Calculate per-exercise, per-key, and per-node proficiency.
- Retain historical best compatible reliable exercise tempo.
- Add deterministic tests.

### Increment 4: Curriculum UI

- Display grouped nodes without locks.
- Use existing cards, list tiles, spacing, colours, and accessibility conventions.
- Show positive proficiency intensity.
- Show key coverage.
- Add key-detail practice actions.
- Defer a bespoke graph canvas.

### Increment 5: Recommendations

- Suggest recommended prerequisites.
- Suggest coverage gaps.
- Suggest the next tempo only from compatible reliable exercise-tempo evidence.
- Preserve learner and teacher choice.

### Increment 6: Roadmap visibility (optional)

- Add the `SkillRoadmapEntry` model (§13.2) and an optional `roadmapEntries` list to `SkillCatalogue`.
- Extend `SkillCatalogueValidator` to check roadmap-entry id uniqueness and group/node references, without running configuration-identity checks against them (§13.3).
- Curate an initial set of roadmap entries from `docs/curriculum.md` (§13.6).
- Render roadmap cards in the Curriculum page (§11.6).
- Confirm roadmap cards are never tappable and never appear on the proficiency heatmap (§18.3).

## 23. Testing requirements

### 23.1 Practice Page compatibility

- Existing `PracticePage(initialMode: ...)` behaviour remains unchanged.
- Existing chord-progression initialisation remains unchanged.
- `initialConfiguration` applies the exact configuration.
- Invalid initial configurations are rejected.
- The back button pops to the originating page.
- Completion still resets the same exercise for another repetition.
- Practice settings remain editable.
- Every completed repetition still creates an ordinary history entry.

### 23.2 Catalogue tests

- Reject duplicate node IDs.
- Reject missing relationship targets.
- Reject invalid exercise configurations.
- Reject duplicate canonical configuration identities.
- Reject invalid proficiency rules.
- Validate the complete default catalogue.

### 23.3 History matching tests

- Matching configurations contribute to the correct skill exercise.
- Attempts launched from the Practice Hub contribute.
- Attempts launched from the Curriculum page contribute.
- Changed Practice Page settings contribute to the newly matching configuration.
- Unmatched configurations do not affect the tree.
- Accuracy below the threshold does not qualify.
- `reliable` tempo with a supported version contributes tempo evidence.
- `insufficientData`, `inconsistent`, and `unavailable` do not contribute tempo evidence.
- Missing tempo evidence can still contribute accuracy evidence for `optional` and `notApplicable` skills.
- Missing tempo evidence cannot establish proficiency for a `required` skill.
- Incompatible tempo-measurement versions are not aggregated.

### 23.4 Proficiency tests

- Fewer than three progression-qualifying attempts produces partial evidence.
- Three progression-qualifying attempts produces established evidence.
- A `required` skill needs both accuracy and reliable tempo evidence.
- An `optional` skill can establish proficiency from accuracy evidence alone.
- A `notApplicable` skill ignores tempo evidence.
- A short cadence can establish accuracy proficiency without becoming permanently incomplete.
- Recent averages use the configured evidence window.
- Historical best compatible tempo is retained separately.
- An unreliable attempt does not downgrade historical best or established proficiency.
- Node-level BPM is omitted when child exercises are not tempo-compatible.
- Key coverage counts checkpoints with established proficiency.
- Adding a new node does not change existing proficiency.
- Adding a dependency does not lock either node.

### 23.5 Reactive UI tests

- The tree subscribes to active-profile history.
- A newly saved repetition updates proficiency.
- Returning from the Practice Page displays current heatmap values.
- Subscription errors use an existing user-friendly error pattern.
- The subscription is cancelled on disposal.

## 24. Acceptance criteria

The first vertical slice is ready when:

1. Exercise history contains the version 1 tempo fields defined by `exercise-tempo-calculation.md`.
2. The proficiency evaluator consumes the stored tempo quality and does not recalculate timing reliability.
3. PianoFitness contains a validated, versioned skill catalogue.
4. The Practice Hub links to a Curriculum page.
5. The tree opens the existing Practice Page through `MaterialPageRoute`.
6. The Practice Page accepts an exact initial `ExerciseConfiguration`.
7. The learner can complete unlimited repetitions using the existing completion and reset flow.
8. The learner can revisit any node regardless of proficiency.
9. Practice Page settings remain editable.
10. Completed attempts are matched from the actual configuration stored in history.
11. Each skill declares a `TempoEvidencePolicy`.
12. Three progression-qualifying attempts produce a positive key-cell proficiency state.
13. A `required` skill uses only reliable tempo entries with a supported measurement version.
14. An `optional` or `notApplicable` short exercise can establish proficiency without reliable tempo.
15. `insufficientData`, `inconsistent`, and `unavailable` results never appear as measured BPM or tempo evidence.
16. A key detail displays recent accuracy, repetition count, and reliable exercise BPM when available.
17. A key detail uses neutral explanatory text when tempo is unavailable or the exercise is too short.
18. Historical best and next-tempo suggestions use only compatible reliable tempo evidence.
19. Node-level BPM is omitted when aggregated child exercises have incompatible tempo semantics.
20. A node displays coverage such as `7 of 12 keys`.
21. Adding a new node leaves existing proficiency unchanged.
22. An unreliable tempo attempt does not downgrade existing positive proficiency.
23. Existing Practice Hub routes and free practice continue to work.
24. No new Practice Runner or parallel practice workflow is introduced.
25. The UI uses no negative proficiency colour and does not rely on colour alone.
26. Roadmap entries, when present, carry no `ExerciseConfiguration`, checkpoints, or proficiency state, and are never tappable into a practice session (§13.3, §11.6).

## 25. Future extensions

The architecture should permit:

- A richer graph or periodic-table visualisation.
- Multiple curated routes through the same catalogue.
- Tooling to help curate roadmap entries from `docs/curriculum.md` as new families are prioritised.
- Teacher-authored recommendations.
- Placement exercises.
- Spaced review and freshness indicators.
- Adaptive tempo increments.
- Pooled timing evidence for exercises too short to qualify within one repetition.
- Explicit rhythmic profiles such as `stepsPerBeat`.
- Velocity and note-duration proficiency.
- Explicit skill-attribution fields if duplicate configurations become necessary.
- Catalogue authoring in JSON or another external format.
- Progress portability between compatible catalogue versions.
- Recent, best-ever, and long-term trend views.
- Suggested BPM integration through the existing metronome state.

## 26. Summary

The Curriculum page adds organisation and proficiency visualisation without creating a second practice system.

Each playable graph leaf is an ordinary `ExerciseConfiguration`. Selecting it pushes the existing Practice Page using the same navigation convention as the Practice Hub. The learner practises as many repetitions as desired, receives the existing completion feedback, and returns using the ordinary back button.

Every repetition continues through the existing history pipeline. The Curriculum page subscribes to that history and matches attempts by their completed configuration. This allows Curriculum sessions, Practice Hub sessions, Quick Start sessions, and edited Practice Page configurations to contribute through one shared source of truth.

Tempo evidence is consumed exactly as classified by the exercise-tempo specification. Longer exercises may require reliable exercise BPM, while short cadences and progressions can use accuracy-only proficiency until pooled timing evidence is supported. Unreliable timing remains neutral and never becomes a misleading BPM or a negative proficiency signal.

Recommended dependencies guide the learner but never lock the graph. Positive heatmap colours show demonstrated proficiency across keys, while newly added exercises simply appear neutral. This provides the smallest practical implementation delta while supporting the broader “periodic table of piano exercises” vision.

Roadmap entries extend that vision without extending the practice surface: a learner sees the fuller arc of the pedagogy, including advanced families not yet implemented, but every card that opens a practice session still opens a real one.
