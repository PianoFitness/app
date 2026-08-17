# Piano Fitness Product Design Direction

> Status: active, living guidance. Last updated August 2026.

This guide describes how Piano Fitness should feel and gives contributors a
shared vocabulary for making design decisions. It is intentionally practical:
use it when designing a page, reviewing a pull request, or deciding whether a
piece of information belongs on screen.

The detailed review of prerequisite-driven progression, spaced maintenance,
and daily-plan mechanics lives in
[`progressive-regimen-design-review.md`](progressive-regimen-design-review.md).

The current reference implementation is the compact Curriculum exercise-detail
page in
[`skill_tree_page.dart`](../lib/presentation/features/skill_progression/skill_tree_page.dart).
It is a direction to extend, not a template every page must copy literally.

## North star

**Piano Fitness is an ongoing training regimen for musicians. It removes the
uncertainty at the start of practice, prescribes useful work for today, and
develops the capabilities that make creative piano playing possible.**

The fitness metaphor is the product model, not merely the visual theme. A
musician does not finish scales any more than an athlete finishes strength or
mobility work. Foundational exercises remain useful as the learner becomes more
capable; the challenge, dosage, variation, and reason for practising them
evolve.

Technique is supporting work rather than the final destination. Piano Fitness
develops fluency, coordination, time, touch, harmonic vocabulary, and physical
ease so that the learner is better prepared for repertoire, improvisation,
composition, accompaniment, and playing with other musicians. The app should
make the training itself satisfying without confusing exercise performance
with musical fulfilment.

The interface should help a learner answer three questions quickly:

1. What exactly should I practise today?
2. What should I focus on during each exercise?
3. How is repeated practice developing my capabilities over time?

It should not feel like an admin dashboard, analytics console, or collection of
nested control panels. The student is there to play piano; the interface should
make that action feel easy to begin.

## The training model

Piano Fitness should translate the useful structure of physical training into
musical practice:

| Fitness concept | Piano Fitness meaning |
| --- | --- |
| Exercise | A repeatable musical movement or pattern, such as a major scale through all 12 keys. |
| Rep | One intentional performance of an exercise. |
| Set | A useful group of repetitions with a shared focus. |
| Weight | The challenge applied to the exercise, most visibly tempo in BPM. |
| Form | Accuracy, rhythmic consistency, fingering, coordination, evenness, touch, and physical ease. |
| Progression | More secure reps, greater range, more keys, coordinated hands, a higher tempo, or a harder variation without sacrificing form. |
| Recovery | Rest within a session and spacing between sessions so practice remains sustainable. |
| Training history | Evidence used to choose the next useful dose, not a ledger of tasks crossed off. |

The analogy is directional rather than literal. BPM is often the clearest
equivalent of weight, but faster is not always better. The app must preserve
form as the constraint: increase tempo or complexity only when the learner can
do so with sufficient control.

### A recurring regimen, not a finite course

Exercises cycle through development states instead of moving from incomplete
to permanently complete:

- **Learning** — understand the movement slowly and accurately.
- **Building consistency** — accumulate controlled repetitions across the
  relevant keys, hands, or variations.
- **Increasing challenge** — add tempo, range, coordination, rhythmic variety,
  or another appropriate load.
- **Maintaining** — revisit an established capability often enough to retain
  it.
- **Applying** — connect the trained capability to repertoire, improvisation,
  composition, or accompaniment.

For example, practising a major scale in all 12 keys three times may establish
an initial level of consistency; it does not finish major scales. The same
exercise can return with a different tempo, hand combination, articulation,
range, rhythm, key order, or musical application. Progress indicators should
describe the learner's current training state and demonstrated capability, not
imply that a foundational skill has been disposed of forever.

### The daily promise

When a learner sits down at the piano, Piano Fitness should remove planning
friction. The default experience presents a bounded plan for today with:

