<!--
  Optional metadata — fill in what's useful, delete what isn't.
  Status: Draft | Active | Deprecated
  Created: YYYY-MM-DD
  Last updated: YYYY-MM-DD
-->

# [Feature / Component Name] Specification

## Overview

One or two paragraphs describing what this feature or component is, what problem it solves, and its place in the app. Keep it concise — this is the entry point for anyone new to the spec.

## Goals

<!-- Optional. Include when the spec covers a broad system with multiple motivating objectives. Omit for small, focused components. -->

- **[Goal name]**: Brief description of what success looks like.
- Add one bullet per distinct goal; three to five is usually the right number.

## Requirements

Describe what the feature must do. Use sub-sections to group related requirements when the scope is large. Keep requirements specific enough to be testable.

### Functional Requirements

- Requirement one.
- Requirement two.

### Technical Requirements

<!-- Optional. Include for components with non-trivial architectural or platform constraints. -->

- Requirement one (e.g., "Must work without a network connection").
- Requirement two.

### Performance Requirements

<!-- Optional. Include for real-time or latency-sensitive components such as audio, MIDI, or animation. -->

- Precision / latency target (e.g., "Timing accuracy within ±1 ms").
- Memory / battery constraint if relevant.

## Design Notes

<!--
  Optional. Include when high-level structure, data flow, or algorithmic approach is worth
  capturing before implementation begins.

  Focus on WHAT and WHY, not HOW:
  - Describe contracts: what data a model must hold, what constraints apply,
    what operations a service must support.
  - Use prose and bullet points rather than full Dart class definitions.
  - Avoid copying class signatures or method bodies — they will drift as the
    code evolves and become a misleading reference. The code and its inline
    doc comments are the authoritative source for implementation detail.
  - If a structural decision needs justification, record it in an ADR instead.
-->

Describe the high-level structure — major components, data flow, and key abstractions.

**[Component / model name]**
- Must hold: field one, field two.
- Must enforce: constraint (e.g., BPM between 20 and 300).
- Must support operations: operation one, operation two.

Use fenced `text` blocks for directory or structural trees when they aid understanding:

```text
feature/
├── feature_page.dart
├── feature_view_model.dart
└── widgets/
    └── feature_widget.dart
```

## User Flow

<!-- Optional. Include for user-facing features with a meaningful sequence of steps. Omit for purely technical or infrastructure specs. -->

1. User opens [screen / entry point].
2. User [takes action].
3. App responds with [result].

## Implementation Phases

<!-- Optional. Include when the feature will be delivered incrementally. Each phase should be independently shippable. Omit for features that will be built all at once. -->

### Phase 1 — [Short label]

**Goal**: What this phase delivers.

- Deliverable one.
- Deliverable two.

### Phase 2 — [Short label]

**Goal**: What this phase delivers.

- Deliverable one.

## Integration Points

<!-- Optional. Include when this feature depends on or is consumed by other systems. Reference other specs and ADRs by name. -->

- **[Other system]**: How this feature interacts with it.
- **[Another system]**: What data or events are exchanged.

## Testing Requirements

<!-- Optional. Include for components with non-trivial testing strategies. Reference the test directory structure from AGENTS.md. -->

### Unit Tests

- What business logic needs unit coverage.

### Widget Tests

- What UI states and interactions need widget test coverage.

### Integration Tests

- What end-to-end flows need integration test coverage.

## Acceptance Criteria

<!-- Optional but recommended for features with clear, verifiable completion conditions. Use checkboxes so progress can be tracked during implementation. -->

- [ ] Criterion one — what must be true for the feature to be considered done.
- [ ] Criterion two.
- [ ] Criterion three.

## Future Enhancements

<!-- Optional. Capture post-v1 ideas here rather than in the requirements so the current scope stays clear. -->

- Enhancement idea one.
- Enhancement idea two.
