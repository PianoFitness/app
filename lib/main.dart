import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_midi_command/flutter_midi_command.dart";
import "package:flutter_midi_command_ble/flutter_midi_command_ble.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:timezone/data/latest.dart" as tz;

import "package:piano_fitness/application/database/app_database.dart";
import "package:piano_fitness/application/repositories/audio_service_impl.dart";
import "package:piano_fitness/application/repositories/metronome_audio_service_impl.dart";
import "package:piano_fitness/application/repositories/midi_repository_impl.dart";
import "package:piano_fitness/application/services/midi/midi_device_discovery_service_impl.dart";
import "package:piano_fitness/application/utils/midi_coordinator.dart";
import "package:piano_fitness/application/repositories/notification_repository_impl.dart";
import "package:piano_fitness/application/repositories/settings_repository_impl.dart";
import "package:piano_fitness/application/repositories/user_profile_repository_impl.dart";
import "package:piano_fitness/application/repositories/exercise_history_repository_impl.dart";
import "package:piano_fitness/application/services/notifications/notification_manager.dart";
import "package:piano_fitness/application/state/metronome_state.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";
import "package:piano_fitness/domain/repositories/metronome_audio_service.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/services/midi_device_discovery_service.dart";
import "package:piano_fitness/domain/repositories/notification_repository.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";
import "package:piano_fitness/domain/repositories/exercise_history_repository.dart";
import "package:piano_fitness/domain/repositories/user_profile_repository.dart";
import "package:piano_fitness/presentation/theme/app_theme.dart";
import "package:piano_fitness/presentation/widgets/profile_initializer.dart";

/// Entry point for the Piano Fitness application.
///
/// Initializes the app with the root widget and starts the Flutter engine.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data for notifications
  tz.initializeTimeZones();

  // Initialize SharedPreferences for profile management
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize database
  final database = AppDatabase();

  // Initialize notification repository with async factory
  final notificationRepository = await NotificationRepositoryImpl.create();

  // Configure logging levels
  if (kDebugMode) {
    // In debug mode, show fine (and above) for detailed diagnostics
    Logger.root.level = Level.FINE;
  } else {
    // In production, only show warnings and errors
    Logger.root.level = Level.WARNING;
  }

  // Set up logging output handler
  Logger.root.onRecord.listen((record) {
    // Only print logs in debug mode to avoid noise in production
    if (!kDebugMode) return;
    final errorSuffix = record.error != null ? " error: ${record.error}" : "";
    final stackSuffix = record.stackTrace != null
        ? "\n${record.stackTrace}"
        : "";
    debugPrint(
      "${record.level.name}: ${record.time}: "
      "${record.loggerName}: ${record.message}$errorSuffix$stackSuffix",
    );
  });

  // Create logger for main initialization
  final log = Logger("main");

  // Wire up BLE MIDI support before any code obtains the MidiCommand
  // singleton, since only the first construction can attach a transport.
  MidiCommand(bleTransport: UniversalBleMidiTransport());

  runApp(
    MultiProvider(
      providers: [
        // Repository interfaces
        Provider<IMidiRepository>(
          create: (_) {
            final repository = MidiRepositoryImpl();
            // Initialize MIDI listening on startup
            // Use unawaited to capture the Future without blocking Provider creation
            unawaited(
              repository.initialize().catchError((
                Object error,
                StackTrace stackTrace,
              ) {
                log.severe(
                  "Failed to initialize MIDI repository: $error",
                  error,
                  stackTrace,
                );
              }),
            );
            return repository;
          },
          dispose: (_, repository) => repository.dispose(),
        ),
        Provider<INotificationRepository>.value(value: notificationRepository),
        Provider<ISettingsRepository>(
          create: (_) => SettingsRepositoryImpl(
            notificationManager: NotificationManager.instance,
          ),
          lazy: false,
        ),
        Provider<IAudioService>(create: (_) => AudioServiceImpl()),
        Provider<IMetronomeAudioService>(
          create: (_) => MetronomeAudioServiceImpl(),
          dispose: (_, service) => service.dispose(),
        ),

        // Database (with dispose callback to close database)
        Provider<AppDatabase>(
          create: (_) => database,
          dispose: (_, db) => db.close(),
        ),

        // User profile repository
        Provider<IUserProfileRepository>(
          create: (_) => UserProfileRepositoryImpl(
            database: database,
            prefs: sharedPreferences,
          ),
        ),

        // Exercise history repository
        Provider<IExerciseHistoryRepository>(
          create: (_) => ExerciseHistoryRepositoryImpl(database: database),
        ),

        // MIDI device discovery service (Bluetooth lifecycle + device scanning)
        Provider<IMidiDeviceDiscoveryService>(
          create: (_) => MidiDeviceDiscoveryServiceImpl(),
          dispose: (_, service) => service.dispose(),
        ),

        // MIDI subscription coordinator (derived from IMidiRepository)
        ProxyProvider<IMidiRepository, MidiCoordinator>(
          update: (_, repo, _) => MidiCoordinator(repo),
        ),

        // Global MIDI state (shared across all features)
        ChangeNotifierProvider<MidiState>(create: (_) => MidiState()),

        // Global metronome state (shared across all features, so a
        // student can start it once and keep it running while navigating)
        ChangeNotifierProvider<MetronomeState>(
          create: (context) => MetronomeState(
            audioService: context.read<IMetronomeAudioService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

/// The root widget of the Piano Fitness application.
///
/// Sets up the app theme and defines the initial navigation structure.
/// Each page now manages its own local MIDI state for better isolation.
class MyApp extends StatelessWidget {
  /// Creates the root widget of the Piano Fitness app.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Piano Fitness",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      home: const ProfileInitializer(),
    );
  }
}