- the exercises to perform and their order;
- the intended number of reps or sets;
- an appropriate BPM or other challenge level when known;
- one concise form cue or musical focus;
- clear transitions, rests, and an achievable stopping point; and
- enough explanation to understand why the work is in today's plan.

The plan should adapt from training history and remain editable. A learner may
replace an exercise, explore the catalogue, follow a teacher's direction, or
move into free play without being punished. Guidance removes uncertainty; it
does not remove agency.

## Experience qualities

| Quality | What it means in practice |
| --- | --- |
| Calm | Neutral surfaces, limited decoration, and no competing highlights. |
| Focused | One obvious primary task per screen or section, with no uncertainty about what to do next. |
| Encouraging | Progress is framed positively; incomplete work is an invitation, not a warning. |
| Engaging | Repetition has responsive feedback, visible development, and enough variation to remain purposeful without becoming distracting. |
| Efficient | Repeated actions are compact, scannable, and close to the content they affect. |
| Warm | Plain language, soft shapes, and restrained color keep the product approachable. |
| Trustworthy | Metrics are shown only when meaningful and never padded with technical placeholders. |

When qualities compete, prioritize clarity and usability over visual novelty.

## Core principles

### 1. Practice is the primary action

The most prominent elements should help the student start or continue
today's practice. Supporting statistics, explanations, and configuration should
not compete with that action. On the default repeat-use path, the learner
should not have to assemble a session from the full exercise catalogue before
playing.

- Lead with **Today's practice** and one clear **Start** or **Continue** action.
- Put practice choices near the exercise name.
- Use clear action labels such as **Left**, **Right**, **Together**, or
  **Practice**.
- Keep configuration that is not needed for the immediate choice behind a
  secondary interaction.

### 2. Develop capabilities, not completion

The interface must not present the curriculum as a one-and-done checklist.
Recorded reps can complete today's prescribed set, but they do not permanently
complete the underlying technique.

- Use **Today's reps complete** for a finished daily dose, not **Exercise
  complete** for an enduring capability.
- Describe longer-term states with language such as **Learning**, **Building
  consistency**, **Increasing tempo**, **Maintaining**, or **Ready for a new
  variation**.
- Keep established exercises available and intentionally return them to future
  plans.
- Celebrate consistency, control, and useful increases in challenge—not simply
  the disappearance of unfinished items.
- Show how technique supports musical applications where that connection is
  known.

### 3. Show progress, not accounting

Progress should be understandable at a glance. Prefer a small visual signifier
over a sentence that makes the student interpret the tracking system.

- Use dots, rings, bars, or checkmarks for repeated progress.
- Provide the exact value through semantics or a tooltip when the visual is
  intentionally compact.
- Use learner-facing language such as **keys practised**, **reps today**,
  **working tempo**, or **last trained**.
- Avoid internal terms such as **evidence**, **qualifying attempt**,
  **established proficiency**, or **measurement version** in the interface.

### 4. Make repetition engaging

Repetition is the work, so each rep should feel responsive and purposeful.
Feedback should help the learner make the next attempt better rather than
merely award completion.

- Give immediate, restrained feedback on accuracy, rhythm, and tempo when the
  system can measure them reliably.
- State one useful focus at a time, such as **Keep the left hand even** or
  **Repeat at 72 BPM**.
- Make the current rep, remaining dose, and next transition easy to understand
  without turning practice into a scoreboard.
- Introduce variation and challenge progressively; do not rely on novelty,
  streak anxiety, points, or punitive mechanics to manufacture engagement.
- Let a satisfying final rep close today's set while preserving a clear path
  back to the exercise in future sessions.

### 5. Use progressive disclosure

Show information when it becomes useful.

- Do not show “tempo unavailable” or an empty metric field. Show BPM whenever
  the attempt has enough timing data to calculate an average; keep the stricter
  reliability classification internal to proficiency decisions.
