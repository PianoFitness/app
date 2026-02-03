import "package:flutter/foundation.dart";
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/repositories/notification_repository.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";
import "package:audioplayers/audioplayers.dart";
import "mock_repositories.mocks.dart";

// Generate mocks for repository interfaces
@GenerateMocks([
  IMidiRepository,
  INotificationRepository,
  ISettingsRepository,
  IAudioService,
  AudioPlayer,
])
void main() {}

// Helper class for MIDI repository with custom behavior
class MockMidiRepositoryHelper {
  MockMidiRepositoryHelper(this.mock) {
    // Setup default stub behaviors
    when(mock.registerDataHandler(any)).thenAnswer((invocation) {
      final handler =
          invocation.positionalArguments[0] as void Function(Uint8List);
      _handlers.add(handler);
    });

    when(mock.unregisterDataHandler(any)).thenAnswer((invocation) {
      final handler =
          invocation.positionalArguments[0] as void Function(Uint8List);
      _handlers.remove(handler);
    });
  }

  final MockIMidiRepository mock;
  final List<void Function(Uint8List)> _handlers = [];

  /// Simulate receiving MIDI data for testing
  void simulateMidiData(Uint8List data) {
    for (final handler in _handlers) {
      handler(data);
    }
  }
}
