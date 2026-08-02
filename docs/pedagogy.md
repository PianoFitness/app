# PianoFitness Pedagogy: How We Teach

This document describes PianoFitness's teaching philosophy — the principles behind how exercise
families are ordered, labelled, and presented. For the ordered inventory of exercise families
themselves — what to teach and in what order — see [`curriculum.md`](curriculum.md).

## 1. Non-gating exploration

No concept or technique is gated behind a barrier. A learner can explore any family in the
curriculum at their own interest, while still being able to see the progression leading up to
more advanced concepts.

In the app, this is implemented directly: every node in the Curriculum is always tappable,
prerequisites are advisory (`recommendedPrerequisite` relations) rather than locks, and
proficiency is positive-only — a node never shows as locked or red, only as "no evidence yet"
through to "established." Families that exist in this document but are not yet implemented as
practiseable exercises can still appear as inert "roadmap" cards, so a learner sees the fuller
arc of the pedagogy without anything being hidden or blocked. See
`docs/specifications/skill-progression.md` §4.4 and §13 for the implementation of this principle.

## 2. Categories versus variations

A curriculum family names a musical capability — for example "major and minor scales" or
"foundational triads." After selecting a family, the learner explores applicable variations:

- All 12 keys
- Left hand, right hand, hands together
- Root position and inversions
- Ascending, descending, and combined directions
- One or more octaves
- Increasing tempo
- Repeated accurate and rhythmically consistent performances

Not every dimension applies to every family — cadences, for instance, have no meaningful "octave
range" variation. Keeping this distinction explicit prevents the family list from ballooning with
what are really just variations on a smaller set of core capabilities.

## 3. Developmental priority labels

Each family in `curriculum.md` carries one of four priority labels. These communicate typical
pedagogical order without creating a locked tier — every family remains freely explorable
regardless of its label, consistent with §1.

- **Foundation** — the first stops; most learners benefit from starting here.
- **Developing** — builds directly on foundation material; the typical next step.
- **Advanced** — deeper technical or harmonic vocabulary, usually pursued once foundation and
  developing material feels comfortable.
- **Exploratory** — theoretically or stylistically specialized; valuable but not on a typical
  linear path, and in some cases still under theoretical review (see §5).

## 4. Exercise-type labels

Not everything in the curriculum can be assessed the same way. Each family is labelled with one
of:

- **Technique exercise** — deterministically assessable via MIDI: scales, chords, arpeggios,
  progressions, voicing sequences. PianoFitness can objectively check pitch, timing, and accuracy.
- **Musical application** — guided use of technique in a musical context: improvisation,
  accompaniment, reharmonization, melody harmonization. PianoFitness can prompt and structure
  these but cannot fully auto-assess musicality.
- **Creative challenge** — open-ended creative work such as composition or building original
  progressions. Structured but not scored.
- **Listening or analysis study** — reflective or analytical work: recording review, harmonic
  analysis, transcription. Not something PianoFitness assesses directly.

Labelling each family this way keeps the curriculum from implying automated assessment of
inherently subjective musical work.

## 5. Handling theoretically unsettled material

Some draft pedagogy entries are exploratory, self-correcting, or not yet independently verified
against source theory. Rather than presenting these as settled teaching material,
`curriculum.md` quarantines them in a "Topics requiring pedagogical or theoretical review"
appendix until they are reviewed and either promoted into a regular family or removed.

## 6. Family documentation template

Where a family has enough distinct content to warrant it, `curriculum.md` documents it with a
short **Connections** note pointing to what it builds on and what it typically leads toward, in
addition to its exercise list. The goal is a connected learning map rather than an unconnected
encyclopedia of exercises.

## 7. Relationship to the Curriculum feature

The in-app Curriculum (`docs/specifications/skill-progression.md`) implements §1's non-gating
principle directly. The priority and exercise-type labels in this document are curation input for
deciding which families become real, practiseable nodes versus roadmap entries — they are not
currently modelled as fields in the app's data model.
