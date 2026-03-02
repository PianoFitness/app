import "dart:async";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:logging/logging.dart";
import "package:provider/provider.dart";
import "package:timezone/data/latest.dart" as tz;

import "package:piano_fitness/application/database/app_database.dart";
import "package:piano_fitness/application/repositories/audio_service_impl.dart";
import "package:piano_fitness/application/repositories/midi_repository_impl.dart";
import "package:piano_fitness/application/repositories/notification_repository_impl.dart";
import "package:piano_fitness/application/repositories/settings_repository_impl.dart";
import "package:piano_fitness/application/services/notifications/notification_manager.dart";
import "package:piano_fitness/application/state/midi_state.dart";
import "package:piano_fitness/domain/repositories/audio_service.dart";
import "package:piano_fitness/domain/repositories/midi_repository.dart";
import "package:piano_fitness/domain/repositories/notification_repository.dart";
import "package:piano_fitness/domain/repositories/settings_repository.dart";
import "package:piano_fitness/presentation/constants/typography_constants.dart";
import "package:piano_fitness/presentation/theme/semantic_colors.dart";
import "package:piano_fitness/presentation/widgets/main_navigation.dart";

/// Entry point for the Piano Fitness application.
///
/// Initializes the app with the root widget and starts the Flutter engine.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone data for notifications
  tz.initializeTimeZones();

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

        // Database
        Provider<AppDatabase>(
          create: (_) => AppDatabase(),
          dispose: (_, db) => db.close(),
        ),

        // Global MIDI state (shared across all features)
        ChangeNotifierProvider<MidiState>(create: (_) => MidiState()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Creates a custom TextTheme matching the app's design system.
///
/// Based on the Piano Fitness design specification with consistent font sizing
/// across display, headline, body, and label text styles. Font sizes are defined
/// in [FontSizes] for maintainability.
TextTheme _createTextTheme() {
  return const TextTheme(
    // Display styles - largest text
    displayLarge: TextStyle(fontSize: FontSizes.displayLarge),
    displayMedium: TextStyle(fontSize: FontSizes.displayMedium),
    displaySmall: TextStyle(fontSize: FontSizes.displaySmall),

    // Headline styles - section headers
    headlineLarge: TextStyle(fontSize: FontSizes.headlineLarge),
    headlineMedium: TextStyle(fontSize: FontSizes.headlineMedium),
    headlineSmall: TextStyle(fontSize: FontSizes.headlineSmall),

    // Title styles - component titles
    titleLarge: TextStyle(fontSize: FontSizes.titleLarge),
    titleMedium: TextStyle(fontSize: FontSizes.titleMedium),
    titleSmall: TextStyle(fontSize: FontSizes.titleSmall),

    // Body styles - main content
    bodyLarge: TextStyle(fontSize: FontSizes.bodyLarge),
    bodyMedium: TextStyle(fontSize: FontSizes.bodyMedium),
    bodySmall: TextStyle(fontSize: FontSizes.bodySmall),

    // Label styles - buttons, chips, small text
    labelLarge: TextStyle(fontSize: FontSizes.labelLarge),
    labelMedium: TextStyle(fontSize: FontSizes.labelMedium),
    labelSmall: TextStyle(fontSize: FontSizes.labelSmall),
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textTheme: _createTextTheme(),
        extensions: const <ThemeExtension<dynamic>>[SemanticColors.light],
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: _createTextTheme(),
        extensions: const <ThemeExtension<dynamic>>[SemanticColors.dark],
      ),
      home: const MainNavigation(),
    );
  }
}
