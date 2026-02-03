import "package:audioplayers/audioplayers.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";

/// Adapter wrapping audioplayers.AudioPlayer as AudioPlayerHandle
///
/// Isolates domain layer from external audio player implementation.
class _AudioPlayerAdapter implements AudioPlayerHandle {
  _AudioPlayerAdapter(this._player);

  final AudioPlayer _player;

  @override
  Future<void> playAsset(String assetPath) async {
    await _player.play(AssetSource(assetPath));
  }

  @override
  Future<void> stop() async {
    await _player.stop();
  }

  @override
  Future<void> dispose() async {
    await _player.dispose();
  }
}

/// Implementation of IAudioService
///
/// Factory pattern - creates new AudioPlayerHandle instances for feature use.
class AudioServiceImpl implements IAudioService {
  @override
  AudioPlayerHandle createPlayer() => _AudioPlayerAdapter(AudioPlayer());
}
