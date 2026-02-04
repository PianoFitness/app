# ADR-0011: 80% Test Coverage Requirements

**Status:** Accepted

**Date:** 2024-01-01

## Context

Piano Fitness handles complex domain logic (music theory, MIDI processing) and critical infrastructure (MIDI devices, notifications). Insufficient test coverage leads to:
- Regression bugs during refactoring
- Difficulty maintaining confidence during changes
- Unclear impact of code modifications
- Technical debt accumulation

**Coverage Thresholds Considered:**

- **70%**: Too low for complex codebase, insufficient safety net
- **80%**: Industry standard, balances thoroughness with pragmatism
- **90%+**: Diminishing returns, discourages necessary refactoring

**What Gets Excluded:**
- Generated code (build_runner outputs)
- Platform-specific code requiring device testing
- UI layout/styling (visual testing more appropriate)
- Error handling for impossible states

## Decision

Mandate ≥80% test coverage for all new features, bug fixes, and refactoring.

**Enforcement Strategy:**

1. **Pre-Development**: Check baseline coverage
2. **During Development**: Write tests alongside code
3. **Pre-Commit**: Automated via lefthook pre-push hook
4. **Coverage Verification**: HTML report review required

**Test Categories:**

- **Unit Tests** - Business logic in domain and application layers
- **Widget Tests** - UI components and MVVM integration
- **Integration Tests** - Complete user workflows

**Commands:**

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Consequences

### Positive

- **Regression Prevention** - High confidence during refactoring
- **Documentation** - Tests document expected behavior
- **Design Quality** - Testable code tends to be better designed
- **Faster Development** - Catch bugs early, cheaper to fix
- **Maintainability** - Clear impact of changes

### Negative

- **Time Investment** - Writing tests takes time
- **False Security** - Coverage percentage doesn't guarantee quality
- **Maintenance Burden** - Tests require updates when code changes

### Neutral

- **80% Threshold** - Pragmatic balance between safety and pragmatism
- **Enforced via Lefthook** - Automated checking prevents violations

## Related Decisions

- [ADR-0012: Test Organization](0012-test-organization-mirrors-source.md) - Test structure
- [ADR-0020: Lefthook Automation](0020-lefthook-automated-quality-controls.md) - Coverage enforcement
- [ADR-0010: Shared Test Helper](0010-shared-test-helper-infrastructure.md) - Test infrastructure

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Coverage enforcement: `lefthook.yml` pre-push hook
- Coverage reports: `coverage/` directory
- Testing guidelines: `test/GUIDELINES.md`
- Current status: 99.9% pass rate (719/720 tests)
