---
name: flutter-quality-auditor
description: Audit Flutter and Dart changes for correctness, architecture, maintainability, performance, accessibility, dependency health, and test quality. Use before commits or merges, after refactors or state-management changes, and when reviewing regressions or assessing whether implementation work meets Piano Fitness quality standards.
---

# Flutter Quality Auditor

Perform an evidence-first review. Diagnose and report by default; modify code only when the user asks for fixes.

## Establish Scope

1. Read the repository instructions and relevant architecture documentation.
2. Inspect `git status`, the relevant diff, and nearby code and tests. Preserve unrelated user changes.
3. Determine the requested review boundary: a diff, feature, regression, or repository-wide health check.
4. Verify each suspected issue against the actual execution path before reporting it.

## Run Proportionate Checks

Start with focused tests, then broaden when the risk or request warrants it. The standard repository checks are:

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
./scripts/check-layer-boundaries.sh
dart fix --dry-run
```

Use `flutter doctor`, `flutter pub deps`, or `flutter pub outdated` only when environment or dependency health is relevant. Use Flutter CLI commands for dependency changes. Distinguish repository-wide baseline failures from failures introduced by the reviewed changes, and distinguish total coverage from coverage of modified code.

Use Dart tooling when it is available, compatible, and narrowly scoped. Do not connect tooling to a broader directory than the repository being reviewed.

## Review Dimensions

### Correctness and Tests

- Follow state and data from input through persistence and presentation.
- Check boundary cases, async ordering, disposal, cancellation, error paths, and null safety.
- Confirm tests exercise user-observable behavior and realistic regressions rather than only implementation details.
- Look for missing migration, integration, widget, or domain tests appropriate to the change.

### Architecture and Maintainability

- Enforce inward dependencies: Presentation to Application to Domain.
- Keep domain code free of Flutter and infrastructure dependencies.
- Check MVVM responsibilities, dependency injection, repository interfaces, and centralized MIDI dispatch.
- Flag oversized constructors, build methods, classes, duplicated logic, and complex conditions that obscure responsibility.
- Ensure resources are disposed and `ChangeNotifier` state changes notify listeners appropriately.

### Flutter User Experience

- Check responsive constraints, overflow risks, rebuild scope, list virtualization, and expensive work inside `build`.
- Check semantics, focus order, keyboard access, touch targets, contrast, scalable text, localization, and alternatives to color-only meaning.
- Prefer `const` where useful, but do not elevate cosmetic micro-optimizations above correctness or clarity.

### Dependencies and Security

- Identify stale, unnecessary, abandoned, or conflicting packages using evidence.
- Check secrets, logs, permissions, validation, and storage of sensitive data.
- Do not recommend dependency churn without a concrete benefit and migration cost.

## Report Findings

Lead with actionable findings ordered by severity. For each finding include:

- file and line;
- observed behavior or risk;
- evidence or reproduction path;
- the smallest appropriate correction.

Then summarize checks run, totals, relevant coverage, and remaining uncertainty. If no findings remain, say so directly and name any checks that could not be run.