- Pair History BPM with a compact tempo-consistency marker: a straight line for
  steady tempo, an equalizer for mostly steady, a wave for varied tempo, and a
  timer for a short sample. Derive the band at runtime from stored timing
  statistics. Use a tooltip and semantic label to explain the marker and expose
  the exact variation percentage; color only reinforces it.
- Do not repeat explanatory text on every row.
- Put detailed history and analysis on a dedicated progress or history view,
  not inside the action picker.

### 6. Prefer one visual layer

Repeated borders, panels inside panels, and many equal-weight controls create a
command-console effect. Most sections should need only one containing surface.

- Repeated list rows use a quiet tonal surface and usually no elevation.
- Related actions may sit inside that row as soft tonal pills.
- Avoid placing outlined buttons inside outlined cards.
- Avoid borders when spacing, background tone, or typography already expresses
  the grouping.

### 7. Density and breathing room are partners

Compact does not mean cramped. Remove low-value content first, then use a
consistent spacing rhythm.

- Keep repeated rows low-profile so more of the practice plan is visible.
- Preserve at least a 44 logical-pixel touch target.
- Use whitespace between groups; do not add a container merely to create
  separation.
- Cap content width on large screens so controls do not stretch into long,
  sparse strips.

### 8. Design every state together

Default, in-progress, today's dose completed, established, maintaining,
unavailable, hover, focus, and pressed states belong to the same component
design. Do not design only the empty state.

- Default state: neutral and clearly interactive.
- In progress: a restrained secondary tint or partially filled indicator.
- Today's dose completed: a primary tint plus a non-color signifier such as a
  checkmark or filled rep marks.
- Established or maintaining: positive capability status that remains clearly
  available for practice.
- Unavailable: explain why and how to proceed; do not merely gray out an action.

### 9. Keep global navigation global

A student should never need to retrace a workflow simply to reach another
part of the app or correct their setup.

- Keep the application menu and metronome available on section, detail, and
  practice screens.
- Use **Back** to return within the current workflow; use the application menu
  to move directly to another section.
- Put profile switching, MIDI setup, notifications, and other app-wide tools
  in the same predictable menu at every route depth.
- Selecting a primary section starts from that section's root instead of
  preserving an invisible stack of detail pages underneath it.
- Avoid stacking page-specific app bars beneath the application app bar.

## Product information architecture

The primary navigation expresses learner intent, not the application's internal
feature map:

| Destination | Learner question | Primary content |
| --- | --- | --- |
| Curriculum | What am I practising today? | Today's regimen first; exercise catalogue and substitutions second |
| Piano | Can I play or look this up? | Free play and visual reference on one piano surface |
| Progress | How is my practice adding up? | Summary first, recent activity second |

Use **learn, play, review** as a quick test for new top-level destinations. A
new page should usually be contextual or live in the global application menu
unless it represents a distinct, frequent learner intent that does not fit one
of these three destinations.

Practice Session is a contextual workflow, not a fourth destination. Metronome,
MIDI, notifications, profiles, and other setup are globally reachable tools.

## Reusable page patterns

### Action-first page

Lead with the control or content the learner came to use. A short status line is
enough when context is necessary. Avoid a decorative hero that repeats the page
title or explains a familiar interaction before revealing it.

Current example: Piano keeps a full-width keyboard docked at the bottom of the
screen and gives the learning canvas above it to the optional visual reference.

### Today's practice, then catalogue

On repeat-use learning pages, show today's bounded practice plan before the
full catalogue. Make the next exercise, dose, working tempo or challenge, and
focus cue immediately scannable. Continuing recent work is one input to the
plan, not the entire recommendation strategy.

When meaningful history exists, use it to select an appropriate continuation,
maintenance exercise, or progressive challenge. When it does not, offer a
clearly labelled starter regimen based on the learner's stated level or a safe
foundation sequence. Never leave the primary surface empty merely because the
system cannot yet personalize it.

