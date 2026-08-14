# Application UX Audit

> Status: implemented baseline. Audited and applied August 2026.

## Implementation outcome

The audit now has a working product baseline rather than only a proposed
direction:

- Curriculum is the default destination and offers a direct **Continue** action
  when matching practice history exists.
- Primary navigation is reduced to **Curriculum**, **Piano**, and **Progress**.
- Piano combines free play and reference as modes of one surface.
- Curriculum-launched practice opens in a focused state, with configuration
  available on demand.
- Progress leads with practice count, active days, and best accuracy before the
  chronological activity list.
- MIDI, notification, and device-controller pages use compact settings patterns
  and hide advanced controls until requested.
- Practice Hub and Repertoire are retired from product navigation. Their source
  remains temporarily so deletion can be evaluated separately from this UX
  change.

The recommendations below are retained as the reasoning behind the resulting
information architecture and as a checklist for future work.

## Product focus

Piano Fitness is strongest when it helps a learner choose a useful technique,
start practising immediately, and see that work accumulate over time. The
Curriculum is the clearest expression of that promise because it connects all
three parts in one journey.

The product hierarchy should therefore be:

1. **Curriculum:** decide what to practise and continue recent work.
2. **Practice session:** play the selected exercise with immediate feedback.
3. **Progress:** understand consistency and improvement over time.
4. **Tools:** use the piano, reference view, metronome, and device settings when
   needed.

Previously, six equal navigation destinations made utilities and overlapping
entry points appear as important as that core loop. The resulting information
architecture was capable but harder to understand than the underlying product
needed to be.

## Main findings

### 1. Curriculum should be home

The previous landing page, Free Play, begins with explanatory content and then
directs learners elsewhere for structured practice. That makes the first screen
a detour. Curriculum should open first and provide a clear next practice action.

### 2. Navigation exposes the internal feature map

The previous bottom bar contained Curriculum, Practice, Free Play, Reference,
Repertoire, and History. Six peer destinations were difficult to scan on a
phone and did not communicate which journey mattered most.

The structure also mirrors implementation boundaries rather than learner
intent. A learner should not have to decide whether a scale belongs under
Curriculum, Practice, or Reference before acting.

### 3. Practice and Curriculum overlap

The Practice hub lists the same exercise families already available in the
Curriculum, adds quick starts, and links to a metronome that is already globally
available. It creates two competing answers to “what should I practise?” and
does not use the learner's progress to make the choice easier.

### 4. Activity and proficiency were conflated

History records completed attempts, while Curriculum previously filled its
practice marks only when an attempt also had qualifying accuracy and a
compatible reliable tempo measurement. This made real practice disappear from
the curriculum, especially for history recorded under an older tempo algorithm.

The interface should distinguish these concepts:

- A filled practice dot means a matching practice was recorded.
- A checkmark means the stricter proficiency rule has been met.
- BPM appears only when compatible reliable tempo exists.

### 5. Several pages explain themselves before becoming useful

Free Play, Practice, MIDI Settings, Notifications, and Repertoire use prominent
headers, panels, icons, or instructional copy before the main control. This
creates a software-dashboard feeling and pushes the task below the fold. Page
titles and short empty-state guidance are usually enough.

## Recommended information architecture

Use three primary destinations:

| Destination | Purpose | Contains |
| --- | --- | --- |
| Curriculum | Choose and continue practice | Current focus, skill catalogue, practice actions, compact progress |
| Piano | Explore or look something up | Free play and scale/chord reference as two modes of one piano surface |
| Progress | Review consistency and growth | Summary, recent activity, history, personal bests |

Keep these as contextual or secondary routes:

- Practice Session opens from a Curriculum action, not from primary navigation.
- Metronome remains globally available from the app bar.
- Profile, MIDI, notifications, and other preferences live under one settings or
  profile destination.
- Advanced device controls open from a connected MIDI device.

This reduces the learner's recurring decision to: **learn, play, or review**.

## Page-by-page recommendations

### Curriculum — keep and strengthen

