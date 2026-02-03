# ADR-0019: CLI-Only Package Management

**Status:** Accepted

**Date:** 2024-01-01

## Context

Flutter/Dart package management can be done via:

1. **Manual editing** - Directly edit `pubspec.yaml`
2. **CLI commands** - Use `flutter pub add/remove`

**Problems with manual editing:**

- Syntax errors in YAML
- Incorrect version constraints
- Missing dependency resolution
- Manual `flutter pub get` required
- No automatic constraint checking

## Decision

**MANDATORY: Use Flutter CLI for all package management operations.**

**Required Commands:**

```bash
# Add dependencies
flutter pub add package_name
flutter pub add --dev package_name  # dev dependencies
flutter pub add package_name:^1.0.0  # specific version

# Remove dependencies
flutter pub remove package_name

# Update dependencies
flutter pub get        # after manual changes (avoid)
flutter pub upgrade    # upgrade to latest compatible
flutter pub outdated   # check for updates
```

**Prohibited:**
- ❌ Manual editing of `pubspec.yaml` dependencies section
- ❌ Direct version changes without CLI

**Exceptions (CLI still preferred):**
- ✅ Constraint changes (prefer `flutter pub add package:^version`)
- ✅ Dependency overrides (rare, document reason)

## Consequences

### Positive

- **Safety** - CLI validates syntax and constraints
- **Automation** - Auto-runs `pub get` after changes
- **Consistency** - Standardized workflow across team
- **Version Resolution** - CLI handles constraint conflicts
- **Error Prevention** - Catches issues before commit

### Negative

- **Learning Curve** - Developers must learn CLI commands
- **Documentation** - Must document in AGENTS.md/CONTRIBUTING.md

### Neutral

- **Speed** - CLI slightly slower than direct edit, but safer

## Related Decisions

- [ADR-0020: Lefthook Automation](0020-lefthook-automated-quality-controls.md) - Git hooks enforce quality
- [ADR-0023: Import Organization](0023-import-organization-conventions.md) - Code organization standards

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Documented in: `AGENTS.md`, `CONTRIBUTING.md`
- Enforced via: Code review guidelines
- Example: `flutter pub add piano` adds `piano` package correctly