The catalogue remains available for exploration, substitution, and
teacher-directed practice, but browsing it should not be required before a
normal daily session can begin.

### Summary, then activity

Progress pages should answer “how am I doing?” before presenting the underlying
event log. Use a few legible metrics with meaningful values; omit unavailable
metrics rather than filling their place with status prose.

Current example: Progress shows practices, active days, and best accuracy above
recent activity.

### Standard settings list

Routine preferences use one quiet, width-capped list. Each setting has a clear
label, optional one-line description, and its control in the trailing position.
Permission state may be a list item with a direct action. Avoid gradients,
illustrative headers, and a separate card for every switch.

Current example: Notifications uses standard list and switch rows.

### Status first, advanced details on demand

Hardware pages should first answer whether the instrument is connected and what
the learner can do next. Technical identifiers, channels, raw MIDI values, and
diagnostic controls belong in collapsed advanced sections unless they require
immediate attention.

Current examples: MIDI Settings prioritizes connection and available keyboards;
Device Controller collapses device metadata and advanced MIDI controls.

### Contextual tool on a shared surface

When a supporting activity modifies the primary object, prefer a contextual
tool over making the learner switch the entire page into another mode. Keep the
primary object usable, summarize the active tool state beside it, and move
multi-field configuration into a focused sheet with a clear reading order.

Current example: Piano is always playable. **Show notes** opens a Type →
Selection → Voicing flow, then returns to the same piano with the chosen scale
or chord highlighted. A 12-tone circle connects those pitch classes into a
recognizable shape while the keyboard remains fixed at the bottom. Clearing the
highlights returns to free play without a mode transition.

### Instrument dock and learning canvas

When a page combines an instrument with explanatory material, keep the
instrument stable and dedicate the remaining space to learning. The keyboard
spans the bottom edge at a familiar height and adapts by range—two octaves on a
phone, three on a medium screen, and four on a wide screen—rather than becoming
taller or moving when reference content changes.

The keyboard is a dense, direct-manipulation instrument rather than a row of
independent buttons, so its keys may be narrower than the standard 44-pixel
control target to keep a complete musical range visible. Preserve full-key hit
areas and per-key semantics; regular buttons, menus, and settings controls still
use the standard minimum target.

Visual theory aids should explain relationships, not decorate empty space. Use
consistent pitch positions, connect selected tones when geometry is meaningful,
and show currently played tones as a separate immediate-feedback state. Name
the representation accurately: a chromatic circle is not a Tonnetz.

## Visual language

### Material 3 foundation

- Piano Fitness uses Material 3 as its component and accessibility baseline.
  Material 3 provides coherent behavior, but it does not replace product-level
  judgment about hierarchy, density, language, or progressive disclosure.
- Prefer current Material components such as `NavigationBar`, `FilledButton`,
  and `SegmentedButton` when they fit the interaction.
- Configure shared component behavior in
  [`app_theme.dart`](../lib/presentation/theme/app_theme.dart), then use the
  themed component directly. Add local overrides only for a documented need.
- Migrate older components page by page so each change can be visually and
  responsively reviewed.

### Surfaces and elevation

- The runtime source of truth is
  [`app_theme.dart`](../lib/presentation/theme/app_theme.dart). Add shared visual
  decisions there before styling individual pages independently.
- Use Material 3 color roles from `Theme.of(context).colorScheme`; do not embed
  feature-specific light-mode colors.
- Use `surfaceContainerLow` for quiet repeated rows and
  `surfaceContainerHighest` for compact controls that need separation.
- Default repeated cards to zero elevation. Reserve shadows for floating or
  temporarily elevated elements such as dialogs and menus.
- A page may have several sections, but it should not look like every piece of
  content is floating independently.

### Shape

- Use the shared radii in
  [`ui_constants.dart`](../lib/presentation/constants/ui_constants.dart).
