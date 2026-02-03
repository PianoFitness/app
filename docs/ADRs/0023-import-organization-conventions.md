# ADR-0023: Import Organization Conventions

**Status:** Accepted

**Date:** 2024-01-01

## Context

Dart import organization affects:

- **Readability** - Clear dependency hierarchy
- **Maintainability** - Easy to spot circular dependencies
- **CI/CD** - Consistent across team
- **Code Review** - Standard format reduces noise

**Dart has built-in formatter** (`dart format`), but import ordering requires manual attention.

## Decision

**Mandatory Import Order:**

```dart
// 1. Dart core libraries
import 'dart:async';
import 'dart:math';

// 2. Flutter framework libraries
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Third-party packages (alphabetical)
import 'package:flutter_midi_command/flutter_midi_command.dart';
import 'package:piano/piano.dart';
import 'package:provider/provider.dart';

// 4. Local imports - ARCHITECTURAL ORDER
//    (follows Clean Architecture dependency rule)
import 'package:piano_fitness/domain/models/chord_type.dart';
import 'package:piano_fitness/domain/services/music_theory/scales.dart';

import 'package:piano_fitness/application/repositories/midi_repository.dart';
import 'package:piano_fitness/application/state/midi_state.dart';

import 'package:piano_fitness/presentation/shared/widgets/piano_keyboard.dart';
import 'package:piano_fitness/presentation/utils/piano_range_utils.dart';

import 'package:piano_fitness/features/practice/practice_page_view_model.dart';
```

**Local Import Architectural Order:**

1. **Domain layer** - Models, services (no dependencies)
2. **Application layer** - Repositories, state (depends on domain)
3. **Presentation layer** - Shared widgets, utilities (depends on domain/application)
4. **Features layer** - Feature-specific code (depends on all above)

**Rationale:**

- **Dependency Flow:** Mirrors Clean Architecture dependency rule (outer depends on inner)
- **Circular Detection:** Easy to spot violations (inner importing outer)
- **Readability:** Clear separation of concerns
- **Code Review:** Incorrect imports stand out immediately

**Example - ViewModel Import:**
```dart
// Practice ViewModel imports
import 'package:piano_fitness/domain/models/practice/exercise.dart';
import 'package:piano_fitness/domain/services/music_theory/scales.dart';

import 'package:piano_fitness/application/repositories/midi_repository.dart';
import 'package:piano_fitness/application/state/midi_state.dart';

import 'package:piano_fitness/presentation/utils/piano_range_utils.dart';
```

## Consequences

### Positive

- **Architecture Enforcement** - Import order reflects dependency rule
- **Circular Prevention** - Easy to spot wrong direction imports
- **Readability** - Consistent across codebase
- **Review Efficiency** - Standard format reduces cognitive load

### Negative

- **Manual Ordering** - `dart format` doesn't enforce this order
- **Learning Curve** - Developers must remember architectural order

### Neutral

- **Blank Lines** - Separate groups with blank lines for clarity
- **Alphabetical** - Within each group, alphabetical order

## Related Decisions

- [ADR-0001: Clean Architecture](0001-clean-architecture-three-layers.md) - Dependency rule
- [ADR-0002: MVVM Pattern](0002-mvvm-presentation-pattern.md) - Feature imports
- [ADR-0019: CLI Package Management](0019-cli-only-package-management.md) - Development conventions

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Documented in: `AGENTS.md` (Code Conventions section)
- Enforced via: Code review
- Example files: All ViewModels follow this convention
- Automation: Future linter rule consideration
