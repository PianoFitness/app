/// Service for playing metronome click sounds with minimal, consistent
/// trigger-to-sound latency.
///
/// Distinct from [IAudioService]: that abstraction wraps a single one-shot
/// player suited to occasional sound effects, while a metronome needs a
/// pool of pre-loaded, low-latency players that can fire in rapid
/// succession without waiting on the previous click to finish. See
/// docs/specifications/metronome-component.md#audio-system.
abstract class IMetronomeAudioService {
  /// Pre-loads the click sound so the first beat isn't slower than the
  /// rest. Call this when the metronome UI opens, before the user presses
  /// start. Safe to call multiple times.
  Future<void> initialize();

  /// Plays the click sound. This is the timing-critical call - implementations
  /// must not `await` any setup work here; do it in advance instead.
  ///
  /// [volume] is in the 0.0-1.0 range, driven by beat emphasis.
  Future<void> playClick({required double volume});

  /// Releases all held audio resources. Safe to call even if playback was
  /// never triggered.
  Future<void> dispose();
}
