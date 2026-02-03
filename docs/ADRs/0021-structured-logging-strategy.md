# ADR-0021: Structured Logging Strategy

**Status:** Proposed

**Date:** 2026-02-03

## Context

Piano Fitness logging is currently ad-hoc:

```dart
// Current approach (inconsistent)
print("MIDI connected"); // Some places
debugPrint("Note played: $note"); // Other places
if (kDebugMode) print("Debug info"); // Debug only
// No logs in some places
```

**Problems:**
- No log levels (info, warning, error)
- No structured data for analysis
- Production logs too verbose or missing
- Hard to filter by feature/concern
- No correlation IDs for debugging flows

## Decision

Implement **structured logging with flutter_logger package** (or similar).

**Proposed Architecture:**

```dart
// Centralized logger
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true
    ),
  );
  
  static void info(String message, {Map<String, dynamic>? data}) {
    _logger.i(message, data);
  }
  
  static void warning(String message, {dynamic error}) {
    _logger.w(message, error);
  }
  
  static void error(String message, dynamic error, StackTrace? stack) {
    _logger.e(message, error, stack);
  }
}
```

**Usage Example:**
```dart
// Structured logging
AppLogger.info("MIDI device connected", data: {
  "deviceName": device.name,
  "deviceId": device.id,
  "timestamp": DateTime.now().toIso8601String(),
});

// Error logging
try {
  await connectMidi();
} catch (e, stack) {
  AppLogger.error("MIDI connection failed", e, stack);
}
```

**Log Levels:**
- **DEBUG** - Development diagnostics (filtered in production)
- **INFO** - Normal operations (device connected, note played)
- **WARNING** - Recoverable issues (Bluetooth permission denied)
- **ERROR** - Failures requiring attention (connection timeout)

**Feature Tags:**
- `[MIDI]` - MIDI device operations
- `[PRACTICE]` - Practice session events
- `[AUDIO]` - Audio playback events
- `[NOTIFICATION]` - Notification scheduling

## Consequences

### Positive

- **Structured Data** - JSON logs enable analysis
- **Consistent** - Standard logger across codebase
- **Filterable** - By level, feature, timestamp
- **Production Ready** - Appropriate verbosity control
- **Debug Friendly** - Rich context for troubleshooting

### Negative

- **Migration Required** - Replace all print/debugPrint calls
- **Package Dependency** - Adds logging package
- **Learning Curve** - Developers must use structured format

### Neutral

- **Configuration** - Log levels configurable per build
- **Performance** - Minimal overhead in production

## Related Decisions

- [ADR-0001: Clean Architecture](0001-clean-architecture-three-layers.md) - Logging at all layers
- [ADR-0015: MIDI Message Processing](0015-midi-message-processing.md) - MIDI event logging

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- **Status:** Proposed - Not yet implemented
- Proposed package: `logger` (or equivalent)
- Logger utility: `lib/shared/utils/app_logger.dart`
- Migration: Replace all print/debugPrint calls
- Configuration: Build-specific log levels
