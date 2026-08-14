# ADR-0030: Persistent Application Navigation Shell

**Status:** Accepted

**Date:** 2026-08-14

## Context

Primary sections were rendered by `MainNavigation`, but detail and practice
pages were pushed onto the root navigator. Each pushed page covered the main
app bar. A student several steps into a curriculum workflow therefore had to
press Back repeatedly before they could open MIDI settings, switch profiles,
enable the metronome, or move to another section.

These are global actions rather than ancestors in the student's content
history. Their availability should not depend on route depth.

## Decision

`MainNavigation` is a persistent application shell with its own nested content
navigator. Primary sections and nested feature routes render inside that
navigator, leaving one shell-owned app bar visible.

The shell app bar provides:

- a Back action when the nested content navigator can pop;
- an always-available application menu;
- an always-available metronome shortcut; and
- the current section or detail-route title.

The application menu contains all primary sections plus app-wide destinations:
Metronome, MIDI Settings, Notifications, and profile switching. Selecting a
primary section clears nested content history and opens that section's root.

Pages remain usable outside the shell for focused widget tests and standalone
flows. A small inherited scope lets them omit their local app bar only when
they are hosted by the persistent shell.

## Consequences

### Positive

- Global navigation and setup are reachable from every curriculum and practice
  route without unwinding history.
- Back retains a clear meaning: return one step within the current workflow.
- Detail screens no longer create stacked or inconsistent app bars.
- Primary-section switching is direct and does not leave hidden detail stacks.
- The same architecture applies to future nested workflows.

### Negative

- Route title and back-state synchronization are now responsibilities of the
  shell's navigator observer.
- New nested routes should provide a concise `RouteSettings.name` for the
  shell title.
- Pages with page-specific app-bar actions must expose those actions in their
  content or through a future shell-action contract.

### Neutral

- Portrait keeps the existing bottom navigation for fast section switching;
  landscape uses the application menu to preserve vertical space.
- Standalone pages retain their own app bars when no navigation shell scope is
  present.

## Related Decisions

- [ADR-0002: MVVM Pattern in Presentation Layer](0002-mvvm-presentation-pattern.md)
- [ADR-0029: Practice History Page — Navigation Placement and MVP Scope](0029-practice-history-navigation-and-scope.md)

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- `lib/presentation/widgets/main_navigation.dart`
- `lib/presentation/widgets/main_navigation_scope.dart`
- `test/presentation/widgets/main_navigation_test.dart`
- `docs/design-guidelines.md`
