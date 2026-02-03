# ADR-0020: Lefthook Automated Quality Controls

**Status:** Accepted

**Date:** 2024-01-01

## Context

Manual code quality checks are error-prone:

- Developers forget to run `flutter analyze`
- Code formatting inconsistencies slip through
- Tests not run before pushing
- Commits don't follow conventions

**Solution needed:**
- Automated pre-commit checks
- Automated pre-push validation
- Zero-configuration for developers
- Fast feedback loop

## Decision

Implement **lefthook git hooks** for automated quality controls.

**Installation (one-time):**
```bash
brew install lefthook  # macOS
lefthook install       # in project directory
```

**Automated Checks:**

**Pre-Commit Hook:**
```yaml
pre-commit:
  commands:
    format:
      run: dart format .
    analyze:
      run: flutter analyze
```

**Pre-Push Hook:**
```yaml
pre-push:
  commands:
    test:
      run: flutter test --coverage
```

**Manual Trigger:**
```bash
lefthook run pre-commit  # Run checks manually
```

**Benefits over alternatives:**

| Tool       | Speed              | Config        | Cross-Platform      |
| ---------- | ------------------ | ------------- | ------------------- |
| lefthook   | Fast (parallel)    | YAML          | ✅ All platforms     |
| Husky      | Slow (JS overhead) | JSON          | ❌ Node.js required  |
| pre-commit | Medium             | YAML          | ⚠️ Python required   |
| Git hooks  | Fast               | Shell scripts | ⚠️ Platform-specific |

## Consequences

### Positive

- **Zero Thought** - Quality checks automatic
- **Fast Feedback** - Errors caught before push
- **Consistency** - All developers use same checks
- **Parallel Execution** - Format + analyze run simultaneously
- **Cross-Platform** - Works on macOS/Linux/Windows
- **Coverage Enforcement** - Pre-push hook validates ≥80% (ADR-0011)

### Negative

- **Installation Required** - Developers must install lefthook
- **Can Skip** - `--no-verify` bypasses hooks (discouraged)
- **Hook Failures** - Blocks commits until fixed

### Neutral

- **Configuration** - `lefthook.yml` in repository
- **Manual Override** - Can run `lefthook run` manually

## Related Decisions

- [ADR-0011: Test Coverage Requirements](0011-test-coverage-requirements.md) - Pre-push enforces ≥80%
- [ADR-0019: CLI Package Management](0019-cli-only-package-management.md) - Development workflow

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Configuration: `lefthook.yml`
- Pre-commit: `dart format .` + `flutter analyze`
- Pre-push: `flutter test --coverage`
- Installation: `brew install lefthook && lefthook install`
