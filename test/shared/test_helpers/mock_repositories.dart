import "package:flutter/foundation.dart";
import "package:flutter_midi_command/flutter_midi_command.dart" as midi_cmd;
import "package:mockito/annotations.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/application/repositories/notification_manager_interface.dart";
import "package:piano_fitness/application/services/midi/midi_connection_service.dart";
import "package:piano_fitness/domain/models/midi/midi_input_packet.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";
import "package:piano_fitness/domain/repositories/exercise_history_repository.dart";
import "package:piano_fitness/domain/repositories/metronome_audio_service.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/repositories/notification_repository.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/domain/services/midi_device_discovery_service.dart";
import "mock_repositories.mocks.dart";

// Generate mocks for repository interfaces and MIDI services
@GenerateMocks([
  IMidiRepository,
  IMidiDeviceDiscoveryService,
  INotificationRepository,
  ISettingsRepository,
  IUserProfileRepository,
  IExerciseHistoryRepository,
  INotificationManager,
  IAudioService,
  AudioPlayerHandle,
  IMetronomeAudioService,
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
          invocation.positionalArguments[0] as void Function(MidiInputPacket);
      _handlers.add(handler);
    });

    when(mock.unregisterDataHandler(any)).thenAnswer((invocation) {
      final handler =
          invocation.positionalArguments[0] as void Function(MidiInputPacket);
      _handlers.remove(handler);
    });
  }

  final MockIMidiRepository mock;
  final List<void Function(MidiInputPacket)> _handlers = [];

  /// Simulates receiving MIDI data at [receivedAt] for testing event timing.
  void simulateMidiData(Uint8List data, {Duration receivedAt = Duration.zero}) {
    final packet = MidiInputPacket(data: data, receivedAt: receivedAt);
    for (final handler in List<void Function(MidiInputPacket)>.from(
      _handlers,
    )) {
      handler(packet);
    }
  }
}
