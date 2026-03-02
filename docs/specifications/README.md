# Specifications

Specifications document **what** Piano Fitness features and components should do. They describe intended behavior, data models, interfaces, and requirements so that developers, designers, and contributors share a common understanding before and during implementation.

## Specifications vs. ADRs

These two document types serve different purposes and complement each other:

|               | Specifications                  | ADRs                                         |
| ------------- | ------------------------------- | -------------------------------------------- |
| **Answers**   | What are we building?           | Why did we choose this approach?             |
| **Focus**     | Behavior, structure, interfaces | Decision context, alternatives, consequences |
| **Lifecycle** | Updated as the feature evolves  | Largely immutable once recorded              |
| **Location**  | `docs/specifications/`          | `docs/ADRs/`                                 |

When a specification leads to a significant architectural decision, capture that decision in an ADR and link to it from the spec.

## When to Write a Specification

Write a specification when:

- Building a **new feature** with non-trivial behavior or multiple states
- Designing a **shared component** that will be used across features
- Specifying a **cross-cutting system** (e.g., data persistence, audio, visual feedback)
- Aligning on **acceptance criteria** before implementation begins
- Documenting **complex algorithms or data models** that need to be understood before coding

Not every change needs a spec. Small bug fixes, refactors, and minor UI tweaks generally don't.

## How to Create a Specification

1. Copy `_template.md` to a new file in this directory, using a descriptive kebab-case name (e.g., `metronome-component.md`).
2. Fill in the `## Overview` and any sections relevant to your feature. **Omit sections that don't apply** — not every spec needs testing requirements, acceptance criteria, or implementation phases.
3. Include the optional metadata block at the top if you want to track status and dates.
4. Describe *what* the feature must do and *why*, not *how* the code implements it — see [Specs vs. Code](#specs-vs-code) below.
5. Reference related specs and ADRs by name in prose; avoid maintaining links that may go stale.

## Specs vs. Code

Specs and code answer different questions and should stay in their respective lanes:

| Question                      | Where it lives                   |
| ----------------------------- | -------------------------------- |
| What must this feature do?    | Specification                    |
| Why was this approach chosen? | ADR                              |
| How is it implemented?        | Code + inline `///` doc comments |

Avoid copying Dart class and method definitions into specs. Code in a spec will drift the moment a field is renamed or a signature changes, creating a false or misleading reference. Specs describe **contracts** — what data a model must capture, what constraints apply, what operations a service must support — expressed in prose or bullet points. The code is the authoritative source for the rest.

If a structural decision deserves explanation (e.g., "BPM is stored as an integer, not a float"), that reasoning belongs in an ADR, not reproduced as a class definition in a spec.

## Relationship to Implementation

Specifications describe **intended** behavior, not necessarily the current state of the code. They are living documents — update them as requirements are refined during development. When the implementation diverges from the spec, update the spec to reflect the decision or open an ADR explaining the change in direction.

Spec sections marked as optional (e.g., `## Future Enhancements`) represent planned but not yet committed work.