- Main containers generally use `AppBorderRadius.large` (16).
- Nested compact controls generally use `AppBorderRadius.medium` (12).
- Rounded shapes should soften the interface, not turn every label into a
  decorative badge.

### Color

- Neutral surfaces carry structure.
- Primary color identifies the current action, meaningful progress, or
  completion of today's prescribed dose.
- Secondary and tertiary colors add hierarchy sparingly.
- Error and warning colors are reserved for states that require attention.
- Never rely on color alone; pair it with shape, text, an icon, or semantics.
- Gradients are for rare hero or celebratory moments, not the default treatment
  for cards and controls.

### Typography

- Use the app `TextTheme`; avoid one-off font sizes unless a component has a
  documented need.
- Page titles come from the app bar or a single clear heading.
- Exercise/key names use a compact, semibold title style.
- Supporting copy uses `onSurfaceVariant` and should remain readable, not faint.
- Metrics such as BPM are concise labels, not prose sentences. When their
  quality matters, add a small icon and a plain-language tooltip rather than a
  second line of diagnostic copy.
- Use at most three obvious levels of type hierarchy in one section.

### Spacing and layout

- Use the shared 4/8/16/24/32/48 spacing scale in `Spacing`.
- Align repeated content to the same edges.
- Keep related actions close together and separate unrelated sections with more
  space.
- Test narrow phone, tablet, and desktop widths. Prefer constraint-based layout
  decisions over device-name checks.

### Motion

- Motion should explain a state change or make progress feel responsive.
- Keep routine transitions short and subtle.
- Avoid ambient animation during focused practice.
- Respect reduced-motion preferences when adding nonessential motion.

## Reference pattern: today's regimen

The default Curriculum surface should make a session feel ready to begin:

```text
Today's practice                                      18 min

1  Major scales · all 12 keys              3 sets · 72 BPM
   Focus: even rhythm as the thumb passes under

2  I–IV–V–I progressions                   2 sets · 60 BPM
   Focus: move between chords without breaking time

3  Apply it · improvise with today's keys             4 min

                                      [ Start practice ]
```

The exact prescription and amount of personalization will evolve, but the
hierarchy should remain stable: what to do, how much to do, the appropriate
challenge, what to focus on, and when the session is done. The application step
makes the relationship between training and music explicit; it need not be
MIDI-scored like a closed technique exercise.

## Reference pattern: compact exercise list

The Curriculum detail and substitution surfaces use a compact view of the
broader exercise catalogue:

```text
Build secure scale technique in each hand, then together.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━  3 / 12 keys

C major       [ Left   ● ● ○ ] [ Right  ● ○ ○ ] [ Together  ○ ○ ○ ]
D♭ major      [ Left   ● ● ● ] [ Right  ● ● ○ ] [ Together  ● ○ ○ ]
```

The important characteristics are:

- One short context sentence, then one page-level progress summary.
- One quiet row per practice item.
- The item name and its actions share a line when space permits.
- Related actions read as a group without a heavy enclosing border.
- Progress is visible but visually quieter than the action label.
- BPM appears beside progress only after it exists.
- Practice marks acknowledge recorded activity; the checkmark remains the
  stronger signifier for established proficiency.
- Finishing today's prescribed reps accents the relevant action, not the entire
  screen or the exercise forever.

Use this pattern for other repeated practice choices, but adapt the labels and
metrics to the learner's task.

## Applying the direction to other pages

### Before redesigning

Write down the primary user action in one sentence. If a page has several
equally important answers, decide whether it is really one page or several
steps.

Then inventory every visible element:

- Does it help the user decide or act now?
- Is it useful only after data exists?
- Is it repeated elsewhere?
- Could it be represented by a familiar visual signifier?
- Could it move to a detail, history, or settings view?

### Common transformations

