---
name: documentation-steward
description: Create, update, simplify, split, deprecate, review, and reconcile Piano Fitness specifications and architecture decision records. Use for work in docs/specifications or docs/ADRs, when implementation and documentation disagree, when a feature needs a specification, or when a significant technical decision needs a durable record.
---

# Documentation Steward

Maintain a coherent record of what Piano Fitness should do, why it should do it, and which architectural decisions constrain the implementation.

## Establish Context

1. Read the repository instructions and the complete target document.
2. For specifications, read the specifications index, template, and related specifications. For ADRs, read the ADR index and nearby decisions.
3. Inspect the relevant implementation and tests with `rg`; do not infer current behavior from filenames or stale prose.
4. Identify contradictions, duplicated ownership, broken cross-references, and statements unsupported by code or tests.
5. Ask the user only for decisions that materially affect the document and cannot be discovered locally. Batch related questions.

## Choose the Right Document

- Use a specification for user-visible behavior, requirements, constraints, success criteria, and rationale.
- Use an ADR for a durable architectural choice, the alternatives considered, and its consequences.
- Link the two when a product requirement depends on an architectural decision; do not duplicate their full contents.

## Maintain Specifications

- Emphasize what and why. Mention implementation details only when they are genuine constraints.
- Write verifiable requirements and acceptance criteria.
- Treat accessibility as a requirement, including keyboard access, semantics, contrast, motion, and alternatives to color-only communication where relevant.
- Prefer one clear source of truth. Consolidate overlapping documents, split documents with distinct responsibilities, and explicitly mark superseded material.
- Preserve useful historical context without letting it masquerade as current behavior.
- Add or repair links to related ADRs, tests, and specifications.

## Maintain ADRs

- Follow the repository's sequential four-digit naming convention and template.
- Record the actual status and date.
- Explain the context and forces, the chosen decision, viable alternatives, and positive and negative consequences.
- Keep accepted ADRs immutable. Create a superseding ADR when a decision changes and link both records.
- Update the ADR index whenever an ADR is added, superseded, or deprecated.

## Reconcile and Validate

1. Compare the result against code, tests, indexes, and linked documents.
2. Resolve conflicting terminology and ownership boundaries.
3. Verify relative links and headings.
4. Review the diff for accidental rewrites or unrelated changes.
5. Report any deliberate gap between documented intent and implemented behavior.

Do not change implementation merely to make it agree with documentation unless the user also asked for code changes.
