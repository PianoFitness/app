/// Domain-level abstraction for audio player
///
/// Provides only the methods needed by domain logic,
/// decoupling from specific audio player implementations.
abstract class AudioPlayerHandle {
  /// Play audio from an asset source
  Future<void> playAsset(String assetPath);

  /// Stop audio playback
  Future<void> stop();

  /// Dispose of player resources
  Future<void> dispose();
}

/// Service interface for audio playback
///
/// Factory pattern - creates AudioPlayerHandle instances for feature-specific use.
/// Each ViewModel manages its own player lifecycle.
abstract class IAudioService {
  /// Create new AudioPlayerHandle instance for feature use
  ///
  /// Caller is responsible for disposing the player.
  AudioPlayerHandle createPlayer();
}
