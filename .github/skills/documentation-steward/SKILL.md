---
name: documentation-steward
description: "Create, update, review, retire, or keep-in-sync PianoFitness documentation: feature specifications (docs/specifications/) and Architecture Decision Records (docs/ADRs/). Use when: drafting a new spec; updating a spec after an implementation diverges; creating an ADR for a significant architectural choice; retiring or superseding an ADR; linking a spec to a related ADR; reviewing whether documentation is stale; syncing docs after a refactor or feature change; checking the next ADR number; checking if a spec exists before building a feature."
argument-hint: "Describe the documentation task: e.g. 'draft spec for repertoire tracker', 'update practice-sessions.md to reflect new timer implementation', 'create ADR for switching from hive to Drift'"
---

# Documentation Steward

Manages PianoFitness feature specifications and Architecture Decision Records (ADRs) — draft, update, retire, and cross-reference them according to project conventions.

## When to Use

- Drafting a **new spec** before or after building a feature
- Updating an **existing spec** when the implementation diverges from it
- Creating an **ADR** after a significant architectural decision is made
- Superseding or deprecating an **old ADR**
- Cross-referencing a spec and the ADR(s) that underpin it
- Finding the next available ADR number
- Checking whether a spec or ADR exists before starting work

## Document Locations

| Type           | Directory              | Template                           |
| -------------- | ---------------------- | ---------------------------------- |
| Specifications | `docs/specifications/` | `docs/specifications/_template.md` |
| ADRs           | `docs/ADRs/`           | `docs/ADRs/template.md`            |
| ADR index      | `docs/ADRs/README.md`  | —                                  |

## Key Principles

- **Specs answer "what"**: behavior, data models, interfaces, acceptance criteria. Update freely as the feature evolves.
- **ADRs answer "why"**: context, decision, alternatives, consequences. Treat as largely immutable once recorded; supersede rather than edit.
- **Accessibility is required** in every user-facing spec (`## Accessibility` section). Never omit it.
- **Describe intent, not code**: avoid copying class signatures or method bodies — the code diverges and the doc becomes misleading.
- **Cross-reference by name in prose**: e.g. "see ADR-0024" or "see `practice-sessions.md`" — name-based references survive file moves better than links.

---

## Procedure: Draft a New Spec

1. Read `docs/specifications/README.md` to understand when a spec is warranted.
2. Read `docs/specifications/_template.md` for the full section inventory.
3. Read 1-2 existing specs (e.g. `practice-sessions.md`, `metronome-component.md`) to calibrate tone and depth.
4. Create a new file: `docs/specifications/<kebab-case-name>.md`.
5. Fill in `## Overview`, `## Requirements`, and `## Accessibility`. Add optional sections only when relevant.
6. If the feature raises an architectural question, draft an ADR and cross-reference it from the spec.
7. Include the optional metadata block (`Status: Draft`, `Created: YYYY-MM-DD`) at the top.

---

## Procedure: Update an Existing Spec

1. Read the current spec in full.
2. Read any code the spec describes — look in `lib/presentation/features/`, `lib/domain/`, `lib/application/`.
3. Identify divergences: missing functionality, changed data models, renamed components, removed phases.
4. Edit the spec to reflect what was actually built. Remove or update stale sections; do not leave contradictory content.
5. Update the metadata block (`Last updated: YYYY-MM-DD`, `Status: Active`).
6. If the divergence was caused by an architectural decision, check whether an ADR should be created.

---

## Procedure: Create a New ADR

1. Read `docs/ADRs/README.md` to find the next available number (4-digit, zero-padded).
2. Read `docs/ADRs/template.md` for the required sections.
3. Read 1-2 recent ADRs (e.g. `0024-drift-database-persistence.md`, `0025-exercise-history-data-model.md`) to calibrate tone.
4. Create `docs/ADRs/<NNNN>-<kebab-title>.md` using the template.
5. Fill in: **Status** (`Accepted`), **Date**, **Context**, **Decision**, **Consequences**, **Related Decisions**, and **Technical Story**.
6. Add the new ADR to the appropriate section of `docs/ADRs/README.md`.
7. If a spec motivated or is affected by this ADR, update that spec to reference the ADR by number.

---

## Procedure: Supersede or Deprecate an ADR

1. Open the ADR to be superseded.
2. Change **Status** to `Superseded by [ADR-NNNN](NNNN-new-title.md)`.
3. Create the new ADR (see above) with a **Related Decisions** link back to the old one.
4. Update `docs/ADRs/README.md` to note the supersession inline or via a comment.

---

## Decision Points

### Should this be a spec or an ADR?

| Signal                                                   | Document                          |
| -------------------------------------------------------- | --------------------------------- |
| "What does this feature do?"                             | Spec                              |
| "Why did we choose this approach over alternatives?"     | ADR                               |
| Both — the feature choice has architectural implications | Both: spec + cross-referenced ADR |

### Does this already exist?

- Read `docs/specifications/` listing before creating a new spec.
- Read `docs/ADRs/README.md` index before creating a new ADR — search for related topics.
- If a related spec/ADR exists, update or extend it rather than duplicating.

### How detailed should the spec be?

| Feature size                              | Guidance                                                                              |
| ----------------------------------------- | ------------------------------------------------------------------------------------- |
| Small bug fix or trivial UI tweak         | No spec needed                                                                        |
| Single-screen feature with clear behavior | Overview + Requirements + Accessibility                                               |
| System-level or cross-cutting feature     | Full template including Integration Points, Testing Requirements, Acceptance Criteria |
| Incremental, multi-phase feature          | Add Implementation Phases section                                                     |

---

## Quality Checklist

Before finishing any documentation task, verify:

- [ ] No class signatures, method bodies, or raw Dart code copied into the doc (use prose descriptions instead)
- [ ] Every user-facing spec has a non-empty `## Accessibility` section
- [ ] ADR has Status, Date, Context, Decision, Consequences, and Technical Story filled in
- [ ] New ADR is listed in `docs/ADRs/README.md`
- [ ] Cross-references use names, not fragile relative links
- [ ] Metadata block (`Status`, `Created`/`Last updated`) is present and accurate
- [ ] Spec sections that don't apply are omitted, not left blank

---

## References

- [Spec template](../../docs/specifications/_template.md)
- [ADR template](../../docs/ADRs/template.md)
- [ADR index](../../docs/ADRs/README.md)
- [Specifications README](../../docs/specifications/README.md)