| Existing pattern | Preferred direction |
| --- | --- |
| Several sentences of status text | One visual indicator with accessible detail |
| Empty metric placeholders | Hide the metric until a value exists |
| Outlined controls inside outlined cards | Quiet row plus tonal action group |
| Entire card colored for partial progress | Accent the specific progress indicator |
| Large cards for repeated simple choices | Compact rows with consistent touch targets |
| Different decorative language per page | Shared theme roles, spacing, radii, and states |
| Technical system terminology | Short learner-facing language |
| “3 of 3 complete” as permanent mastery | Today's dose plus a continuing development state |
| Empty Curriculum with no history | A clearly labelled starter regimen |
| Catalogue as the default starting point | Today's prescribed practice first; catalogue second |

## A small design vocabulary

These terms make design conversations easier:

- **Visual hierarchy**: the order in which the eye notices things. The primary
  action should usually be noticed before supporting detail.
- **Density**: how much useful information fits in an area. High density can be
  efficient; clutter is density without clear hierarchy.
- **Affordance**: the visual clue that something can be interacted with. A
  button should look tappable without needing instructional text.
- **Progressive disclosure**: revealing detail only when it becomes relevant.
- **Container nesting**: placing panels or bordered elements inside other
  panels. Too much nesting makes an interface feel mechanical and heavy.
- **Semantic color**: color chosen for meaning—such as success or error—rather
  than decoration.
- **Touch target**: the full tappable area, which can be larger than the visible
  icon or label.
- **State**: a component's current condition, such as default, pressed, in
  progress, today's dose completed, established, maintaining, disabled, or
  error.

## Design review questions

Use these questions during implementation and review.

### Two-second test

- What draws the eye first?
- Is the page's purpose immediately clear?
- Is the next useful action obvious?
- Can the learner begin without first designing their own session?

### Training model

- Does the experience distinguish finishing today's reps from permanently
  completing a technique?
- Is the prescribed challenge appropriate, and does form constrain progression?
- Will established foundational exercises return for maintenance or a new
  variation?
- Is the connection between technique and musical application visible?
- Does repetition feel responsive and purposeful without punitive gamification?

### Content

- Is every visible sentence useful at this moment?
- Is any wording exposing an internal implementation concept?
- Are missing values hidden rather than described at length?

### Visual hierarchy

- Are too many elements using borders, color, elevation, or bold type?
- Can one containing surface be removed?
- Are repeated items compact and easy to scan?
- Does whitespace show the grouping without extra decoration?

### Interaction and accessibility

- Are touch targets at least 44 logical pixels?
- Do hover, focus, pressed, disabled, today's-dose-completed, established, and
  maintaining states remain clear?
- Does every control have a contextual semantic label?
- Is meaning available without relying on color?
- Does text scaling remain usable?

### Responsive behavior

- Does it work at 390 logical pixels without clipping or overflow?
- Is content width capped on large screens?
- Does the primary action stay visible across layouts?

## Implementation sources of truth

Use these in order:

1. The active Flutter `ThemeData` and `ColorScheme` in
   [`app_theme.dart`](../lib/presentation/theme/app_theme.dart).
2. Shared spacing, radius, size, opacity, and motion tokens in
   [`ui_constants.dart`](../lib/presentation/constants/ui_constants.dart).
3. Semantic and piano-key theme extensions in `lib/presentation/theme/`.
4. Reusable presentation components and documented feature patterns.

The older
[`design-system.md`](specifications/design-system.md) specification contains
useful historical ideas, but some example classes, colors, and typography are
aspirational and are not implemented. Runtime theme values take precedence.

## Evolving this guide

This is a starting point, not a finished design system.

When a pattern works well on a second page:

1. Extract reusable tokens or components only when repetition is real.
2. Add the pattern and its states to this guide.
3. Add responsive and accessibility tests.
4. Record a screenshot or short visual example when practical.
5. Document intentional exceptions and why they exist.

Consistency should make the product feel coherent, while leaving room for the
piano, musical feedback, and moments of achievement to feel expressive.
