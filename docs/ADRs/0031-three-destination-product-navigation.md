# ADR-0031: Three-Destination Product Navigation

**Status:** Accepted

**Date:** 2026-08-15

## Context

Piano Fitness exposed Curriculum, Practice, Free Play, Reference, Repertoire,
and History as equal primary destinations. Those destinations reflected feature
implementation boundaries more closely than learner intent. Curriculum and
Practice both answered “what should I practise?”, Free Play and Reference both
centered on the same piano surface, and History exposed a log without first
explaining progress.

The curriculum is the product's clearest value proposition: choose useful
technical work, practise it, and see improvement accumulate. Primary navigation
needs to make that loop evident without removing globally useful tools.

## Decision

The application has three primary destinations organized around learner intent:

- **Curriculum** — choose or continue structured practice;
- **Piano** — play freely or use the musical reference mode; and
- **Progress** — understand accumulated practice, then inspect recent activity.

Curriculum is the initial destination. Piano is one always-playable instrument
surface. Reference is an optional **Show notes** tool on that surface: learners
choose a scale or chord in a focused configuration sheet, then return to the
piano with those notes highlighted. The piano remains a full-width bottom dock,
showing two to four octaves according to available width, while the area above
becomes a learning canvas. Its first reference representation is a 12-tone
circle that connects selected pitch classes and responds to played notes.
Practice sessions remain contextual routes launched from Curriculum. The
Practice Hub and Repertoire are removed from primary navigation. History
remains the underlying record and is presented as the detail layer of Progress.

Metronome, MIDI setup, notifications, and profile switching remain app-wide
utilities in the persistent navigation shell established by ADR-0030.

## Consequences

### Positive

- The product communicates a simple learn, play, review mental model.
- Curriculum becomes the obvious starting point and north-star experience.
- Duplicate ways to find the same technical exercise no longer compete.
- Free play and reference share one instrument without requiring a mode change.
- Progress provides meaning before exposing chronological records.
- Three destinations remain legible on narrow phone navigation bars.

### Negative

- Practice Hub and Repertoire code remain dormant until a separate deletion or
  product decision is made.
- Users accustomed to standalone Free Play, Reference, or History labels must
  learn the broader Piano and Progress labels.

### Neutral

- Practice sessions, settings, and hardware controls still exist; they are
  contextual or global routes rather than primary destinations.
- This decision changes presentation and navigation, not domain exercise or
  history models.

## Related Decisions

- [ADR-0029: Practice History Page — Navigation Placement and MVP Scope](0029-practice-history-navigation-and-scope.md)
- [ADR-0030: Persistent Application Navigation Shell](0030-persistent-application-navigation-shell.md)

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- `lib/presentation/widgets/main_navigation.dart`
- `lib/presentation/features/piano/`
- `lib/presentation/features/history/`
- `docs/ux-audit.md`
- `docs/design-guidelines.md`
