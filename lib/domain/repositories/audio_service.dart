import "package:audioplayers/audioplayers.dart";

/// Service interface for audio playback
///
/// Factory pattern - creates AudioPlayer instances for feature-specific use.
/// Each ViewModel manages its own player lifecycle.
abstract class IAudioService {
  /// Create new AudioPlayer instance for feature use
  ///
  /// Caller is responsible for disposing the player.
  AudioPlayer createPlayer();
}
