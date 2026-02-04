# ADR-0007: Factory Pattern for Audio Service

**Status:** Accepted

**Date:** 2026-02-03

## Context

Audio playback in Piano Fitness has different requirements than MIDI:
- **MIDI**: Global hardware resource, one device, shared state across features
- **Audio**: Feature-specific resource, each feature manages own player lifecycle

Only `RepertoirePageViewModel` uses audio playback. Unlike MIDI state which is shared globally, audio playback is:
- Feature-specific (not shared between features)
- Lifecycle-managed (created/disposed by ViewModel)
- Independent (no cross-feature coordination needed)

**Anti-Pattern to Avoid:**
Global AudioPlayer singleton would be inappropriate because:
- Only one feature uses audio
- Different features might need simultaneous audio in the future
- Resource cleanup must be feature-specific

## Decision

Use factory pattern for `IAudioService` - service creates AudioPlayer instances on demand, caller manages lifecycle.

**Implementation:**

```dart
abstract class IAudioService {
  AudioPlayer createPlayer();
}

class AudioServiceImpl implements IAudioService {
  @override
  AudioPlayer createPlayer() => AudioPlayer();
}
```

**ViewModel Usage:**

```dart
class RepertoirePageViewModel extends ChangeNotifier {
  RepertoirePageViewModel({required IAudioService audioService})
    : _audioService = audioService {
    _player = _audioService.createPlayer();
  }
  
  late final AudioPlayer _player;
  
  @override
  void dispose() {
    _player.dispose(); // ViewModel owns lifecycle
    super.dispose();
  }
}
```

**Rationale:**

- **Feature Ownership** - Each ViewModel creates and disposes its own player
- **Testability** - Factory method easy to mock
- **Flexibility** - Future features can create their own players
- **Proper Resource Management** - Caller responsible for disposal

## Consequences

### Positive

- **Feature Isolation** - Audio lifecycle isolated to feature needing it
- **Testability** - Easy to mock factory method
- **Resource Safety** - Clear disposal responsibility
- **Future-Proof** - Multiple features can have independent audio

### Negative

- **Manual Lifecycle** - ViewModel must remember to dispose player
- **Not Truly DI** - Factory method less pure than injecting player directly

### Neutral

- **Factory Pattern** - Standard creational pattern for resource management
- **Single User** - Currently only RepertoirePageViewModel uses audio

## Related Decisions

- [ADR-0004: Repository Pattern](0004-repository-pattern-external-dependencies.md) - Repository abstraction strategy
- [ADR-0006: Global MIDI State](0006-global-midi-state.md) - Contrast: MIDI is global, audio is not
- [ADR-0018: Audio Playback](0018-audio-playback-factory-pattern.md) - Feature-specific audio implementation

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Interface: `lib/domain/repositories/audio_service.dart`
- Implementation: `lib/application/repositories/audio_service_impl.dart`
- Usage: `lib/features/repertoire/repertoire_page_view_model.dart`
- Original decision: `REFACTOR_DI.md` "ADR-003"
