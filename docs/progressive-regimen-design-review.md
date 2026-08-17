# Progressive Regimen Design Review

> Status: proposed direction. Reviewed August 2026.

This review is grounded in the current Curriculum UI and ViewModel, skill
catalogue and proficiency evaluator, Progress UI and ViewModel, exercise
history presentation, pedagogy, and skill-progression specification.

## Decision summary

Piano Fitness should combine two systems that ordinary workout apps usually do
not need to combine:

1. **A capability path** that introduces musical ideas in a useful conceptual
   order. Foundational triads prepare the learner for seventh chords; seventh
   chords prepare the learner for richer progressions and voicings.
2. **A maintenance loop** that returns established capabilities through spaced
   practice so deeper learning does not rest on eroding foundations.

The default Curriculum experience should turn those systems into a small,
concrete plan for today. A useful initial prescription is three roles rather
than three arbitrary exercises:

| Plan role | Purpose | Example |
| --- | --- | --- |
| Review | Shore up an established capability that is due for practice. | Major scales in less-recently practised keys |
| Build | Continue the learner's active edge of development. | Foundational triads, hands together |
| Advance | Introduce a deeper concept for which the learner is ready. | Seventh chords after sufficient triad fluency |

An optional **Apply** step can connect the day's training to improvisation,
repertoire, composition, or accompaniment. It may be prompted and timed without
being objectively scored.

This gives each session a stable pedagogical shape:

```text
established foundation due for review
                 +
current capability still being developed
                 +
newly ready concept that moves the learner deeper
                 =
             today's practice
```

The plan is assembled from curriculum relationships and practice history. It
should be deterministic enough to feel intentional, explainable enough to earn
trust, and editable enough to preserve learner and teacher agency.

## How piano progression differs from progressive load

The fitness model remains useful for reps, form, recovery, and progressive
challenge, but it is incomplete by itself. Strength exercises can often develop
in parallel. Musical knowledge is more structurally dependent: some
capabilities make later material intelligible and playable.

Piano Fitness therefore needs to track two independent dimensions:

| Dimension | Learner question | Product behavior |
| --- | --- | --- |
| Depth or readiness | What am I prepared to learn next? | Follow advisory relationships through the curriculum graph. |
| Freshness or maintenance | What should I revisit now? | Schedule established capabilities from recency and performance history. |

These must not be collapsed into one completion score. A skill can be deeply
established but due for review. Another can be freshly practised but still at
an early developmental stage.

Missing a review must not erase proficiency or turn a skill red. Freshness is a
scheduling signal, not a punishment or claim that the learner has forgotten.

## Review of the current Curriculum page

### What works

- The catalogue already represents stable skills, checkpoints, exercise
  configurations, and advisory relationships.
- Recommended prerequisites guide without locking exploration.
- Proficiency derives reactively from ordinary exercise history, so practice
  from different entry points contributes to one model.
- Exercise detail supports repeated attempts, key coverage, accuracy evidence,
  and compatible measured tempo.
- Suggested tempo progression already exists in the domain layer.

These are strong foundations for a regimen. The product does not need a second
exercise runner or a second history pipeline.

### Primary usability gap: the page still asks the learner to programme practice

The Curriculum currently leads with the most recently practised exercise when
one exists, then presents the full grouped catalogue. Its instruction is
“Choose a skill and practice it across keys.” This answers what is available,
but not what the learner should do today.

Repeating only the most recent exercise can reinforce an arbitrary choice. It
does not balance maintenance, current development, and forward movement.

**Recommendation:** Replace the single **Continue** card with a compact
**Today's practice** plan. Keep the complete catalogue below it as a secondary
path for exploration, substitution, and teacher direction.

### Progress language implies a finite checklist

Node cards currently use language such as “3 of 12 keys complete,” while detail
pages show a bounded progress bar. This is useful for initial coverage but can
imply that the technique is finished once every checkpoint is established.

**Recommendation:** Separate coverage from training state:

- **Coverage:** 3 of 12 keys established.
- **Current phase:** Building consistency, increasing tempo, or maintaining.
- **Freshness:** Practised recently, due soon, or ready to revisit.

The checkmark may mean “established at this level,” but the action must remain
visibly available and the exercise must be eligible for future plans.

### Relationships are descriptive rather than operational

The catalogue can say **Recommended first: Major scale**, but the system does
not yet use relationship readiness to choose the learner's next concept.