Make this the default page and primary navigation destination. Add a compact
“Continue” area when recent work exists, followed by the skill catalogue. Lead
with foundational skills and progressively disclose modes and advanced
variations. Avoid repeating the page title in a nested app bar.

### Practice hub — merge, then remove

The page is not needed as a separate destination. Move any genuinely useful
quick starts into Curriculum's “Continue” or “Suggested next” area. The
Curriculum already provides every practice family with more context and
progress. Remove the duplicate metronome entry.

### Practice session — keep as the focused task

This is the product's action screen. Keep the current exercise goal, keyboard,
feedback, and primary start/reset control visible. Put configuration behind a
compact settings affordance when the session was launched from Curriculum.
Avoid showing every possible configuration as equal-weight controls during
practice.

### Free Play — keep, simplify, and rename Piano

Show the piano immediately. Remove the large “Free Play Mode” introduction and
the banner directing users to Practice. Connection state can be a small status
near the keyboard. Consider a segmented Play/Reference switch so both tools
share the same mental model and screen.

### Reference — merge into Piano

Reference is useful, but it is a mode of the same interactive piano rather than
a separate top-level product area. Keep its compact configuration row and reuse
the common piano surface.

### History — evolve into Progress

History is useful but reads as an event log. Add a small summary first: practice
days, recent focus, and improvements that help the learner decide what to do
next. Keep the raw chronological list below it and provide direct links back to
the matching Curriculum exercise.

### Repertoire — remove from primary navigation

The current page is primarily a timer plus recommendations for third-party
apps; it does not manage repertoire. If repertoire management is not a planned
core capability, remove the page and preserve only a generic practice timer if
users need it. If repertoire becomes core later, rebuild it around pieces,
sections, goals, and progress rather than the current timer-first page.

### Metronome — keep as a global tool

The quick panel is the right primary interaction. The full page remains useful
for detailed control, but it does not need another entry in the Practice hub.

### MIDI settings — keep under settings

Make connection status and “Connect device” the first visual priority. Move
output channel and troubleshooting behind secondary disclosure. Avoid a large
decorative Bluetooth icon and repeated status panels.

### Device controller — keep as an advanced route

This page exposes technical identifiers, ports, control-change values, program
numbers, and pitch bend. It is valuable for diagnostics and advanced hardware
use but should open only from a connected device, with device metadata collapsed
by default.

### Notification settings — keep, flatten

Use a standard settings list: permission status, timer completion switch,
practice reminder switch, and reminder time. The existing gradient permission
panel and several large containers give routine preferences too much visual
weight.

### Profiles — keep under the app bar

Profiles support separate history and progress, but profile management is not a
primary practice destination. The current app-bar access is appropriate. After
switching profiles, every progress/history view must explicitly reload for the
new active profile.

## Pages that are probably not needed

- **Practice hub:** duplicates Curriculum and global tools.
- **Standalone Reference:** merge into Piano.
- **Repertoire in its current form:** remove unless piece management is a
  committed product direction.

History should not be deleted, but it should become the detail layer of a more
useful Progress experience.

## Delivery record

### Implemented

- Open on Curriculum.
- Show recorded practice independently from proficiency.
- Remove Curriculum's duplicate nested app bar.
- Reduce primary navigation to Curriculum, Piano, and Progress.
- Merge Free Play and Reference.
- Move quick starts into Curriculum and retire the Practice hub.
- Add Curriculum “Continue” and “Suggested next” sections.
- Turn History into a decision-oriented Progress page.
- Flatten settings pages and progressively disclose advanced MIDI controls.

### Follow-up discovery

- Add a more opinionated “Suggested next” recommendation when the curriculum
  progression model can support it.
- Decide whether Repertoire has a committed product roadmap; otherwise remove
  its dormant implementation in a dedicated cleanup.
- Test the complete core loop with learners: launch, choose an exercise,
  practise, return, and recognize the recorded progress.

## Success criteria

- A returning learner can begin the next useful exercise in two taps or fewer.
- A completed practice appears immediately in both Curriculum and Progress.
- The primary navigation has no more than four destinations.
- Each page has one obvious primary action or purpose in a two-second scan.
- Utilities never compete visually with the current learning goal.
