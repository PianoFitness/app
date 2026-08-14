# Piano Fitness Product Design Direction

> Status: active, living guidance. Last updated August 2026.

This guide describes how Piano Fitness should feel and gives contributors a
shared vocabulary for making design decisions. It is intentionally practical:
use it when designing a page, reviewing a pull request, or deciding whether a
piece of information belongs on screen.

The current reference implementation is the compact Curriculum exercise-detail
page in
[`skill_tree_page.dart`](../lib/presentation/features/skill_progression/skill_tree_page.dart).
It is a direction to extend, not a template every page must copy literally.

## North star

**Piano Fitness should feel like a calm, encouraging practice companion: a
modern fitness app for musicians.**

The interface should help a learner answer three questions quickly:

1. What can I practise?
2. How am I progressing?
3. What should I tap next?

It should not feel like an admin dashboard, analytics console, or collection of
nested control panels. The student is there to play piano; the interface should
make that action feel easy to begin.

## Experience qualities

| Quality | What it means in practice |
| --- | --- |
| Calm | Neutral surfaces, limited decoration, and no competing highlights. |
| Focused | One obvious primary task per screen or section. |
| Encouraging | Progress is framed positively; incomplete work is an invitation, not a warning. |
| Efficient | Repeated actions are compact, scannable, and close to the content they affect. |
| Warm | Plain language, soft shapes, and restrained color keep the product approachable. |
| Trustworthy | Metrics are shown only when meaningful and never padded with technical placeholders. |

When qualities compete, prioritize clarity and usability over visual novelty.

## Core principles

### 1. Practice is the primary action

The most prominent elements should help the student start or continue
practising. Supporting statistics, explanations, and configuration should not
compete with that action.

- Put practice choices near the exercise name.
- Use clear action labels such as **Left**, **Right**, **Together**, or
  **Practice**.
- Keep configuration that is not needed for the immediate choice behind a
  secondary interaction.

### 2. Show progress, not accounting

Progress should be understandable at a glance. Prefer a small visual signifier
over a sentence that makes the student interpret the tracking system.

- Use dots, rings, bars, or checkmarks for repeated progress.
- Provide the exact value through semantics or a tooltip when the visual is
  intentionally compact.
- Use learner-facing language such as **keys complete** or **practices
  recorded**.
- Avoid internal terms such as **evidence**, **qualifying attempt**,
  **established proficiency**, or **measurement version** in the interface.

### 3. Use progressive disclosure

Show information when it becomes useful.

- Do not show “tempo unavailable” or an empty metric field. Show BPM only after
  a reliable tempo has been recorded.
- Do not repeat explanatory text on every row.
- Put detailed history and analysis on a dedicated progress or history view,
  not inside the action picker.

### 4. Prefer one visual layer

Repeated borders, panels inside panels, and many equal-weight controls create a
command-console effect. Most sections should need only one containing surface.

- Repeated list rows use a quiet tonal surface and usually no elevation.
- Related actions may sit inside that row as soft tonal pills.
- Avoid placing outlined buttons inside outlined cards.
- Avoid borders when spacing, background tone, or typography already expresses
  the grouping.

### 5. Density and breathing room are partners

Compact does not mean cramped. Remove low-value content first, then use a
consistent spacing rhythm.

- Keep repeated rows low-profile so more of the practice plan is visible.
- Preserve at least a 44 logical-pixel touch target.
- Use whitespace between groups; do not add a container merely to create
  separation.
- Cap content width on large screens so controls do not stretch into long,
  sparse strips.

### 6. Design every state together

Default, in-progress, completed, unavailable, hover, focus, and pressed states
belong to the same component design. Do not design only the empty state.

- Default state: neutral and clearly interactive.
- In progress: a restrained secondary tint or partially filled indicator.
- Complete: a primary tint plus a non-color signifier such as a checkmark or
  filled progress marks.
- Unavailable: explain why and how to proceed; do not merely gray out an action.

### 7. Keep global navigation global

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
| Curriculum | What should I practise? | Continue, choose a skill, begin a focused session |
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

### Continue, then catalogue

On repeat-use learning pages, show a direct continuation of the learner's
recent work before the complete catalogue. Keep the continuation compact and
identify both the exercise and its configuration. Do not fabricate a
recommendation when no meaningful history exists.

Current example: Curriculum shows **Continue** only after a matching practice
record has been found.

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
  completion.
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
- Metrics such as BPM are concise labels, not prose sentences.
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

## Reference pattern: compact practice list

The Curriculum detail page demonstrates the intended hierarchy:

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
- Completion accents the relevant action, not the entire screen.

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
  progress, complete, disabled, or error.

## Design review questions

Use these questions during implementation and review.

### Two-second test

- What draws the eye first?
- Is the page's purpose immediately clear?
- Is the next useful action obvious?

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
- Do hover, focus, pressed, disabled, and completed states remain clear?
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