**Recommendation:** Treat relationships as inputs to recommendation, not hard
gates. A concept becomes **ready to introduce** when its recommended foundations
have enough relevant coverage or proficiency. The learner may still open it
earlier, and a teacher may place it into the plan explicitly.

## Review of the current Progress and History page

### What works

- The page makes recorded practice visible and trustworthy.
- Every attempt preserves exercise configuration, time, accuracy, and tempo
  information when available.
- The reverse-chronological list is useful for audit and reflection.
- The data stream is already sufficient to derive recency for matched
  curriculum exercises.

### Primary usability gap: history is a ledger, not a training signal

The top summary shows total practices, active days, and best-ever accuracy,
followed by a flat Recent activity list. Those measures acknowledge effort but
do not answer:

- Which foundations are becoming stale?
- What capability is actively improving?
- What is the learner ready to study next?
- Is practice balanced across keys and capability families?

Best-ever accuracy is especially weak as a headline metric: one successful
attempt can dominate indefinitely and says little about current development.

**Recommendation:** Keep the event log, but place a capability-oriented summary
above it:

```text
Progress

Ready to revisit       Major scales · 4 keys due
Currently building     Foundational triads · 7 of 12 keys established
Ready to explore       Seventh chords · builds on foundational triads

Recent development
Tempo steadier in major scales · 68 → 76 BPM

Recent activity
…chronological records…
```

Progress explains the system's understanding; Curriculum turns that
understanding into today's action. The same recommendation engine should power
both surfaces so they never contradict each other.

## Proposed recommendation mechanics

### 1. Derive a training state for every exercise

Keep historical proficiency and current scheduling state separate. Derive at
least:

- last matching practice date;
- last qualifying practice date;
- number of recent qualifying repetitions;
- current accuracy and compatible working tempo;
- established coverage and current development phase;
- freshness: new, current, due soon, or due;
- next appropriate challenge, when one can be calculated safely; and
- relationship readiness for deeper nodes.

Most of this can be computed from the existing catalogue and history. Do not
store a second mutable proficiency record unless performance or portability
requires it.

### 2. Use spaced review as a scheduling policy

A simple first policy is preferable to false scientific precision. After an
exercise becomes established, schedule increasingly spaced reviews—for
example, after roughly 2, 7, 21, and 45 days. A strong review can extend the
interval; difficulty or inconsistent form can shorten it.

The exact intervals are a product hypothesis and should be configurable rather
than embedded throughout the UI. Physical coordination, conceptual recall, and
different learner levels may eventually need different policies.

Spaced review should operate at the smallest useful curriculum identity. For
example, the system can bring back under-practised keys or hand combinations
instead of prescribing all 12 keys every time.

### 3. Compose the daily plan by role

For a default three-item plan:

1. **Review candidate:** choose the most useful due foundation, considering
   overdue amount, foundational importance, weak coverage, and recent plan
   repetition.
2. **Build candidate:** choose an unfinished active skill or coverage gap near
   the learner's present level.
3. **Advance candidate:** choose a not-yet-established node whose recommended
   foundations are sufficiently ready.

If no safe Advance candidate exists, use a second Build or Review item. For a
new learner with no history, use a curated foundation starter plan. For a short
session, reduce the number or dose of items before removing all maintenance.

Selection should be scored and constrained, not purely randomized. Useful
inputs include:

- prerequisite readiness;
- review due date and time since last practice;
- accuracy and tempo consistency;
- missing keys, hands, or variations;
- recent repetition of the same exercise in generated plans;
- balance across scales, chords, coordination, and other curriculum families;
- learner level, available time, focus, and teacher assignments; and
- physical load, so one session does not overwork the same movement pattern.

Randomness can break ties or add variety, but it should not override
pedagogical readiness or overdue maintenance.

### 4. Prescribe a dose, not just an exercise name

Each plan item needs:

- role: Review, Build, Advance, or Apply;
- exact configuration or bounded sequence of configurations;
- reps or sets;
- working BPM or another challenge parameter when reliable;
- one form or listening cue;
- a short reason such as **Due for review**, **Continue building**, or **Ready
  because foundational triads are established**; and
- an estimated duration.

This is what converts a recommendation into something the learner can sit down
and do without further planning.

### 5. Keep the daily plan stable and editable

Generating a different plan every time the page rebuilds will make the system
feel arbitrary. Generate or restore one plan for the practice day and update it
as items are performed.

Allow the learner to:

- start or resume the plan;
- replace an item while preserving its role when possible;
- shorten or extend the session;
- explain **Why this?**;
- follow a teacher-authored item;
- skip without penalty; and
- leave for free play or the full catalogue.

