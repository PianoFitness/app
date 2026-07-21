import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "package:mockito/mockito.dart";
import "package:piano_fitness/application/state/metronome_state.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/domain/repositories/exercise_history_repository.dart";
import "package:piano_fitness/domain/repositories/metronome_audio_service.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/repositories/notification_repository.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "mock_repositories.mocks.dart";

/// Stubs the [IMetronomeAudioService] methods MetronomeState calls
/// unconditionally (initialize on creation, dispose on teardown) so tests
/// don't hit MissingStubError just from having the provider in the tree.
MockIMetronomeAudioService _createStubbedMetronomeAudioService() {
  final mock = MockIMetronomeAudioService();
  when(mock.initialize()).thenAnswer((_) async {});
  when(mock.playClick(volume: anyNamed("volume"))).thenAnswer((_) async {});
  when(mock.dispose()).thenAnswer((_) async {});
  return mock;
}

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
  final mockUserProfileRepository = MockIUserProfileRepository();
  final mockExerciseHistoryRepository = MockIExerciseHistoryRepository();

  // Stub createPlayer for AudioService to prevent MissingStubError
  final mockAudioPlayer = MockAudioPlayerHandle();
  when(mockAudioService.createPlayer()).thenReturn(mockAudioPlayer);

  // Stub basic UserProfileRepository methods
  when(
    mockUserProfileRepository.getActiveProfileId(),
  ).thenAnswer((_) async => null);

  return MultiProvider(
    providers: [
      Provider<IMidiRepository>.value(value: mockMidiRepository),
      Provider<MidiCoordinator>(
        create: (_) => MidiCoordinator(mockMidiRepository),
      ),
      Provider<INotificationRepository>.value(
        value: mockNotificationRepository,
      ),
      Provider<ISettingsRepository>.value(value: mockSettingsRepository),
      Provider<IAudioService>.value(value: mockAudioService),
      Provider<IUserProfileRepository>.value(value: mockUserProfileRepository),
      Provider<IExerciseHistoryRepository>.value(
        value: mockExerciseHistoryRepository,
      ),
      ChangeNotifierProvider<MidiState>(create: (_) => MidiState()),
      Provider<IMetronomeAudioService>.value(
        value: _createStubbedMetronomeAudioService(),
      ),
      ChangeNotifierProvider<MetronomeState>(
        create: (context) => MetronomeState(
          audioService: context.read<IMetronomeAudioService>(),
        ),
      ),
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
  IUserProfileRepository? userProfileRepository,
  IExerciseHistoryRepository? exerciseHistoryRepository,
  MidiState? midiState,
  MetronomeState? metronomeState,
}) {
  final mockMidiRepository = midiRepository ?? MockIMidiRepository();
  final mockNotificationRepository =
      notificationRepository ?? MockINotificationRepository();
  final mockSettingsRepository =
      settingsRepository ?? MockISettingsRepository();
  final mockAudioService = audioService ?? MockIAudioService();
  final mockUserProfileRepository =
      userProfileRepository ?? MockIUserProfileRepository();
  final mockExerciseHistoryRepository =
      exerciseHistoryRepository ?? MockIExerciseHistoryRepository();

  // Stub createPlayer for AudioService if not already stubbed
  if (audioService == null) {
    final mockAudioPlayer = MockAudioPlayerHandle();
    when(mockAudioService.createPlayer()).thenReturn(mockAudioPlayer);
  }

  // Stub basic UserProfileRepository methods if not already stubbed
  if (userProfileRepository == null) {
    when(
      mockUserProfileRepository.getActiveProfileId(),
    ).thenAnswer((_) async => null);
  }

  return MultiProvider(
    providers: [
      Provider<IMidiRepository>.value(value: mockMidiRepository),
      Provider<MidiCoordinator>(
        create: (_) => MidiCoordinator(mockMidiRepository),
      ),
      Provider<INotificationRepository>.value(
        value: mockNotificationRepository,
      ),
      Provider<ISettingsRepository>.value(value: mockSettingsRepository),
      Provider<IAudioService>.value(value: mockAudioService),
      Provider<IUserProfileRepository>.value(value: mockUserProfileRepository),
      Provider<IExerciseHistoryRepository>.value(
        value: mockExerciseHistoryRepository,
      ),
      // Use .value() if custom MidiState provided, otherwise use create for auto-disposal
      if (midiState != null)
        ChangeNotifierProvider<MidiState>.value(value: midiState)
      else
        ChangeNotifierProvider<MidiState>(create: (_) => MidiState()),
      Provider<IMetronomeAudioService>.value(
        value: _createStubbedMetronomeAudioService(),
      ),
      // Use .value() if custom MetronomeState provided, otherwise use
      // create for auto-disposal
      if (metronomeState != null)
        ChangeNotifierProvider<MetronomeState>.value(value: metronomeState)
      else
        ChangeNotifierProvider<MetronomeState>(
          create: (context) => MetronomeState(
            audioService: context.read<IMetronomeAudioService>(),
          ),
        ),
    ],
    child: MaterialApp(home: child),
  );
}
