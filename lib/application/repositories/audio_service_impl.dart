import "package:audioplayers/audioplayers.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";

/// Implementation of IAudioService
///
/// Factory pattern - creates new AudioPlayer instances for feature use.
class AudioServiceImpl implements IAudioService {
  @override
  AudioPlayer createPlayer() => AudioPlayer();
}
