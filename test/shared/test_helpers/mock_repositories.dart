import "package:flutter/foundation.dart";
import "package:flutter_midi_command/flutter_midi_command.dart" as midi_cmd;
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/application/repositories/notification_manager_interface.dart";
import "package:piano_fitness/application/services/midi/midi_connection_service.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/repositories/notification_repository.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";
import "mock_repositories.mocks.dart";

// Generate mocks for repository interfaces and MIDI services
@GenerateMocks([
  IMidiRepository,
  INotificationRepository,
  ISettingsRepository,
  INotificationManager,
  IAudioService,
  AudioPlayerHandle,
  MidiConnectionService,
  midi_cmd.MidiCommand,
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
    for (final handler in List<void Function(Uint8List)>.from(_handlers)) {
      handler(data);
    }
  }
}
