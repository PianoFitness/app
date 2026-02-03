# ADR-0018: Audio Playback Factory Pattern

**Status:** Accepted

**Date:** 2024-01-01

## Context

Piano Fitness needs audio playback for:

- **Virtual Piano** - Play notes when no MIDI device connected
- **Reference Tones** - Play scales/chords for learning
- **Metronome** - Click track for timing (future)

**Requirements:**

- **Feature-Specific** - Each feature may need different audio sources
- **Testable** - Mock audio for tests
- **Platform Independent** - Works across iOS, Android, desktop, web
- **Low Latency** - Piano notes must play instantly (<100ms)

**Challenge:** Unlike MIDI (global singleton - ADR-0006), audio is feature-specific and requires independent instances.

## Decision

Implement **IAudioService with factory pattern** via Repository abstraction.

**Factory Pattern:**

```dart
// Repository provides factory, not singleton
class AudioRepository implements IAudioService {
  @override
  Future<AudioPlayer> createPlayer() async {
    return AudioPlayer(); // New instance each call
  }
  
  @override
  Future<void> playNote(int midiNote) async {
    final player = await createPlayer();
    await player.play(AssetSource('audio/$midiNote.mp3'));
  }
}
```

**IAudioService Interface:**
```dart
abstract class IAudioService {
  Future<AudioPlayer> createPlayer();
  Future<void> playNote(int midiNote);
  Future<void> playChord(List<int> notes);
  Future<void> stopAll();
}
```

**Contrast with MIDI (ADR-0006):**

| Concern   | MIDI (Singleton)         | Audio (Factory)         |
| --------- | ------------------------ | ----------------------- |
| Hardware  | One physical device      | Multiple audio sources  |
| State     | Global shared state      | Feature-specific state  |
| Lifecycle | App-wide                 | Feature-scoped          |
| Pattern   | Singleton + Global state | Factory + Local players |

**Usage Example:**
```dart
// PlayPage ViewModel
class PlayPageViewModel extends ChangeNotifier {
  final IAudioService _audioService;
  late AudioPlayer _pianoPlayer;
  
  PlayPageViewModel(this._audioService) {
    _pianoPlayer = await _audioService.createPlayer();
  }
  
  Future<void> playVirtualNote(int note) async {
    await _audioService.playNote(note);
  }
}
```

## Consequences

### Positive

- **Feature Independence** - Each feature controls own audio
- **Testability** - Easy to mock via IAudioService interface
- **Flexibility** - Different audio sources per feature
- **Resource Management** - Players disposed with features
- **Clear Separation** - Factory vs Singleton patterns match use cases

### Negative

- **Memory** - Multiple AudioPlayer instances (mitigated by disposal)
- **Complexity** - More instances to manage than singleton

### Neutral

- **Factory Pattern** - Standard pattern for feature-specific resources
- **Contrast with MIDI** - Different patterns for different constraints

## Related Decisions

- [ADR-0004: Repository Pattern](0004-repository-pattern-external-dependencies.md) - IAudioService abstraction
- [ADR-0006: Global MIDI State](0006-global-midi-state.md) - Contrast with singleton pattern
- [ADR-0007: Factory Pattern Audio Service](0007-factory-pattern-audio-service.md) - Original decision document

## Technical Story

*Note: Implementation links may become outdated as codebase evolves. Refer to git history for accurate implementation details at time of decision.*

- Interface: `lib/application/repositories/audio_repository.dart` (IAudioService)
- Implementation: Uses `audioplayers` package
- Audio assets: `assets/audio/`
- Usage: PlayPage, PracticePage, ReferencePage ViewModels
