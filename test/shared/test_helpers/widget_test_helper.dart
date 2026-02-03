import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/repositories/notification_repository.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";
import "mock_repositories.mocks.dart";

/// Creates a widget wrapped with all required providers for testing.
///
/// This helper provides a consistent MultiProvider setup for widget tests,
/// preventing code duplication and ensuring all dependencies are available.
///
/// Example usage:
/// ```dart
/// await tester.pumpWidget(createTestWidget(MyPage()));
/// ```
Widget createTestWidget(Widget child) {
  final mockMidiRepository = MockIMidiRepository();
  final mockNotificationRepository = MockINotificationRepository();
  final mockSettingsRepository = MockISettingsRepository();
  final mockAudioService = MockIAudioService();

  // Stub createPlayer for AudioService to prevent MissingStubError
  final mockAudioPlayer = MockAudioPlayerHandle();
  when(mockAudioService.createPlayer()).thenReturn(mockAudioPlayer);

  return MultiProvider(
    providers: [
      Provider<IMidiRepository>.value(value: mockMidiRepository),
      Provider<INotificationRepository>.value(
        value: mockNotificationRepository,
      ),
      Provider<ISettingsRepository>.value(value: mockSettingsRepository),
      Provider<IAudioService>.value(value: mockAudioService),
      ChangeNotifierProvider<MidiState>(create: (_) => MidiState()),
    ],
    child: MaterialApp(home: child),
  );
}

/// Creates a widget with custom mock implementations.
///
/// Use this when you need to control mock behavior for specific test scenarios.
///
/// Example:
/// ```dart
/// final mockMidi = MockIMidiRepository();
/// when(mockMidi.someMethod()).thenReturn(someValue);
///
/// await tester.pumpWidget(createTestWidgetWithMocks(
///   child: MyPage(),
///   midiRepository: mockMidi,
/// ));
/// ```
Widget createTestWidgetWithMocks({
  required Widget child,
  IMidiRepository? midiRepository,
  INotificationRepository? notificationRepository,
  ISettingsRepository? settingsRepository,
  IAudioService? audioService,
  MidiState? midiState,
}) {
  final mockMidiRepository = midiRepository ?? MockIMidiRepository();
  final mockNotificationRepository =
      notificationRepository ?? MockINotificationRepository();
  final mockSettingsRepository =
      settingsRepository ?? MockISettingsRepository();
  final mockAudioService = audioService ?? MockIAudioService();

  // Stub createPlayer for AudioService if not already stubbed
  if (audioService == null) {
    final mockAudioPlayer = MockAudioPlayerHandle();
    when(mockAudioService.createPlayer()).thenReturn(mockAudioPlayer);
  }

  return MultiProvider(
    providers: [
      Provider<IMidiRepository>.value(value: mockMidiRepository),
      Provider<INotificationRepository>.value(
        value: mockNotificationRepository,
      ),
      Provider<ISettingsRepository>.value(value: mockSettingsRepository),
      Provider<IAudioService>.value(value: mockAudioService),
      // Use .value() if custom MidiState provided, otherwise use create for auto-disposal
      if (midiState != null)
        ChangeNotifierProvider<MidiState>.value(value: midiState)
      else
        ChangeNotifierProvider<MidiState>(create: (_) => MidiState()),
    ],
    child: MaterialApp(home: child),
  );
}