The plan should track today's completion separately from long-term skill state.

## Proposed page hierarchy

### Curriculum

1. **Today's practice** — the primary action and three-role prescription.
2. **Up next** — one visible deeper capability and why it is becoming ready.
3. **Your path** — compact capability groups with coverage, phase, and
   freshness.
4. **All exercises** — the freely explorable catalogue.

The first screenful should contain enough information to start practising. The
learner should not have to scan the catalogue or interpret a heatmap first.

### Progress

1. **Training status** — due foundations, active development, and next-ready
   concept.
2. **Development over time** — trends in meaningful comparable measures, not
   isolated best-ever values.
3. **Balance** — where practice has concentrated and what has received little
   recent attention.
4. **Recent activity** — the existing chronological record, retained as detail.

Avoid a dense analytics dashboard. Every summary should either explain a
recommendation or help the learner reflect on development.

## Accessibility and trust

- Expose Review, Build, Advance, freshness, and item status in text and
  semantics; color may reinforce but never carry those meanings alone.
- Keep the plan in a predictable reading and focus order that matches its
  performance order.
- Give Start, Replace, Skip, **Why this?**, and per-exercise actions full touch
  targets and contextual semantic labels.
- Preserve readable layouts under text scaling; dose, BPM, and rationale must
  wrap rather than disappear.
- Announce plan changes without unexpectedly moving keyboard or screen-reader
  focus.
- Explain recommendations in learner-facing language. Do not expose internal
  readiness scores, scheduling weights, or evidence terminology.
- Do not present overdue reviews as failures. Avoid warning colors, lost
  streaks, or language that creates anxiety around returning after a break.

## Domain additions

The existing catalogue relationships, proficiency evaluator, and history
matcher should remain sources of truth. Add a recommendation layer rather than
placing scheduling logic in either page ViewModel.

Suggested concepts:

```text
SkillTrainingState
  proficiency
  coverage
  freshness
  relationshipReadiness
  currentChallenge

DailyPracticePlan
  date
  estimatedDuration
  items[]

DailyPracticePlanItem
  role
  exerciseConfiguration(s)
  prescribedReps
  prescribedChallenge
  focusCue
  rationale
  status

PracticePlanComposer
  compose(catalogue, history, learnerContext, planPolicy)
```

Persist the generated plan or make generation stable for the day. Persist
explicit edits and item status. Continue saving every performed rep through the
existing exercise-history path.

## Delivery recommendation

### Phase 1: useful plan from existing evidence

- Add freshness and last-practised derivation.
- Compose a stable three-role daily plan from the current catalogue and history.
- Use fixed, configurable review intervals.
- Show **Today's practice** above the Curriculum catalogue.
- Support Start, Resume, Replace, Skip, and **Why this?**.
- Replace permanent completion wording with coverage, phase, and freshness.

### Phase 2: make Progress explanatory

- Add Ready to revisit, Currently building, and Ready to explore summaries.
- Replace best-ever accuracy as a headline with comparable recent development.
- Add skill-level drill-down while retaining the event log.
- Show when a recommendation changed because of new practice.

### Phase 3: adapt the regimen

- Adjust review intervals and dose from observed performance.
- Balance curriculum families and physical movement patterns across sessions.
- Add learner focus, available-time controls, and teacher-authored priorities.
- Add optional musical application finishers.
- Evaluate recommendation quality before adding more elaborate gamification.

## Validation criteria

The direction is working when:

- a returning learner can begin an appropriate session from Curriculum without
  choosing exercises manually;
- each plan normally contains both maintenance and forward development;
- the learner can understand why every item was selected;
- an established foundation returns when due without appearing to lose earned
  proficiency;
- newly recommended concepts follow intelligible curriculum relationships;
- completing today's plan does not imply permanent completion of its skills;
- Curriculum and Progress describe the same current training state; and
- the learner can override the recommendation without friction or punishment.

## Open product questions

- What should the default session length and number of exercises be for each
  learner level?
- Should review intervals differ for physical technique, harmonic vocabulary,
  and conceptual recall?
- What level of prerequisite coverage is enough to make a deeper node ready?
- Should an Advance item introduce one new concept, one new key, or either?
- How should a teacher assignment replace or rebalance the generated roles?
- Which application prompts are valuable even when Piano Fitness cannot score
  them objectively?
- Which signals best represent form beyond pitch accuracy and tempo
  consistency with the MIDI data currently available?
